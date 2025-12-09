local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local allowedUsernames = {
	["gabiotaxmil"] = true,
}

local STARTING_MONEY = 250
local MONEY_DATASTORE_NAME = "PlayerMoney"
local USE_DATASTORE = false

local moneyDataStore = nil
if USE_DATASTORE then
	moneyDataStore = DataStoreService:GetDataStore(MONEY_DATASTORE_NAME)
end

local playerMoney = {}

local moneyUpdateEvent = ReplicatedStorage:FindFirstChild("MoneyUpdateEvent")
if not moneyUpdateEvent then
	moneyUpdateEvent = Instance.new("RemoteEvent")
	moneyUpdateEvent.Name = "MoneyUpdateEvent"
	moneyUpdateEvent.Parent = ReplicatedStorage
end

local getMoneyFunction = ReplicatedStorage:FindFirstChild("GetMoneyFunction")
if not getMoneyFunction then
	getMoneyFunction = Instance.new("RemoteFunction")
	getMoneyFunction.Name = "GetMoneyFunction"
	getMoneyFunction.Parent = ReplicatedStorage
end

local function isAllowed(player)
	if not player or not player.Name then
		return false
	end
	return allowedUsernames[player.Name] == true
end

local function loadPlayerMoney(player)
	local userId = player.UserId
	
	if USE_DATASTORE and moneyDataStore then
		local success, data = pcall(function()
			return moneyDataStore:GetAsync(userId)
		end)
		
		if success and data then
			return tonumber(data) or STARTING_MONEY
		else
			warn(string.format("[MoneySystem] Error al cargar dinero para %s: %s", player.Name, tostring(data)))
			return STARTING_MONEY
		end
	else
		return STARTING_MONEY
	end
end

local function savePlayerMoney(player, amount)
	local userId = player.UserId
	
	if USE_DATASTORE and moneyDataStore then
		local success, errorMessage = pcall(function()
			moneyDataStore:SetAsync(userId, amount)
		end)
		
		if not success then
			warn(string.format("[MoneySystem] Error al guardar dinero para %s: %s", player.Name, tostring(errorMessage)))
		end
	end
end

local function getMoney(player)
	if not playerMoney[player] then
		playerMoney[player] = loadPlayerMoney(player)
	end
	return playerMoney[player]
end

local function updateLeaderstats(player, amount)
	local leaderstats = player:FindFirstChild("leaderstats")
	
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end
	
	local moneyValue = leaderstats:FindFirstChild("Dinero")
	if not moneyValue then
		moneyValue = Instance.new("IntValue")
		moneyValue.Name = "Dinero"
		moneyValue.Parent = leaderstats
	end
	
	moneyValue.Value = amount
end

local function setMoney(player, amount)
	if not player or not player.Parent then
		return false
	end
	
	amount = math.max(0, math.floor(amount))
	playerMoney[player] = amount
	
	savePlayerMoney(player, amount)
	
	updateLeaderstats(player, amount)
	
	moneyUpdateEvent:FireClient(player, amount)
	
	return true
end

local function addMoney(player, amount)
	if not player or not player.Parent then
		return false
	end
	
	local currentMoney = getMoney(player)
	return setMoney(player, currentMoney + amount)
end

local function removeMoney(player, amount)
	if not player or not player.Parent then
		return false
	end
	
	local currentMoney = getMoney(player)
	return setMoney(player, math.max(0, currentMoney - amount))
end

local function parseMoneyCommand(message)
	if type(message) ~= "string" then
		return nil
	end
	
	local addMatch = string.match(message, "^/money%s+add%s+(%d+)%s*(.*)$")
	if addMatch then
		local amount = tonumber(addMatch)
		local targetName = string.match(message, "^/money%s+add%s+%d+%s+(.+)$")
		return {action = "add", amount = amount, target = targetName}
	end
	
	local removeMatch = string.match(message, "^/money%s+remove%s+(%d+)%s*(.*)$")
	if removeMatch then
		local amount = tonumber(removeMatch)
		local targetName = string.match(message, "^/money%s+remove%s+%d+%s+(.+)$")
		return {action = "remove", amount = amount, target = targetName}
	end
	
	local setMatch = string.match(message, "^/money%s+set%s+(%d+)%s*(.*)$")
	if setMatch then
		local amount = tonumber(setMatch)
		local targetName = string.match(message, "^/money%s+set%s+%d+%s+(.+)$")
		return {action = "set", amount = amount, target = targetName}
	end
	
	local giveMatch = string.match(message, "^/money%s+give%s+(%d+)%s+(.+)$")
	if giveMatch then
		local amount = tonumber(string.match(message, "^/money%s+give%s+(%d+)"))
		local targetName = string.match(message, "^/money%s+give%s+%d+%s+(.+)$")
		return {action = "give", amount = amount, target = targetName}
	end
	
	if string.match(message, "^/money%s*$") then
		return {action = "check"}
	end
	
	return nil
end

local function findPlayerByName(name)
	if not name or name == "" then
		return nil
	end
	
	name = string.lower(name)
	
	for _, player in ipairs(Players:GetPlayers()) do
		if string.lower(player.Name):match("^" .. name) or string.lower(player.DisplayName):match("^" .. name) then
			return player
		end
	end
	
	return nil
end

local function onPlayerChatted(player)
	return function(message)
		local command = parseMoneyCommand(message)
		
		if not command then
			return
		end
		
		if command.action ~= "check" then
			if not isAllowed(player) then
				warn(string.format("[MoneySystem] Usuario no permitido: %s intentó usar /money", player.Name))
				return
			end
		end
		
		if command.action == "check" then
			local money = getMoney(player)
			print(string.format("[MoneySystem] %s tiene $%d", player.Name, money))
			moneyUpdateEvent:FireClient(player, money)
			
		elseif command.action == "add" then
			local targetPlayer = command.target and findPlayerByName(command.target) or player
			if targetPlayer then
				addMoney(targetPlayer, command.amount)
				print(string.format("[MoneySystem] Se agregaron $%d a %s. Total: $%d", 
					command.amount, targetPlayer.Name, getMoney(targetPlayer)))
			else
				warn(string.format("[MoneySystem] Jugador '%s' no encontrado", command.target or ""))
			end
			
		elseif command.action == "remove" then
			local targetPlayer = command.target and findPlayerByName(command.target) or player
			if targetPlayer then
				removeMoney(targetPlayer, command.amount)
				print(string.format("[MoneySystem] Se quitaron $%d a %s. Total: $%d", 
					command.amount, targetPlayer.Name, getMoney(targetPlayer)))
			else
				warn(string.format("[MoneySystem] Jugador '%s' no encontrado", command.target or ""))
			end
			
		elseif command.action == "set" then
			local targetPlayer = command.target and findPlayerByName(command.target) or player
			if targetPlayer then
				setMoney(targetPlayer, command.amount)
				print(string.format("[MoneySystem] Dinero de %s establecido a $%d", 
					targetPlayer.Name, command.amount))
			else
				warn(string.format("[MoneySystem] Jugador '%s' no encontrado", command.target or ""))
			end
			
		elseif command.action == "give" then
			if not command.target then
				warn("[MoneySystem] Debes especificar un jugador para dar dinero")
				return
			end
			
			local targetPlayer = findPlayerByName(command.target)
			if targetPlayer then
				local playerMoney = getMoney(player)
				if playerMoney >= command.amount then
					removeMoney(player, command.amount)
					addMoney(targetPlayer, command.amount)
					print(string.format("[MoneySystem] %s dio $%d a %s", 
						player.Name, command.amount, targetPlayer.Name))
				else
					warn(string.format("[MoneySystem] %s no tiene suficiente dinero ($%d)", 
						player.Name, playerMoney))
				end
			else
				warn(string.format("[MoneySystem] Jugador '%s' no encontrado", command.target))
			end
		end
	end
end

getMoneyFunction.OnServerInvoke = function(player)
	return getMoney(player)
end

Players.PlayerAdded:Connect(function(player)
	local initialMoney = loadPlayerMoney(player)
	playerMoney[player] = initialMoney
	
	updateLeaderstats(player, initialMoney)
	
	moneyUpdateEvent:FireClient(player, initialMoney)
	
	player.Chatted:Connect(onPlayerChatted(player))
	
	print(string.format("[MoneySystem] %s se unió con $%d", player.Name, initialMoney))
end)

Players.PlayerRemoving:Connect(function(player)
	local money = playerMoney[player]
	if money then
		savePlayerMoney(player, money)
		playerMoney[player] = nil
		print(string.format("[MoneySystem] Se guardó el dinero de %s: $%d", player.Name, money))
	end
end)

for _, player in ipairs(Players:GetPlayers()) do
	local initialMoney = loadPlayerMoney(player)
	playerMoney[player] = initialMoney
	updateLeaderstats(player, initialMoney)
	moneyUpdateEvent:FireClient(player, initialMoney)
	player.Chatted:Connect(onPlayerChatted(player))
end

print("[MoneySystem] Sistema de dinero iniciado")
print(string.format("[MoneySystem] Dinero inicial: $%d", STARTING_MONEY))
print(string.format("[MoneySystem] DataStore: %s", USE_DATASTORE and "Activado" or "Desactivado"))
