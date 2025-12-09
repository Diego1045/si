local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Esperar al evento
local GoalCelebration = ReplicatedStorage:WaitForChild("GoalCelebration")

-- Configuración de la cámara de celebración
local CAMERA_OFFSET = Vector3.new(8, 5, 8) -- Distancia (X, Y, Z) desde el jugador
local FOV_CELEBRATION = 50 -- Campo de visión para efecto cinemático

-- Obtener el controlador de MouseLock (Shift Lock)
local PlayerModule = require(player.PlayerScripts:WaitForChild("PlayerModule"))
local mouseLockController = PlayerModule:GetCameras().activeMouseLockController

local function startCelebration(scoringPlayer, duration)
	if not scoringPlayer or not scoringPlayer.Character then return end
	
	local targetRoot = scoringPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return end
	
	print("[CelebrationCamera] 🎥 Iniciando cámara de celebración para: " .. scoringPlayer.Name)
	
	-- Guardar configuración original
	local originalCameraType = camera.CameraType
	local originalSubject = camera.CameraSubject
	local originalFOV = camera.FieldOfView
	
	-- Desactivar Shift Lock temporalmente
	if mouseLockController then
		mouseLockController:EnableMouseLock(false)
	end
	
	-- Cambiar a modo Scriptable para control total
	camera.CameraType = Enum.CameraType.Scriptable
	
	-- Efecto de Tween (suavizado) para el FOV
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(camera, tweenInfo, {FieldOfView = FOV_CELEBRATION}):Play()
	
	-- Loop para mantener la cámara enfocada aunque el jugador se mueva (celebrando)
	local connection
	local startTime = tick()
	
	connection = RunService.RenderStepped:Connect(function()
		if not targetRoot then 
			connection:Disconnect()
			return
		end
		
		-- Usamos Opción A: Fija relativa al jugador (gira con él) para ver siempre su cara
		-- Offset: 0 en X (centro), 2 en Y (altura), -8 en Z (al frente del jugador)
		-- Nota: En Roblox, -Z es "hacia adelante". Si ponemos la cámara en -8, estará 8 studs delante de la cara.
		local relativeOffset = Vector3.new(0, 2, -8) 
		local cameraPosition = targetRoot.CFrame:PointToWorldSpace(relativeOffset)
		
		-- Mirar a la cabeza (o un poco arriba del pecho)
		local lookAtPosition = targetRoot.Position + Vector3.new(0, 1.5, 0)
		
		-- Actualizar CFrame de la cámara (Posición frontal, mirando a la cara)
		-- Invertimos la dirección de la cámara para que mire hacia atrás (hacia el jugador)
		camera.CFrame = CFrame.lookAt(cameraPosition, lookAtPosition)
		
		-- Verificar tiempo
		if tick() - startTime >= duration then
			connection:Disconnect()
			
			-- Restaurar cámara
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = player.Character and player.Character:FindFirstChild("Humanoid")
			TweenService:Create(camera, tweenInfo, {FieldOfView = originalFOV}):Play()
			
			-- Reactivar Shift Lock (opcional, permite al usuario volver a usarlo)
			if mouseLockController then
				mouseLockController:EnableMouseLock(true)
			end
			
			print("[CelebrationCamera] ⏹️ Fin de celebración")
		end
	end)
end

print("[CelebrationCamera] 🎧 Esperando evento GoalCelebration...") -- DEBUG
GoalCelebration.OnClientEvent:Connect(function(scoringPlayer, duration)
	print("[CelebrationCamera] 📨 Evento recibido para: " .. tostring(scoringPlayer)) -- DEBUG
	startCelebration(scoringPlayer, duration)
end)
