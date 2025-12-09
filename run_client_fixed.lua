local Run = {}
Run.__index = Run

--> // Variables
local ReplicatedStorage : ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService : RunService = game:GetService("RunService")
local Players : Players = game:GetService("Players")

local Modules = ReplicatedStorage.Modules
local HelperFunctions = require(Modules.Shared.HelperFunctions)
local Settings = require(Modules.Run.Settings) :: GameSettings

local Player : Player = Players.LocalPlayer
local Character : Model = Player.Character or Player.CharacterAdded:Wait()
local Humanoid : Humanoid = Character:WaitForChild("Humanoid")

local RegenerationTimer : number = 0

-- 🎯 Usar ID de animación en lugar de script.Run
local RunAnimationId = 130760743624770 -- Usar el mismo ID que en HandleEKeyAndAnimation
local RunAnimation = Instance.new("Animation")
RunAnimation.AnimationId = "rbxassetid://" .. tostring(RunAnimationId)

--> // Function when you begin running
function Run.begin(Character: Model)
	if Character:GetAttribute("state") == "running" then return end
	Character:SetAttribute("state", "running")
	RegenerationTimer = Settings.RegenerationDelay

	HelperFunctions.PlayAnimation(Character, RunAnimation, false)
	Humanoid.WalkSpeed = 22
end

--> // Function when you stop running
function Run.stop(Character: Model)
	if Character:GetAttribute("state") ~= "running" then return end
	Character:SetAttribute("state", "neutral")
	RegenerationTimer = Settings.RegenerationDelay

	HelperFunctions.StopAllAnimations(Character)
	Humanoid.WalkSpeed = 16
end

--> // Updates Stamina Attribute
RunService.Heartbeat:Connect(function(Delta : number) : RunService
	if not Character or not Character.Parent then
		Character = Player.Character or Player.CharacterAdded:Wait()
		Humanoid = Character:WaitForChild("Humanoid")
	end

	local Stamina = Character:GetAttribute("stamina") or 100
	
	if Character:GetAttribute("state") == "running" then
		Stamina = math.max(Stamina - Delta * Settings.DepletionRate, 0)
		Character:SetAttribute("stamina", Stamina)
		
		--> // If you run out of stamina, stop running
		if Stamina <= 0 then
			Character:SetAttribute("state", "neutral")
			Run.stop(Character)
		end
	else
		--> // Regenerate Stamina over time if you're not running
		if RegenerationTimer > 0 then
			RegenerationTimer -= Delta
		else
			Stamina = math.min(Stamina + Delta * Settings.RegenerationRate, 100)
			Character:SetAttribute("stamina", Stamina)
		end
	end
end)

return Run
