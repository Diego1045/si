-- 🛡️ Barrida (Slide Tackle) - LocalScript
-- Ubicación recomendada: StarterPlayer > StarterPlayerScripts
-- Reproduce la animación y avisa al servidor para aplicar la física al balón

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer

-- Helper robusto para obtener el Character listo (incluye respawns)
local function getPlayerCharacter()
	local char = localPlayer.Character
	if not char or not char.Parent then
		char = localPlayer.CharacterAdded:Wait()
	end
	char:WaitForChild("Humanoid")
	return char
end

local character = getPlayerCharacter()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Configuración
local SLIDE_KEY = Enum.KeyCode.Q
local SLIDE_COOLDOWN = 1.2
local lastSlide = 0

-- Animación de barrida (ID proporcionado por el usuario)
local SLIDE_ANIM_ID = "rbxassetid://130760743624770"
local slideTrack do
	local anim = Instance.new("Animation")
	anim.AnimationId = SLIDE_ANIM_ID
	slideTrack = humanoid:LoadAnimation(anim)
	slideTrack.Priority = Enum.AnimationPriority.Action
end

-- RemoteEvent (client → server)
local slideEvent = ReplicatedStorage:FindFirstChild("SlideTackle")
if not slideEvent then
	slideEvent = Instance.new("RemoteEvent")
	slideEvent.Name = "SlideTackle"
	slideEvent.Parent = ReplicatedStorage
end

-- Entrada de usuario
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode ~= SLIDE_KEY then return end
	if os.clock() - lastSlide < SLIDE_COOLDOWN then return end

	lastSlide = os.clock()

	-- Dirección de cámara / movimiento
	local cam = workspace.CurrentCamera
	local dir = (cam and cam.CFrame.LookVector) or rootPart.CFrame.LookVector
	local dirFlat = Vector3.new(dir.X, 0, dir.Z)
	if dirFlat.Magnitude < 0.01 then return end
	dirFlat = dirFlat.Unit

	-- Animación local
	if slideTrack then
		slideTrack:Play(0.05, 1, 1)
	end

	-- Avisar al servidor
	slideEvent:FireServer(dirFlat)
end)

-- Re‐enganchar tras respawn
localPlayer.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = newChar:WaitForChild("Humanoid")
	rootPart = newChar:WaitForChild("HumanoidRootPart")
end)


