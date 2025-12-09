local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local moneyUpdateEvent = ReplicatedStorage:WaitForChild("MoneyUpdateEvent")

local getMoneyFunction = ReplicatedStorage:WaitForChild("GetMoneyFunction")

local UPDATE_ANIMATION_TIME = 0.3
local POSITION_OFFSET = UDim2.new(0, 20, 0, 20)

local currentMoney = 0

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoneySystemGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local moneyFrame = Instance.new("Frame")
moneyFrame.Name = "MoneyFrame"
moneyFrame.Size = UDim2.new(0, 200, 0, 60)
moneyFrame.Position = UDim2.new(1, -220, 0, 20)
moneyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
moneyFrame.BackgroundTransparency = 0.2
moneyFrame.BorderSizePixel = 0
moneyFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = moneyFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 215, 0)
stroke.Thickness = 2
stroke.Transparency = 0.5
stroke.Parent = moneyFrame

local iconLabel = Instance.new("TextLabel")
iconLabel.Name = "IconLabel"
iconLabel.Size = UDim2.new(0, 50, 0, 50)
iconLabel.Position = UDim2.new(0, 10, 0.5, 0)
iconLabel.AnchorPoint = Vector2.new(0, 0.5)
iconLabel.BackgroundTransparency = 1
iconLabel.Text = "💰"
iconLabel.TextSize = 36
iconLabel.Font = Enum.Font.GothamBold
iconLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
iconLabel.Parent = moneyFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(0, 100, 0, 20)
titleLabel.Position = UDim2.new(0, 65, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "DINERO"
titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = moneyFrame

local moneyLabel = Instance.new("TextLabel")
moneyLabel.Name = "MoneyLabel"
moneyLabel.Size = UDim2.new(0, 130, 0, 35)
moneyLabel.Position = UDim2.new(0, 65, 0, 20)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Text = "$0"
moneyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
moneyLabel.TextSize = 28
moneyLabel.Font = Enum.Font.GothamBold
moneyLabel.TextXAlignment = Enum.TextXAlignment.Left
moneyLabel.TextStrokeTransparency = 0.5
moneyLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
moneyLabel.Parent = moneyFrame

local function formatMoney(amount)
	local formatted = tostring(amount)
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

local function updateMoney(newAmount)
	if newAmount == currentMoney then
		return
	end
	
	local oldAmount = currentMoney
	currentMoney = newAmount
	
	local formattedMoney = formatMoney(newAmount)
	moneyLabel.Text = "$" .. formattedMoney
	
	if newAmount > oldAmount then
		local greenTween = TweenService:Create(
			moneyLabel,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{TextColor3 = Color3.fromRGB(76, 175, 80)}
		)
		greenTween:Play()
		
		greenTween.Completed:Wait()
		
		local normalTween = TweenService:Create(
			moneyLabel,
			TweenInfo.new(UPDATE_ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{TextColor3 = Color3.fromRGB(255, 255, 255)}
		)
		normalTween:Play()
		
	elseif newAmount < oldAmount then
		local redTween = TweenService:Create(
			moneyLabel,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{TextColor3 = Color3.fromRGB(244, 67, 54)}
		)
		redTween:Play()
		
		redTween.Completed:Wait()
		
		local normalTween = TweenService:Create(
			moneyLabel,
			TweenInfo.new(UPDATE_ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{TextColor3 = Color3.fromRGB(255, 255, 255)}
		)
		normalTween:Play()
	end
	
	moneyLabel.Size = UDim2.new(0, 140, 0, 38)
	local scaleTween = TweenService:Create(
		moneyLabel,
		TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = UDim2.new(0, 130, 0, 35)}
	)
	scaleTween:Play()
end

local function requestInitialMoney()
	local success, money = pcall(function()
		return getMoneyFunction:InvokeServer()
	end)
	
	if success and money then
		updateMoney(money)
	end
end

moneyUpdateEvent.OnClientEvent:Connect(function(amount)
	if amount and type(amount) == "number" then
		updateMoney(amount)
	end
end)

task.wait(1)
requestInitialMoney()

local leaderstats = player:WaitForChild("leaderstats", 10)
if leaderstats then
	local moneyValue = leaderstats:WaitForChild("Dinero", 5)
	if moneyValue then
		updateMoney(moneyValue.Value)
		
		moneyValue:GetPropertyChangedSignal("Value"):Connect(function()
			updateMoney(moneyValue.Value)
		end)
	end
end

print("[MoneySystem] Cliente iniciado - Sistema de dinero listo")
