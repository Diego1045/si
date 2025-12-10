-- 🎮 ScoreCommand.server.lua
-- Ubicación: ServerScriptService
-- Sistema de comandos para modificar puntajes

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- 📂 VARIABLES
local HomeScore = ReplicatedStorage:FindFirstChild("HomeScore") or ReplicatedStorage:WaitForChild("HomeScore", 10)
local AwayScore = ReplicatedStorage:FindFirstChild("AwayScore") or ReplicatedStorage:WaitForChild("AwayScore", 10)

-- Verificar que las variables existan
if not HomeScore or not AwayScore then
	warn("[ScoreCommand] ⚠️ No se encontraron HomeScore o AwayScore. El script puede no funcionar correctamente.")
end

-- 📋 IMPORTAR LISTA DE ADMINISTRADORES
-- Buscar el ModuleScript AdminList (puede estar en ReplicatedStorage o ServerStorage)
local ServerStorage = game:GetService("ServerStorage")
local AdminListModule = ReplicatedStorage:FindFirstChild("AdminList") or ServerStorage:FindFirstChild("AdminList")

local ADMIN_USERNAMES = {}
if AdminListModule then
	local AdminList = require(AdminListModule)
	ADMIN_USERNAMES = AdminList.ADMIN_USERNAMES or {}
	print("[ScoreCommand] ✅ Lista de administradores cargada desde AdminList")
else
	warn("[ScoreCommand] ⚠️ No se encontró AdminList ModuleScript. Creando lista vacía.")
	warn("[ScoreCommand] 💡 Crea un ModuleScript llamado 'AdminList' en ReplicatedStorage o ServerStorage")
end

-- Función para verificar si un jugador es administrador
local function isAdmin(player)
	-- Verificar si el nombre está en la lista de administradores
	for _, adminName in ipairs(ADMIN_USERNAMES) do
		if player.Name == adminName then
			return true
		end
	end
	
	return false
end

-- 🎯 FUNCIÓN: Modificar puntaje
local function setScore(team, score)
	if team == "Home" or team == "home" then
		HomeScore.Value = math.max(0, math.floor(score))
		print("[ScoreCommand] ✅ Puntaje Home actualizado a: " .. HomeScore.Value)
		return true
	elseif team == "Away" or team == "away" then
		AwayScore.Value = math.max(0, math.floor(score))
		print("[ScoreCommand] ✅ Puntaje Away actualizado a: " .. AwayScore.Value)
		return true
	else
		warn("[ScoreCommand] ⚠️ Equipo inválido. Usa 'Home' o 'Away'")
		return false
	end
end

-- 🎯 FUNCIÓN: Agregar puntos
local function addScore(team, points)
	if team == "Home" or team == "home" then
		HomeScore.Value = math.max(0, HomeScore.Value + math.floor(points))
		print("[ScoreCommand] ✅ Puntaje Home: " .. HomeScore.Value .. " (+" .. points .. ")")
		return true
	elseif team == "Away" or team == "away" then
		AwayScore.Value = math.max(0, AwayScore.Value + math.floor(points))
		print("[ScoreCommand] ✅ Puntaje Away: " .. AwayScore.Value .. " (+" .. points .. ")")
		return true
	else
		warn("[ScoreCommand] ⚠️ Equipo inválido. Usa 'Home' o 'Away'")
		return false
	end
end

-- 🎯 FUNCIÓN: Resetear puntajes
local function resetScores()
	HomeScore.Value = 0
	AwayScore.Value = 0
	print("[ScoreCommand] ✅ Puntajes reseteados a 0")
	return true
end

-- 📡 REMOTEFUNCTION: Para llamar desde otros scripts del servidor
local SetScoreFunction = ReplicatedStorage:FindFirstChild("SetScore")
if not SetScoreFunction then
	SetScoreFunction = Instance.new("RemoteFunction")
	SetScoreFunction.Name = "SetScore"
	SetScoreFunction.Parent = ReplicatedStorage
end

SetScoreFunction.OnServerInvoke = function(player, action, team, value)
	-- Verificar permisos (opcional - comenta si quieres que cualquiera pueda usarlo)
	-- if not isAdmin(player) then
	-- 	warn("[ScoreCommand] ⚠️ " .. player.Name .. " intentó modificar puntajes sin permisos")
	-- 	return false, "No tienes permisos para modificar puntajes"
	-- end
	
	if action == "set" then
		return setScore(team, value), "Puntaje " .. team .. " establecido a " .. value
	elseif action == "add" then
		return addScore(team, value), "Puntaje " .. team .. " aumentado en " .. value
	elseif action == "reset" then
		return resetScores(), "Puntajes reseteados"
	else
		return false, "Acción inválida. Usa 'set', 'add' o 'reset'"
	end
end

print("[ScoreCommand] ✅ Sistema de comandos de puntaje cargado")

-- 💬 COMANDOS DE CHAT - Sistema de comandos para administradores
Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		-- Verificar si el jugador es administrador
		if not isAdmin(player) then return end
		
		local args = {}
		for word in message:gmatch("%S+") do
			table.insert(args, word)
		end
		
		if #args == 0 then return end
		
		local command = args[1]:lower()
		
		-- Comando: /score set Home 5
		if command == "/score" or command == "/puntaje" then
			if #args >= 2 then
				local action = args[2]:lower()
				
				if action == "set" and #args >= 4 then
					local team = args[3]
					local value = tonumber(args[4]) or 0
					setScore(team, value)
					-- Comando ejecutado silenciosamente (sin mensaje en chat)
				elseif action == "add" and #args >= 4 then
					local team = args[3]
					local value = tonumber(args[4]) or 0
					addScore(team, value)
					-- Comando ejecutado silenciosamente (sin mensaje en chat)
				elseif action == "reset" then
					resetScores()
					-- Comando ejecutado silenciosamente (sin mensaje en chat)
				elseif action == "get" or action == "ver" then
					-- Mostrar puntajes solo en la consola del servidor (no en chat)
					print("[ScoreCommand] 📊 Puntajes actuales (solicitado por " .. player.Name .. "):")
					print("  Home: " .. HomeScore.Value)
					print("  Away: " .. AwayScore.Value)
				end
				-- Los comandos se ejecutan silenciosamente, sin mensajes en el chat
			end
		end
	end)
end)

print("[ScoreCommand] 💬 Comandos de chat activados para administradores")
print("[ScoreCommand] 📝 Comandos disponibles en el chat:")
print("  /score set Home 5  - Establecer Home a 5")
print("  /score set Away 3  - Establecer Away a 3")
print("  /score add Home 2  - Agregar 2 a Home")
print("  /score add Away 1  - Agregar 1 a Away")
print("  /score reset       - Resetear ambos a 0")
print("  /score get         - Ver puntajes actuales")



--ScoreCommand.add('Home', 2) 
--ScoreCommand.add('Away', 1)
--ScoreCommand.set('Away', 3)
--ScoreCommand.set('Home', 3)
--ScoreCommand.reset()  -- Resetear ambos a 0