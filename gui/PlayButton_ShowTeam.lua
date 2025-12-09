local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local Play_button = playerGui:FindFirstChild("Play_button", true)
local Team_White = playerGui:FindFirstChild("Team_White", true)
local main_buttons = playerGui:FindFirstChild("main_buttons", true)

local cameraViewModule = ReplicatedStorage:FindFirstChild("camera_view_system") or script.Parent:FindFirstChild("camera_view_system")
local CameraViewSystem = cameraViewModule and require(cameraViewModule) or nil

Play_button.MouseButton1Click:Connect(function()
	Team_White.Visible = true
	main_buttons.Visible = false
	
	if CameraViewSystem and CameraViewSystem.Activate then
		CameraViewSystem.Activate()
	else
		local cameraPart = workspace:FindFirstChild("Camara")
		if cameraPart then
			camera.CameraType = Enum.CameraType.Scriptable
			local cameraPosition = cameraPart.Position + Vector3.new(-90, 1, 0)
			local lookDirection = Vector3.new(0, -1, -0.1)
			camera.CFrame = CFrame.lookAt(cameraPosition, cameraPosition + lookDirection)
		end
	end
end)

