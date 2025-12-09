local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- ⚙️ CONFIGURACIÓN
local INTERMISSION_TIME = 10 -- Tiempo de espera en el lobby
local MATCH_TIME = 300       -- Duración del partido en segundos (5 minutos)

-- 📂 VARIABLES GLOBALES
local GameState = ReplicatedStorage:FindFirstChild("GameState")
if not GameState then
	GameState = Instance.new("StringValue")
	GameState.Name = "GameState"
	GameState.Parent = ReplicatedStorage
end

local TimeRemaining = ReplicatedStorage:FindFirstChild("TimeRemaining")
if not TimeRemaining then
	TimeRemaining = Instance.new("IntValue")
	TimeRemaining.Name = "TimeRemaining"
	TimeRemaining.Parent = ReplicatedStorage
end

-- ⚽ PUNTUACIÓN
local HomeScore = ReplicatedStorage:FindFirstChild("HomeScore")
if not HomeScore then
	HomeScore = Instance.new("IntValue")
	HomeScore.Name = "HomeScore"
	HomeScore.Parent = ReplicatedStorage
end

local AwayScore = ReplicatedStorage:FindFirstChild("AwayScore")
if not AwayScore then
	AwayScore = Instance.new("IntValue")
	AwayScore.Name = "AwayScore"
	AwayScore.Parent = ReplicatedStorage
end

-- 📢 FUNCIONES DE ESTADO
-- Declaración anticipada para evitar errores de "nil value" por recursión mutua
local startIntermission, startMatch

local function setGameState(newState)
	GameState.Value = newState
	print(string.format("[GameManager] 🔄 Estado cambiado a: %s", newState))
end

local function resetScores()
	HomeScore.Value = 0
	AwayScore.Value = 0
end

startIntermission = function()
	setGameState("Intermission")
	resetScores() -- Resetear marcador al iniciar intermission
	
	-- Cuenta regresiva de Intermission
	for i = INTERMISSION_TIME, 0, -1 do
		TimeRemaining.Value = i
		task.wait(1)
	end
	
	-- Al terminar intermission, iniciar partido
	startMatch()
end

startMatch = function()
	setGameState("Playing")
	
	-- Cuenta regresiva del Partido
	for i = MATCH_TIME, 0, -1 do
		-- Verificar si el estado cambió externamente (ej. gol de oro, fin forzado)
		if GameState.Value ~= "Playing" then
			break
		end
		
		TimeRemaining.Value = i
		task.wait(1)
	end
	
	-- Al terminar el tiempo, volver a intermission
	startIntermission()
end

-- 🚀 INICIO DEL LOOP
task.spawn(function()
	print("[GameManager] ⚽ Sistema iniciado")
	startIntermission()
end)
