local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

local RequestPosition = ReplicatedStorage:WaitForChild("RequestPosition")
local button = script.Parent -- CF_white
local main_buttons = playerGui:FindFirstChild("main_buttons", true)
local team_white = playerGui:FindFirstChild("Team_White", true)

local messageGui = playerGui:FindFirstChild("TeamMessageGui")
if not messageGui then
	messageGui = Instance.new("ScreenGui")
	messageGui.Name = "TeamMessageGui"
	messageGui.ResetOnSpawn = false
	messageGui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Name = "MessageFrame"
	frame.Size = UDim2.new(0, 820, 0, 54)
	frame.Position = UDim2.new(0.5, 0, 0.18, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 0.1
	frame.Visible = false
	frame.Parent = messageGui

	local label = Instance.new("TextLabel")
	label.Name = "MessageLabel"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.TextWrapped = true
	label.TextStrokeTransparency = 0.7
	label.Parent = frame

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 24)
	padding.PaddingRight = UDim.new(0, 24)
	padding.Parent = label

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = 0.25
	stroke.Parent = frame
end

local messageFrame = messageGui:FindFirstChild("MessageFrame")
local messageLabel = messageFrame and messageFrame:FindFirstChild("MessageLabel")

local function showMessage(text)
	if not (messageFrame and messageLabel) then
		return
	end
	messageLabel.Text = text
	messageFrame.Visible = true
	task.delay(3, function()
		if messageLabel.Text == text then
			messageFrame.Visible = false
		end
	end)
end

local function getCharacter()
	return player.Character or player.CharacterAdded:Wait()
end

if button then
	button.MouseButton1Click:Connect(function()
		local success, ok, data = pcall(function()
			return RequestPosition:InvokeServer(button.Name)
		end)

		if not success then
			showMessage("Error de conexión. Intenta nuevamente.")
			return
		end

		if not ok then
			showMessage(data or "Esa posición está ocupada")
			return
		end

		local character = getCharacter()
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		
		if data == "Reservado" then
			-- Resetear cámara para que el jugador pueda moverse en el lobby
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				camera.CameraType = Enum.CameraType.Custom
				camera.CameraSubject = humanoid
			end

			if main_buttons then main_buttons.Visible = false end
			if team_white then team_white.Visible = false end
			return
		end

		if humanoidRootPart and typeof(data) == "CFrame" then
			humanoidRootPart.CFrame = data
		end

		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = humanoid
		end

		if main_buttons then
			main_buttons.Visible = false
		end

		if team_white then
			team_white.Visible = false
		end
	end)
end
