local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 📂 VARIABLES
local GameState = ReplicatedStorage:WaitForChild("GameState")
local TimeRemaining = ReplicatedStorage:WaitForChild("TimeRemaining")
local HomeScore = ReplicatedStorage:WaitForChild("HomeScore")
local AwayScore = ReplicatedStorage:WaitForChild("AwayScore")

-- 🎨 GUI SETUP
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GameStatusGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true -- Para que se pegue al borde real de la pantalla
screenGui.Parent = playerGui

-- Frame Principal (Contenedor)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "ScoreboardFrame"
mainFrame.Size = UDim2.new(0, 450, 0, 90) -- MENOS ANCHO (Antes 600)
mainFrame.Position = UDim2.new(0.5, 0, 0, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0)
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = screenGui

-- 🟦 LADO IZQUIERDO (INICIO - HOME - AZUL)
local leftContainer = Instance.new("Frame")
leftContainer.Name = "LeftContainer"
leftContainer.Size = UDim2.new(0.5, 0, 1, 0)
leftContainer.Position = UDim2.new(0, 0, 0, 0)
leftContainer.BackgroundColor3 = Color3.fromRGB(0, 80, 255) -- Azul intenso
leftContainer.BorderSizePixel = 0
leftContainer.Parent = mainFrame

-- Decoración
local leftCorner = Instance.new("UICorner")
leftCorner.CornerRadius = UDim.new(0, 8)
leftCorner.Parent = leftContainer

-- Texto "Inicio"
local homeName = Instance.new("TextLabel")
homeName.Name = "TeamName"
homeName.Size = UDim2.new(0.6, 0, 1, 0)
homeName.Position = UDim2.new(0.05, 0, 0, 0)
homeName.BackgroundTransparency = 1
homeName.Text = "Inicio"
homeName.TextColor3 = Color3.fromRGB(255, 255, 255)
homeName.TextStrokeTransparency = 0 -- Borde negro
homeName.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
homeName.TextXAlignment = Enum.TextXAlignment.Left
homeName.TextSize = 24 -- Ajustado
homeName.Font = Enum.Font.GothamBlack
homeName.Parent = leftContainer

-- Marcador Home
local homeScoreLabel = Instance.new("TextLabel")
homeScoreLabel.Name = "Score"
homeScoreLabel.Size = UDim2.new(0.3, 0, 1, 0)
homeScoreLabel.Position = UDim2.new(0.65, 0, 0, 0)
homeScoreLabel.BackgroundTransparency = 1
homeScoreLabel.Text = "0"
homeScoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
homeScoreLabel.TextStrokeTransparency = 0
homeScoreLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
homeScoreLabel.TextSize = 48 -- Ajustado
homeScoreLabel.Font = Enum.Font.GothamBold
homeScoreLabel.Parent = leftContainer

-- ⬜ LADO DERECHO (LEJOS - AWAY - BLANCO)
local rightContainer = Instance.new("Frame")
rightContainer.Name = "RightContainer"
rightContainer.Size = UDim2.new(0.5, 0, 1, 0)
rightContainer.Position = UDim2.new(0.5, 0, 0, 0)
rightContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Blanco puro
rightContainer.BorderSizePixel = 0
rightContainer.Parent = mainFrame

-- Decoración
local rightCorner = Instance.new("UICorner")
rightCorner.CornerRadius = UDim.new(0, 8)
rightCorner.Parent = rightContainer

-- Texto "Lejos"
local awayName = Instance.new("TextLabel")
awayName.Name = "TeamName"
awayName.Size = UDim2.new(0.6, 0, 1, 0)
awayName.Position = UDim2.new(0.35, 0, 0, 0)
awayName.BackgroundTransparency = 1
awayName.Text = "Lejos"
awayName.TextColor3 = Color3.fromRGB(255, 255, 255) -- Blanco
awayName.TextStrokeTransparency = 0 -- Borde negro
awayName.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
awayName.TextXAlignment = Enum.TextXAlignment.Right
awayName.TextSize = 24 -- Ajustado
awayName.Font = Enum.Font.GothamBlack
awayName.Parent = rightContainer

-- Marcador Away
local awayScoreLabel = Instance.new("TextLabel")
awayScoreLabel.Name = "Score"
awayScoreLabel.Size = UDim2.new(0.3, 0, 1, 0)
awayScoreLabel.Position = UDim2.new(0.05, 0, 0, 0)
awayScoreLabel.BackgroundTransparency = 1
awayScoreLabel.Text = "0"
awayScoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Blanco
awayScoreLabel.TextStrokeTransparency = 0 -- Borde negro
awayScoreLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
awayScoreLabel.TextSize = 48 -- Ajustado
awayScoreLabel.Font = Enum.Font.GothamBold
awayScoreLabel.Parent = rightContainer

-- ⏱️ CENTRO (VS / TIEMPO)
local centerContainer = Instance.new("Frame")
centerContainer.Name = "CenterContainer"
centerContainer.Size = UDim2.new(0, 70, 1, 10) -- Ajustado
centerContainer.Position = UDim2.new(0.5, 0, -0.1, 0)
centerContainer.AnchorPoint = Vector2.new(0.5, 0)
centerContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Negro para resaltar
centerContainer.BorderSizePixel = 0
centerContainer.Rotation = 10
centerContainer.Visible = false 
centerContainer.Parent = mainFrame

-- Texto Central (VS)
local vsLabel = Instance.new("TextLabel")
vsLabel.Name = "VSLabel"
vsLabel.Size = UDim2.new(0, 60, 1, 0)
vsLabel.Position = UDim2.new(0.5, 0, 0, 0)
vsLabel.AnchorPoint = Vector2.new(0.5, 0)
vsLabel.BackgroundTransparency = 1
vsLabel.Text = "VS"
vsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
vsLabel.TextSize = 32 -- Ajustado
vsLabel.Font = Enum.Font.GothamBlack
vsLabel.TextStrokeTransparency = 0
vsLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
vsLabel.Parent = mainFrame

-- Tiempo
local timeLabel = Instance.new("TextLabel")
timeLabel.Name = "TimeLabel"
timeLabel.Size = UDim2.new(1, 0, 0.4, 0)
timeLabel.Position = UDim2.new(0, 0, 0.85, 0) -- Ajustado
timeLabel.BackgroundTransparency = 1
timeLabel.Text = "00:00"
timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timeLabel.TextStrokeTransparency = 0
timeLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
timeLabel.TextSize = 24 -- Ajustado
timeLabel.Font = Enum.Font.GothamBold
timeLabel.Parent = mainFrame

-- 🔄 FUNCIONES
local function formatTime(seconds)
	local minutes = math.floor(seconds / 60)
	local remainingSeconds = seconds % 60
	return string.format("%02d:%02d", minutes, remainingSeconds)
end

local function updateStatus()
	-- Podríamos cambiar colores o textos según el estado, pero por ahora mantenemos el diseño fijo
	local state = GameState.Value
	if state == "Intermission" then
		timeLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
	else
		timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
end

local function updateScore()
	homeScoreLabel.Text = tostring(HomeScore.Value)
	awayScoreLabel.Text = tostring(AwayScore.Value)
end

-- 📡 CONEXIONES
TimeRemaining.Changed:Connect(function(newTime)
	timeLabel.Text = formatTime(newTime)
	if newTime <= 10 and GameState.Value == "Playing" then
		timeLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
	end
end)

GameState.Changed:Connect(updateStatus)
HomeScore.Changed:Connect(updateScore)
AwayScore.Changed:Connect(updateScore)

-- Inicializar
updateStatus()
updateScore()
timeLabel.Text = formatTime(TimeRemaining.Value)
