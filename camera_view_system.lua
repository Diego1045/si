-- 🎥 Sistema de Vista de Cámara
-- Cambia la cámara del jugador a donde mira una parte llamada "Camara"

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- 📌 Variables
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local viewingCameraMode = false

print("[CameraViewSystem] ✅ Sistema iniciado")

-- 📌 Función para encontrar la parte "Camara"
local function findCameraPart()
	-- Buscar en el workspace
	local cameraPart = workspace:FindFirstChild("Camara")
	
	if cameraPart and cameraPart:IsA("BasePart") then
		print("[CameraViewSystem] ✅ Parte 'Camara' encontrada")
		return cameraPart
	end
	
	warn("[CameraViewSystem] 🚫 No se encontró la parte 'Camara'")
	return nil
end

-- 📌 Activar vista de cámara
local function activateCameraView()
	local cameraPart = findCameraPart()
	if not cameraPart then
		return
	end
	
	viewingCameraMode = true
	print("[CameraViewSystem] 🎥 Activando vista de cámara")
	
	-- Cambiar tipo de cámara a Scriptable (funciona mejor que Fixed para esta configuración)
	camera.CameraType = Enum.CameraType.Scriptable
	
	-- Posicionar la cámara 1 stud arriba de "Camara" y desplazada 90 studs a la izquierda en X
	local cameraPosition = cameraPart.Position + Vector3.new(-90, 1, 0) -- 90 studs a la izquierda (X negativo), 1 stud arriba
	local lookDirection = Vector3.new(0, -1, 0) -- Mirar hacia abajo (dirección negativa Y)
	
	-- Crear CFrame que apunta hacia abajo desde la posición
	local cameraCFrame = CFrame.lookAt(cameraPosition, cameraPosition + lookDirection)
	camera.CFrame = cameraCFrame
	
	print("[CameraViewSystem] ✅ Vista de cámara activada - Mirando hacia abajo desde 1 stud arriba")
end

-- 📌 Desactivar vista de cámara (vuelve al jugador)
local function deactivateCameraView()
	viewingCameraMode = false
	print("[CameraViewSystem] 🚶 Desactivando vista de cámara")
	
	local character = player.Character
	if not character then
		warn("[CameraViewSystem] No hay personaje")
		return
	end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		warn("[CameraViewSystem] No hay humanoid")
		return
	end
	
	-- Volver a la cámara personalizada (que sigue al jugador)
	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = humanoid
	
	print("[CameraViewSystem] ✅ Vuelta a vista normal")
end

-- 📌 Toggle de vista de cámara
local function toggleCameraView()
	if viewingCameraMode then
		deactivateCameraView()
	else
		activateCameraView()
	end
end

-- 📌 Conexión de eventos
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.F then
		print("[CameraViewSystem] 🔘 Tecla F presionada")
		toggleCameraView()
	end
end)

print("[CameraViewSystem] ✅ Sistema completamente inicializado")
print("[CameraViewSystem] 💡 Presiona F para activar/desactivar la vista de cámara")
