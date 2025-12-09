-- 🛡️ Slide Tackle (Barrida) - ServerScript
-- Ubicación recomendada: ServerScriptService
-- Aplica validaciones y física sobre el balón cuando un cliente solicita una barrida

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvent compartido
local SlideTackle = ReplicatedStorage:FindFirstChild("SlideTackle")
if not SlideTackle then
	SlideTackle = Instance.new("RemoteEvent")
	SlideTackle.Name = "SlideTackle"
	SlideTackle.Parent = ReplicatedStorage
end

-- Parámetros de juego (ajustables)
local SLIDE_COOLDOWN = 1.2       -- s
local MAX_REACH = 6              -- distancia máx. de impacto
local MAX_ANGLE_DOT = 0.4        -- orientación mínima hacia delante
local BALL_IMPULSE = 80          -- impulso horizontal
local BALL_UP = 6                -- impulso vertical leve
local NO_COLLIDE_TIME = 0.25     -- s sin colisión tras impacto

local lastSlideByUser = {} -- userId -> timestamp

local function getBall()
	return workspace:FindFirstChild("Ball")
end

local function getRoot(character: Model)
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function detachIfWelded(ball: BasePart)
	-- Si el balón tiene un Motor6D, lo destruimos (sueltas posesión)
	local motor = ball:FindFirstChildWhichIsA("Motor6D")
	if motor then
		motor:Destroy()
	end
	-- Limpiar atributos de posesión si algún jugador tiene el balón como hijo
	for _, plr in ipairs(Players:GetPlayers()) do
		local ok, _ = pcall(function()
			if plr.Character and plr.Character:IsAncestorOf(ball) then
				plr:SetAttribute("hasBall", false)
				plr:SetAttribute("HasBall", false)
			end
		end)
	end
	-- Asegurar flags del balón
	ball.Massless = false
	ball.CanTouch = true
	ball.CanCollide = true
	ball:SetNetworkOwner(nil)
end

SlideTackle.OnServerEvent:Connect(function(player: Player, dir: Vector3)
	if typeof(dir) ~= "Vector3" then return end

	local now = os.clock()
	if lastSlideByUser[player.UserId] and now - lastSlideByUser[player.UserId] < SLIDE_COOLDOWN then
		return
	end
	lastSlideByUser[player.UserId] = now

	local character = player.Character
	local root = getRoot(character)
	local ball = getBall()
	if not (character and root and ball) then return end

	-- Validar orientación (frente del jugador)
	local forward = root.CFrame.LookVector
	local dirFlat = Vector3.new(dir.X, 0, dir.Z)
	if dirFlat.Magnitude < 0.01 then return end
	dirFlat = dirFlat.Unit
	if forward:Dot(dirFlat) < MAX_ANGLE_DOT then return end

	-- Validar distancia
	local dist = (ball.Position - root.Position).Magnitude
	if dist > MAX_REACH then return end

	-- Si está soldado a un jugador, soltar
	detachIfWelded(ball)

	-- Ventana de no colisión con el jugador que barre
	ball.CanCollide = false
	ball.CanTouch = false

	-- Aplicar impulso rasante
	local velocity = (dirFlat * BALL_IMPULSE) + Vector3.new(0, BALL_UP, 0)
	ball.AssemblyLinearVelocity = velocity

	-- Rehabilitar colisión
	task.delay(NO_COLLIDE_TIME, function()
		if ball and ball.Parent then
			ball.CanCollide = true
			ball.CanTouch = true
		end
	end)
end)


