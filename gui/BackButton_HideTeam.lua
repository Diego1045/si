local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local Back_Play = playerGui:FindFirstChild("Back_Play", true)
local Team_White = playerGui:FindFirstChild("Team_White", true)
local main_buttons = playerGui:FindFirstChild("main_buttons", true)

local cameraViewModule = ReplicatedStorage:FindFirstChild("camera_view_system") or script.Parent:FindFirstChild("camera_view_system")
local CameraViewSystem = cameraViewModule and require(cameraViewModule) or nil
local ReleasePosition = ReplicatedStorage:FindFirstChild("ReleasePosition")

Back_Play.MouseButton1Click:Connect(function()
	Team_White.Visible = false
	main_buttons.Visible = true

	if ReleasePosition then
		ReleasePosition:FireServer()
	end
	
	if CameraViewSystem and CameraViewSystem.Deactivate then
		CameraViewSystem.Deactivate()
	else
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				camera.CameraType = Enum.CameraType.Custom
				camera.CameraSubject = humanoid
			end
		end
	end
end)

