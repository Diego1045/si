local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- ⚙️ CONFIGURACIÓN
local DEBOUNCE_TIME = 2 -- Segundos de espera entre goles (Cooldown solicitado)
local BALL_NAME = "Ball" -- Nombre exacto del balón en el Workspace
local GOAL_HOME_NAME = "GoalDetector_Home" -- Nombre del detector del equipo HOME (Azul)
local GOAL_AWAY_NAME = "GoalDetector_Away" -- Nombre del detector del equipo AWAY (Blanco/Rojo)

-- 📂 VARIABLES
local HomeScore = ReplicatedStorage:WaitForChild("HomeScore")
local AwayScore = ReplicatedStorage:WaitForChild("AwayScore")
local GameState = ReplicatedStorage:WaitForChild("GameState")

-- Evento de Celebración
local GoalCelebration = ReplicatedStorage:FindFirstChild("GoalCelebration")
if not GoalCelebration then
	GoalCelebration = Instance.new("RemoteEvent")
	GoalCelebration.Name = "GoalCelebration"
	GoalCelebration.Parent = ReplicatedStorage
end

-- Variables de control
local isGoalProcessing = false
local lastTouchPlayer = nil -- Rastrear quién tocó el balón por última vez

-- 🔍 BUSCAR PARTES
local ball = Workspace:FindFirstChild(BALL_NAME)
local goalHome = Workspace:FindFirstChild(GOAL_HOME_NAME)
local goalAway = Workspace:FindFirstChild(GOAL_AWAY_NAME)

-- Si no encuentra las partes al inicio, espera un poco o advierte
if not ball then warn("[GoalManager] ⚠️ No se encontró el balón: " .. BALL_NAME) end
if not goalHome then warn("[GoalManager] ⚠️ No se encontró el detector Home: " .. GOAL_HOME_NAME) end
if not goalAway then warn("[GoalManager] ⚠️ No se encontró el detector Away: " .. GOAL_AWAY_NAME) end

-- 🦶 FUNCIÓN: RASTREAR TOQUES DE BALÓN
local function setupBallTracking(ballPart)
	if not ballPart then return end
	
	ballPart.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		
		if player then
			lastTouchPlayer = player
			print("[DEBUG] Toque detectado por: " .. player.Name) -- DEBUG
		end
	end)
end

-- Configurar balón inicial
if ball then 
	print("[DEBUG] Configurando tracking para balón inicial") -- DEBUG
	setupBallTracking(ball) 
else
	warn("[DEBUG] No se encontró balón al inicio para tracking")
end

-- ⚽ FUNCIÓN: PROCESAR GOL
local function onGoal(scoringTeam)
	print("[DEBUG] onGoal llamado para equipo: " .. tostring(scoringTeam)) -- DEBUG
	if isGoalProcessing then return end 
	if GameState.Value ~= "Playing" then 
		print("[DEBUG] Gol ignorado porque GameState es: " .. tostring(GameState.Value)) -- DEBUG
		return 
	end 
	
	isGoalProcessing = true
	
	print(string.format("[GoalManager] 🥅 ¡GOL de %s!", scoringTeam))
	
	-- 1. Actualizar Marcador
	if scoringTeam == "Home" then
		HomeScore.Value = HomeScore.Value + 1
	elseif scoringTeam == "Away" then
		AwayScore.Value = AwayScore.Value + 1
	end
	
	-- 2. Disparar Celebración (Cámara al jugador)
	if lastTouchPlayer then
		print("[GoalManager] 🎉 Intentando disparar evento para: " .. lastTouchPlayer.Name)
		GoalCelebration:FireAllClients(lastTouchPlayer, DEBOUNCE_TIME)
	else
		print("[GoalManager] 🎉 Gol sin jugador detectado (lastTouchPlayer es nil)")
	end
	
	-- 3. Verificar Regla de Diferencia de 5 Goles (Mercy Rule)
	local scoreDiff = math.abs(HomeScore.Value - AwayScore.Value)
	if scoreDiff >= 5 then
		print("[GoalManager] 🏆 Diferencia de 5 goles alcanzada. Terminando partido por Mercy Rule.")
		
		-- Esperar un momento para ver el gol
		task.wait(2)
		
		-- Terminar el partido
		GameState.Value = "Intermission"
		
		-- Resetear variables locales
		isGoalProcessing = false
		return -- Salir, no reseteamos balón porque el juego se reinicia
	end
	
	-- 4. Celebración y Cooldown
	task.wait(DEBOUNCE_TIME)
	
	-- ⚠️ NOTA: El reset del balón se maneja en GoalDetector.server.lua
	-- No resetear aquí para evitar doble teletransportación
	
	isGoalProcessing = false
end

-- 📡 CONECTAR EVENTOS
local function setupDetector(detectorPart, scoringTeam)
	if not detectorPart then return end
	
	detectorPart.Touched:Connect(function(hit)
		if hit.Name == BALL_NAME then
			onGoal(scoringTeam)
		end
	end)
end

-- Inicializar detectores si existen
if goalHome then setupDetector(goalHome, "Away") end -- Si entra en portería Home, gol de Away
if goalAway then setupDetector(goalAway, "Home") end -- Si entra en portería Away, gol de Home

-- Re-buscar balón si se destruye y reaparece (opcional)
Workspace.ChildAdded:Connect(function(child)
	if child.Name == BALL_NAME then
		ball = child
		setupBallTracking(ball) -- Reconectar tracking
	elseif child.Name == GOAL_HOME_NAME then
		goalHome = child
		setupDetector(goalHome, "Away")
	elseif child.Name == GOAL_AWAY_NAME then
		goalAway = child
		setupDetector(goalAway, "Home")
	end
end)

print("[GoalManager] ✅ Sistema de goles cargado")
