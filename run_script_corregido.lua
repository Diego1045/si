-- Variables
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Modules = ReplicatedStorage.Modules
local RunClient = require(Modules.Run.RunClient)
local StaminaBar = require(script.StaminaBar)

local Character = script.Parent

-- Set state to neutral & give full stamina
Character:SetAttribute("state", "neutral")
Character:SetAttribute("stamina", 100)

-- Initialize Stamina Bar
StaminaBar.Init(Character)

local running = false
local defaultSpeed = 16

-- Función para obtener el Humanoid del personaje
local function getHumanoid()
	for i, obj in Character:GetChildren() do
		if obj:IsA("Humanoid") then
			return obj
		end
	end
	return nil
end

-- Detect Shift key press
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		local state = Character:GetAttribute("state")
		if state == "neutral" and Character:GetAttribute("stamina") > 0 then
			Character:SetAttribute("state", "running")
			running = true
			RunClient.begin(Character)
		end
	end
end)

-- Detect Shift key release
UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.LeftShift and Character:GetAttribute("state") == "running" then
		Character:SetAttribute("state", "neutral")
		running = false
		RunClient.stop(Character)
	end
end)
