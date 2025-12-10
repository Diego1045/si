local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local BALL_NAME = "Ball"
-- Nombres de las partes que actúan como detectores de gol
local GOAL_HOME_NAME = "GoalDetector_Home" -- Portería del equipo Local (Blue Lock)
local GOAL_AWAY_NAME = "GoalDetector_Away" -- Portería del equipo Visitante (Sub-20)

local ball = workspace:WaitForChild(BALL_NAME)

-- Valores de puntuación (gestionados por GameManager, pero leídos/escritos aquí)
local HomeScore = ReplicatedStorage:WaitForChild("HomeScore")
local AwayScore = ReplicatedStorage:WaitForChild("AwayScore")
local GameState = ReplicatedStorage:WaitForChild("GameState")
local GoalScoredEvent = ReplicatedStorage:FindFirstChild("GoalScored") 
if not GoalScoredEvent then
	GoalScoredEvent = Instance.new("RemoteEvent")
	GoalScoredEvent.Name = "GoalScored"
	GoalScoredEvent.Parent = ReplicatedStorage
end

-- Buscar detectores
local goalHome = workspace:FindFirstChild(GOAL_HOME_NAME)
local goalAway = workspace:FindFirstChild(GOAL_AWAY_NAME)

if not goalHome or not goalAway then
	warn("[GoalDetector] ⚠️ Faltan los detectores de gol: " .. GOAL_HOME_NAME .. " o " .. GOAL_AWAY_NAME)
	-- No detenemos el script, pero no funcionará bien hasta que existan las partes
end

local cooldown = false
local COOLDOWN_TIME = 5 -- Segundos de cooldown entre goles
local resetPosition = ball:IsA("BasePart") and ball.CFrame or CFrame.new(0, 5, 0)

-- Inicializar GoalDetected al inicio (para que GoalManager pueda escucharlo)
-- 🔒 CRÍTICO: Solo GoalDetector crea este objeto para evitar duplicados
local GoalDetected = ReplicatedStorage:FindFirstChild("GoalDetected")
if not GoalDetected then
	GoalDetected = Instance.new("StringValue")
	GoalDetected.Name = "GoalDetected"
	GoalDetected.Value = ""
	GoalDetected.Parent = ReplicatedStorage
	print("[GoalDetector] ✅ GoalDetected creado en ReplicatedStorage")
else
	print("[GoalDetector] ✅ GoalDetected ya existe (reutilizando instancia existente)")
end

local function isBallInside(part)
	if not part or not (ball and ball.Parent) then return false end

	local ballPart = ball:IsA("BasePart") and ball or ball:FindFirstChildWhichIsA("BasePart", true)
	if not ballPart then return false end

	local localPos = part.CFrame:PointToObjectSpace(ballPart.Position)
	local halfSize = part.Size * 0.5
	local ballRadius = ballPart.Size.Magnitude / 2

	return math.abs(localPos.X) <= halfSize.X + ballRadius
		and math.abs(localPos.Y) <= halfSize.Y + ballRadius
		and math.abs(localPos.Z) <= halfSize.Z + ballRadius
end

local function handleGoal(teamScored)
	if cooldown then return end
	
	-- 🔒 BUG FIX: Verificar GameState antes de procesar el gol
	if GameState.Value ~= "Playing" then
		print("[GoalDetector] ⚠️ Gol ignorado - GameState no es 'Playing': " .. tostring(GameState.Value))
		return
	end
	
	cooldown = true
	
	print("⚽ ¡GOL de " .. teamScored .. "!")
	
	-- Actualizar marcador (solo aquí para evitar doble conteo)
	if teamScored == "Home" then
		HomeScore.Value += 1
	elseif teamScored == "Away" then
		AwayScore.Value += 1
	end
	
	-- Notificar clientes (para efectos, UI, etc.)
	GoalScoredEvent:FireAllClients(teamScored)
	
	-- Notificar a GoalManager mediante un valor compartido (para celebración)
	-- GoalDetected ya está inicializado al inicio del script
	GoalDetected.Value = teamScored -- Notificar equipo que marcó
	print("[GoalDetector] 📢 Notificando a GoalManager: " .. teamScored)
	
	-- Resetear balón
	local ballPart = ball:IsA("BasePart") and ball or ball:FindFirstChildWhichIsA("BasePart", true)
	if ballPart then
		task.wait(1) -- Pequeña pausa dramática
		ballPart.CFrame = resetPosition
		ballPart.AssemblyLinearVelocity = Vector3.zero
		ballPart.AssemblyAngularVelocity = Vector3.zero
		ballPart.CanCollide = true
	end
	
	task.delay(COOLDOWN_TIME, function()
		cooldown = false
		-- Limpiar notificación después del cooldown
		if GoalDetected then
			GoalDetected.Value = ""
		end
	end)
end

RunService.Heartbeat:Connect(function()
	if cooldown then return end

	if goalHome and isBallInside(goalHome) then
		-- Si entra en la portería Local, es gol del Visitante (asumiendo lados opuestos)
		-- OJO: Depende de tu lógica. Normalmente:
		-- Portería A (Lado A) -> Si entra balón, Gol de Equipo B.
		handleGoal("Away") 
	elseif goalAway and isBallInside(goalAway) then
		handleGoal("Home")
	end
end)

-- Actualizar posición de reset si el balón cambia (opcional, por si se destruye y recrea)
if ball:IsA("BasePart") then
	ball:GetPropertyChangedSignal("CFrame"):Connect(function()
		-- Podríamos guardar la posición inicial real aquí si quisiéramos
	end)
end
