-- 💬 Sistema de Mensajes en Pantalla (Cliente)
-- Muestra mensajes en pantalla cuando se recibe el comando /msg

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- RemoteEvent para recibir mensajes
local messageEvent = ReplicatedStorage:WaitForChild("ShowMessageScreen")

-- Configuración
local DISPLAY_TIME = 5 -- Segundos que se muestra el mensaje
local FADE_TIME = 0.5 -- Segundos de animación de fade in/out
local MAX_MESSAGE_LENGTH = 100 -- Longitud máxima del mensaje (se trunca si es muy largo)

-- Crear la GUI base (solo una vez)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MessageScreenGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Frame principal para el mensaje
local messageFrame = Instance.new("Frame")
messageFrame.Name = "MessageFrame"
messageFrame.Size = UDim2.new(0.7, 0, 0, 100)
messageFrame.Position = UDim2.new(0.15, 0, 0.1, 0)
messageFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
messageFrame.BackgroundTransparency = 0.3
messageFrame.BorderSizePixel = 0
messageFrame.Visible = false
messageFrame.Parent = screenGui

-- Agregar esquinas redondeadas (opcional, requiere UICorner)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = messageFrame

-- Texto del mensaje
local messageLabel = Instance.new("TextLabel")
messageLabel.Name = "MessageLabel"
messageLabel.Size = UDim2.new(0.95, 0, 0.9, 0)
messageLabel.Position = UDim2.new(0.025, 0, 0.05, 0)
messageLabel.BackgroundTransparency = 1
messageLabel.Text = ""
messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
messageLabel.TextSize = 24
messageLabel.TextWrapped = true
messageLabel.Font = Enum.Font.GothamBold
messageLabel.TextStrokeTransparency = 0.5
messageLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
messageLabel.Parent = messageFrame

-- Texto del autor (opcional)
local authorLabel = Instance.new("TextLabel")
authorLabel.Name = "AuthorLabel"
authorLabel.Size = UDim2.new(0.95, 0, 0, 20)
authorLabel.Position = UDim2.new(0.025, 0, 0.85, 0)
authorLabel.BackgroundTransparency = 1
authorLabel.Text = ""
authorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
authorLabel.TextSize = 14
authorLabel.Font = Enum.Font.Gotham
authorLabel.TextXAlignment = Enum.TextXAlignment.Right
authorLabel.Parent = messageFrame

-- Variable para controlar si hay un mensaje mostrándose
local currentMessageTask = nil
local currentTween = nil

-- Función para mostrar el mensaje (solo uno a la vez)
local function showMessage(messageText, authorName)
	-- Cancelar mensaje anterior si existe
	if currentMessageTask then
		task.cancel(currentMessageTask)
		currentMessageTask = nil
	end
	
	-- Detener animación anterior si existe
	if currentTween then
		currentTween:Cancel()
		currentTween = nil
	end
	
	-- Truncar mensaje si es muy largo
	if #messageText > MAX_MESSAGE_LENGTH then
		messageText = string.sub(messageText, 1, MAX_MESSAGE_LENGTH) .. "..."
	end
	
	-- Configurar los textos
	messageLabel.Text = messageText
	authorLabel.Text = authorName and ("- " .. authorName) or ""
	
	-- Hacer visible el frame
	messageFrame.Visible = true
	messageFrame.BackgroundTransparency = 0.7
	
	-- Animación de entrada (Fade In)
	local fadeIn = TweenService:Create(
		messageFrame,
		TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundTransparency = 0.3}
	)
	currentTween = fadeIn
	fadeIn:Play()
	
	-- Crear task para manejar el mensaje
	currentMessageTask = task.spawn(function()
		-- Esperar el tiempo de visualización
		task.wait(DISPLAY_TIME)
		
		-- Animación de salida (Fade Out)
		local fadeOut = TweenService:Create(
			messageFrame,
			TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{BackgroundTransparency = 1}
		)
		currentTween = fadeOut
		fadeOut:Play()
		
		fadeOut.Completed:Wait()
		messageFrame.Visible = false
		currentMessageTask = nil
		currentTween = nil
	end)
end

-- Escuchar los mensajes del servidor
messageEvent.OnClientEvent:Connect(function(messageText, authorName)
	showMessage(messageText, authorName)
end)

print("[MessageScreen] Cliente iniciado - Listo para mostrar mensajes")

