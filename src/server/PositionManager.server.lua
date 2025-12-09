local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ⚡ Crear RemoteEvents/RemoteFunctions inmediatamente para evitar "Infinite yield"
-- Estos deben existir antes de que los scripts del cliente intenten acceder a ellos
local RequestPosition = ReplicatedStorage:FindFirstChild("RequestPosition")
if not RequestPosition then
	RequestPosition = Instance.new("RemoteFunction")
	RequestPosition.Name = "RequestPosition"
	RequestPosition.Parent = ReplicatedStorage
	print("[PositionManager] ✅ RequestPosition creado en ReplicatedStorage")
else
	print("[PositionManager] ✅ RequestPosition ya existe en ReplicatedStorage")
end

local ReleasePosition = ReplicatedStorage:FindFirstChild("ReleasePosition")
if not ReleasePosition then
	ReleasePosition = Instance.new("RemoteEvent")
	ReleasePosition.Name = "ReleasePosition"
	ReleasePosition.Parent = ReplicatedStorage
	print("[PositionManager] ✅ ReleasePosition creado en ReplicatedStorage")
else
	print("[PositionManager] ✅ ReleasePosition ya existe en ReplicatedStorage")
end

-- RemoteEvent para notificar cambios de posición a los clientes (para actualizar GUI)
local PositionChanged = ReplicatedStorage:FindFirstChild("PositionChanged")
if not PositionChanged then
	PositionChanged = Instance.new("RemoteEvent")
	PositionChanged.Name = "PositionChanged"
	PositionChanged.Parent = ReplicatedStorage
	print("[PositionManager] ✅ PositionChanged creado en ReplicatedStorage")
else
	print("[PositionManager] ✅ PositionChanged ya existe en ReplicatedStorage")
end

local positionTargets = {
	CF_white = "CF_White.R",
	RW_white = "RW_White.R",
	LW_white = "LW_White.R",
	CM_white = "CM_White.R",
	GK_white = "GK_White.R",
}

local normalizedKeyMap = {}
for key in pairs(positionTargets) do
	normalizedKeyMap[string.lower(key)] = key
end

local occupied = {}

-- 📢 Notificar a todos los clientes sobre cambios de posición
local function notifyPositionChanged(positionKey, player, isOccupied)
	if not PositionChanged then
		return
	end
	
	local playerData = nil
	if isOccupied and player then
		playerData = {
			userId = player.UserId,
			username = player.Name
		}
	end
	
	-- Enviar a todos los clientes: posición, datos del jugador (o nil si se liberó)
	PositionChanged:FireAllClients(positionKey, playerData)
end

local function releasePlayerPosition(player)
	local currentKey = player:GetAttribute("SelectedPosition")
	if currentKey and occupied[currentKey] == player then
		occupied[currentKey] = nil
		
		-- Notificar a los clientes que la posición se liberó
		notifyPositionChanged(currentKey, nil, false)
	end
	player:SetAttribute("SelectedPosition", nil)
end

local function getCanonicalKey(buttonName)
	if typeof(buttonName) ~= "string" then
		return nil
	end

	local trimmed = buttonName:gsub("^%s+", ""):gsub("%s+$", "")
	if trimmed == "" then
		return nil
	end

	if positionTargets[trimmed] then
		return trimmed
	end

	local lower = string.lower(trimmed)
	return normalizedKeyMap[lower]
end

local function getTargetPart(name)
	if not name then
		return nil
	end
	return workspace:FindFirstChild(name, true)
end

RequestPosition.OnServerInvoke = function(player, buttonName)
	local canonicalKey = getCanonicalKey(buttonName)
	if not canonicalKey then
		return false, "Posición desconocida"
	end

	local targetName = positionTargets[canonicalKey]
	if not targetName then
		return false, "Posición desconocida"
	end

	local targetPart = getTargetPart(targetName)
	if not targetPart then
		return false, "No se encontró la parte destino"
	end

	local currentOccupant = occupied[canonicalKey]
	if currentOccupant and currentOccupant ~= player then
		return false, "Esa posición está ocupada"
	end

	-- Liberar la posición anterior del jugador si tenía otra asignada
	releasePlayerPosition(player)

	occupied[canonicalKey] = player
	player:SetAttribute("SelectedPosition", canonicalKey)
	
	-- Notificar a todos los clientes que la posición está ocupada
	notifyPositionChanged(canonicalKey, player, true)

	-- 🔒 LÓGICA DE TELETRANSPORTE
	-- Si está jugando, devolver CFrame para teleport inmediato (cliente)
	-- Si es Intermission, devolver "Reservado" (no teleport)
	local gameState = ReplicatedStorage:FindFirstChild("GameState")
	local currentState = gameState and gameState.Value or "Nil"
	
	print(string.format("[PositionManager] Solicitud de %s para %s. Estado actual: %s", player.Name, canonicalKey, currentState))

	if currentState == "Playing" then
		-- Cambiar al equipo "Sub-20"
		local sub20Team = Teams:FindFirstChild("Sub-20")
		if sub20Team then
			player.Team = sub20Team
			print(string.format("[PositionManager] ✅ %s cambiado al equipo Sub-20", player.Name))
		else
			warn("[PositionManager] ⚠️ No se encontró el equipo 'Sub-20'")
		end
		return true, targetPart.CFrame
	else
		return true, "Reservado"
	end
end

-- 🚀 TELETRANSPORTAR AL INICIAR EL PARTIDO
-- Usamos WaitForChild para asegurar que esperamos a que GameManager cree el valor
local GameState = ReplicatedStorage:WaitForChild("GameState")
GameState.Changed:Connect(function(newState)
		print(string.format("[PositionManager] 🔄 Cambio de estado detectado: %s", tostring(newState)))
		
		if newState == "Playing" then
			print("[PositionManager] 🎮 Iniciando partido - Intentando teletransportar jugadores...")
			local count = 0
			for key, player in pairs(occupied) do
				count = count + 1
				print(string.format("[PositionManager] 🔍 Procesando jugador %s en posición %s", player.Name, key))
				
				if player and player.Character then
					local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
					local targetName = positionTargets[key]
					local targetPart = getTargetPart(targetName)
					
					if rootPart and targetPart then
						rootPart.CFrame = targetPart.CFrame
						
						-- Cambiar al equipo "Sub-20"
						local sub20Team = Teams:FindFirstChild("Sub-20")
						if sub20Team then
							player.Team = sub20Team
							print(string.format("[PositionManager] ✅ %s cambiado al equipo Sub-20", player.Name))
						else
							warn("[PositionManager] ⚠️ No se encontró el equipo 'Sub-20'")
						end
						
						print(string.format("[PositionManager] 🚀 Teletransportando %s a %s", player.Name, key))
					else
						warn(string.format("[PositionManager] ⚠️ No se pudo teleportar a %s. RootPart: %s, TargetPart: %s (%s)", 
							player.Name, 
							tostring(rootPart), 
							tostring(targetPart), 
							tostring(targetName)))
					end
				else
					warn(string.format("[PositionManager] ⚠️ Jugador %s no tiene personaje o salió", player.Name))
				end
			end
			print(string.format("[PositionManager] 🏁 Fin del proceso de teleport. Total procesados: %d", count))
	elseif newState == "Intermission" then
		print("[PositionManager] 🛑 Fin del partido - Reseteando jugadores y posiciones")
		
		-- 1. Respawnear a todos los jugadores que estaban jugando
		for key, player in pairs(occupied) do
			if player then
				-- Resetear atributo
				player:SetAttribute("SelectedPosition", nil)
				
				-- Respawnear (los envía al SpawnLocation del Lobby)
				player:LoadCharacter()
			end
		end
		
		-- 2. Limpiar tabla de ocupados
		occupied = {}
		
		-- 3. Notificar a todos los clientes que TODAS las posiciones están libres
		for key, _ in pairs(positionTargets) do
			notifyPositionChanged(key, nil, false)
		end
	end
end)
-- end (Eliminado porque ya no usamos el if GameState then)

ReleasePosition.OnServerEvent:Connect(function(player)
	releasePlayerPosition(player)
end)

Players.PlayerRemoving:Connect(function(player)
	releasePlayerPosition(player)
end)

Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("SelectedPosition", nil)
	
	-- Sincronizar estado de posiciones ocupadas con el nuevo jugador
	task.wait(1) -- Esperar a que el cliente esté listo
	for positionKey, occupant in pairs(occupied) do
		if occupant and occupant.Parent then
			notifyPositionChanged(positionKey, occupant, true)
		end
	end
end)
