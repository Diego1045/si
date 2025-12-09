local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GOAL_TEXT_LABEL_PATH = "Time/Contadot Team b/goles"

local goalEvent = ReplicatedStorage:WaitForChild("GoalScored")
local goalCountValue = ReplicatedStorage:WaitForChild("GoalCount")

local function findGoalLabel()
	local pathPieces = string.split(GOAL_TEXT_LABEL_PATH, "/")
	local current = playerGui

	for _, piece in ipairs(pathPieces) do
		current = current:FindFirstChild(piece)
		if not current then
			break
		end
	end

	if current and current:IsA("TextLabel") then
		return current
	end

	return nil
end

local goalLabel = findGoalLabel()

if not goalLabel then
	warn("[GoalScoreDisplay] No se encontró el TextLabel en la ruta:", GOAL_TEXT_LABEL_PATH)
end

local function updateGoalText(newValue)
	if goalLabel then
		goalLabel.Text = string.format("Goles: %d", newValue)
	end
end

updateGoalText(goalCountValue.Value)

goalEvent.OnClientEvent:Connect(function(count)
	updateGoalText(count)
end)

goalCountValue:GetPropertyChangedSignal("Value"):Connect(function()
	updateGoalText(goalCountValue.Value)
end)

