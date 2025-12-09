local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local shiftLockStatus = false

-- Esta es la función que comienza a escribir en el segundo 412s
local function lock()
	if not rootPart then return end
	
	-- Lógica que añade unos segundos después para rotar el personaje [08:01]
	local lookVector = camera.CFrame.LookVector
	local rootPos = rootPart.Position
	local distance = 500 -- Puede ser cualquier número grande (100 a 1000)
	
	-- Crea un CFrame que mira hacia donde mira la cámara, pero ignorando la inclinación vertical (Y)
	-- [08:35]
	rootPart.CFrame = CFrame.new(rootPos, rootPos + (lookVector * Vector3.new(1, 0, 1) * distance))
end

local mouse = player:GetMouse()

local function shiftLock(toggle)
	shiftLockStatus = toggle
	
	-- Cambiar AutoRotate [06:08]
	humanoid.AutoRotate = not toggle
	
	if toggle then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		mouse.Icon = "http://www.roblox.com/asset?id=569945341" -- Icono personalizado del usuario
		-- Aquí está la parte clave del minuto 06:52 (BindToRenderStep)
		-- Prioridad 200 es alta para que sea suave
		RunService:BindToRenderStep("ShiftLock", 200, lock)
	else
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		mouse.Icon = "" -- Restaurar icono por defecto
		-- Desvincular cuando se desactiva [07:35]
		RunService:UnbindFromRenderStep("ShiftLock")
	end
end

-- Detectar la tecla (F) [02:05]
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	
	local isControl = input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl
	
	if isControl then
		shiftLock(not shiftLockStatus)
	end
end)
