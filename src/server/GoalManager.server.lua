local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- ⚙️ CONFIGURACIÓN
local DEBOUNCE_TIME = 5 -- Segundos de espera entre goles (Cooldown solicitado)
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
local lastTouchPlayer = nil -- Rastrear quién tocó el balón por última vez
local lastProcessedGoal = "" -- Evitar procesar el mismo gol dos veces

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

-- ⚽ FUNCIÓN: PROCESAR GOL (Solo celebración, el marcador ya fue actualizado por GoalDetector)
local function onGoal(scoringTeam)
	-- Verificar GameState
	if GameState.Value ~= "Playing" then 
		print("[DEBUG] Gol ignorado porque GameState es: " .. tostring(GameState.Value)) -- DEBUG
		return 
	end 
	
	print(string.format("[GoalManager] 🎉 Procesando celebración para gol de %s", scoringTeam))
	
	-- 1. Disparar Celebración (Cámara al jugador)
	if lastTouchPlayer then
		print("[GoalManager] 🎉 Intentando disparar evento para: " .. lastTouchPlayer.Name)
		GoalCelebration:FireAllClients(lastTouchPlayer, DEBOUNCE_TIME)
	else
		print("[GoalManager] 🎉 Gol sin jugador detectado (lastTouchPlayer es nil)")
	end
	
	-- 2. Verificar Regla de Diferencia de 5 Goles (Mercy Rule)
	local scoreDiff = math.abs(HomeScore.Value - AwayScore.Value)
	if scoreDiff >= 5 then
		print("[GoalManager] 🏆 Diferencia de 5 goles alcanzada. Terminando partido por Mercy Rule.")
		
		-- Esperar un momento para ver el gol
		task.wait(2)
		
		-- Terminar el partido
		GameState.Value = "Intermission"
		return -- Salir, no reseteamos balón porque el juego se reinicia
	end
	
	-- ⚠️ NOTA: El reset del balón y el cooldown se manejan en GoalDetector.server.lua
	-- No necesitamos hacer nada más aquí
end

-- 📡 ESCUCHAR DETECCIÓN DE GOLES DESDE GoalDetector
-- Ya no detectamos goles aquí, solo escuchamos cuando GoalDetector detecta uno
-- 🔒 BUG FIX: Solo esperar GoalDetected, NO crearlo (GoalDetector es el único que lo crea)
local GoalDetected = ReplicatedStorage:WaitForChild("GoalDetected", 10) -- Esperar hasta 10 segundos
if not GoalDetected then
	warn("[GoalManager] ⚠️ GoalDetected no encontrado después de 10 segundos. GoalDetector puede no estar cargado.")
	return -- Salir si no existe para evitar errores
end

print("[GoalManager] ✅ Escuchando cambios en GoalDetected...")

-- Escuchar cuando GoalDetector detecta un gol
GoalDetected:GetPropertyChangedSignal("Value"):Connect(function()
	local scoringTeam = GoalDetected.Value
	print("[GoalManager] 📢 Cambio detectado en GoalDetected: " .. tostring(scoringTeam))
	
	-- Solo procesar si hay un equipo válido y no es el mismo gol que ya procesamos
	if scoringTeam and scoringTeam ~= "" and scoringTeam ~= lastProcessedGoal then
		lastProcessedGoal = scoringTeam
		print("[GoalManager] 🎯 Procesando gol de: " .. scoringTeam)
		-- GoalDetector ya actualizó el marcador, solo manejamos celebración
		onGoal(scoringTeam)
		
		-- Resetear después de un tiempo para permitir nuevos goles
		task.delay(DEBOUNCE_TIME + 1, function()
			if lastProcessedGoal == scoringTeam then
				lastProcessedGoal = ""
				print("[GoalManager] 🔄 Reset de lastProcessedGoal para permitir nuevos goles")
			end
		end)
	else
		print("[GoalManager] ⚠️ Gol ignorado - scoringTeam:", tostring(scoringTeam), "lastProcessedGoal:", lastProcessedGoal)
	end
end)

-- Re-buscar balón si se destruye y reaparece (opcional)
Workspace.ChildAdded:Connect(function(child)
	if child.Name == BALL_NAME then
		ball = child
		setupBallTracking(ball) -- Reconectar tracking
	end
	-- Los detectores se manejan en GoalDetector.server.lua, no aquí
end)

print("[GoalManager] ✅ Sistema de goles cargado")
