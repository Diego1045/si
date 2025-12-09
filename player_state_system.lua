local Players = game:GetService("Players")

-- 🎯 Sistema de Estados del Jugador
local PlayerStateSystem = {}

-- Estados posibles
PlayerStateSystem.States = {
	BALL = "Ball",        -- Cuando tiene el balón siguiéndole
	NO_BALL = "No Ball",  -- Cuando no tiene el balón
	BARRIDA = "Barrida"   -- Cuando está ejecutando una barrida
}

-- Tabla para rastrear el estado actual de cada jugador
local playerStates = {}

-- Tabla para almacenar callbacks cuando cambia el estado
local stateChangeCallbacks = {}

-- ✅ Obtiene el estado actual de un jugador
function PlayerStateSystem.GetPlayerState(player)
	if not player or not player.UserId then
		warn("[PlayerStateSystem] Jugador no válido")
		return PlayerStateSystem.States.NO_BALL
	end

	local state = playerStates[player.UserId]

	if not state then
		local attributeState = player:GetAttribute("PlayerState")
		if typeof(attributeState) == "string" then
			state = attributeState
		end
	end

	if not state then
		state = PlayerStateSystem.States.NO_BALL
	end

	return state
end

-- ✅ Establece el estado de un jugador
function PlayerStateSystem.SetPlayerState(player, newState)
	if not player or not player.UserId then
		warn("[PlayerStateSystem] Jugador no válido")
		return false
	end
	
	-- Validar que el estado sea válido
	local validState = false
	for _, state in pairs(PlayerStateSystem.States) do
		if newState == state then
			validState = true
			break
		end
	end
	
	if not validState then
		warn("[PlayerStateSystem] Estado inválido:", newState)
		return false
	end
	
	-- 🎯 REGLA: Solo un jugador puede estar en estado "Ball"
	if newState == PlayerStateSystem.States.BALL then
		-- Buscar si ya hay otro jugador con el balón
		for userId, currentState in pairs(playerStates) do
			if currentState == PlayerStateSystem.States.BALL and userId ~= player.UserId then
				local otherPlayer = Players:GetPlayerByUserId(userId)
				if otherPlayer then
					print("[PlayerStateSystem] 🚫 Solo un jugador puede tener el balón. Ya lo tiene:", otherPlayer.Name)
					return false
				end
			end
		end
	end
	
	local oldState = playerStates[player.UserId]
	playerStates[player.UserId] = newState
	player:SetAttribute("PlayerState", newState)
	
	-- Solo notificar si el estado realmente cambió
	if oldState ~= newState then
		print("[PlayerStateSystem] 🎯", player.Name, "cambió de estado:", oldState or "No Ball", "→", newState)
		
		-- Ejecutar callbacks de cambio de estado
		for _, callback in ipairs(stateChangeCallbacks) do
			task.spawn(function()
				callback(player, newState, oldState)
			end)
		end
	end
	
	return true
end

-- ✅ Verifica si un jugador tiene el balón
function PlayerStateSystem.HasBall(player)
	return PlayerStateSystem.GetPlayerState(player) == PlayerStateSystem.States.BALL
end

-- ✅ Verifica si un jugador NO tiene el balón
function PlayerStateSystem.HasNoBall(player)
	return PlayerStateSystem.GetPlayerState(player) == PlayerStateSystem.States.NO_BALL
end

-- ✅ Verifica si un jugador está en estado de barrida
function PlayerStateSystem.IsInBarrida(player)
	return PlayerStateSystem.GetPlayerState(player) == PlayerStateSystem.States.BARRIDA
end

-- ✅ Obtiene el jugador que actualmente tiene el balón
function PlayerStateSystem.GetBallOwner()
	for userId, state in pairs(playerStates) do
		if state == PlayerStateSystem.States.BALL then
			return Players:GetPlayerByUserId(userId)
		end
	end
	return nil
end

-- ✅ Suscribe una función para ser llamada cuando cambie el estado de cualquier jugador
function PlayerStateSystem.OnStateChange(callback)
	if type(callback) == "function" then
		table.insert(stateChangeCallbacks, callback)
		print("[PlayerStateSystem] ✅ Callback de cambio de estado registrado")
	else
		warn("[PlayerStateSystem] El callback debe ser una función")
	end
end

-- ✅ Limpia el estado de un jugador cuando se va
function PlayerStateSystem.CleanupPlayer(player)
	if player and player.UserId then
		playerStates[player.UserId] = nil
		print("[PlayerStateSystem] 🧹 Estado limpiado para", player.Name)
	end
end

-- ✅ Obtiene información del estado de todos los jugadores
function PlayerStateSystem.GetAllPlayerStates()
	local states = {}
	for _, player in Players:GetPlayers() do
		states[player.UserId] = {
			player = player,
			state = PlayerStateSystem.GetPlayerState(player)
		}
	end
	return states
end

-- ✅ Configura el sistema automáticamente
function PlayerStateSystem.Initialize()
	-- Limpiar estados cuando un jugador se va
	Players.PlayerRemoving:Connect(function(player)
		PlayerStateSystem.CleanupPlayer(player)
	end)
	
	print("[PlayerStateSystem] ✅ Sistema de estados inicializado")
end

-- Inicializar automáticamente
PlayerStateSystem.Initialize()

return PlayerStateSystem
