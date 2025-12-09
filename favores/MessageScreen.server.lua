-- 💬 Sistema de Mensajes en Pantalla
-- Escucha el comando /msg seguido de una oración y lo muestra en pantalla a todos los jugadores

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Lista de usuarios permitidos para usar el comando /msg
local allowedUsernames = {
	["gabiotaxmil"] = true,
	-- Agrega más usuarios aquí: ["nombreUsuario"] = true,
}

-- RemoteEvent para enviar mensajes a los clientes
local messageEvent = ReplicatedStorage:FindFirstChild("ShowMessageScreen")
if not messageEvent then
	messageEvent = Instance.new("RemoteEvent")
	messageEvent.Name = "ShowMessageScreen"
	messageEvent.Parent = ReplicatedStorage
end

-- Función para verificar si un jugador está permitido
local function isAllowed(player)
	if not player or not player.Name then
		return false
	end
	return allowedUsernames[player.Name] == true
end

-- Función para parsear el comando /msg
local function parseMessageCommand(message)
	if type(message) ~= "string" then
		return nil
	end
	
	-- Buscar el comando /msg seguido de un espacio y luego el resto del mensaje
	local messageText = string.match(message, "^/msg%s+(.+)$")
	return messageText
end

-- Función para manejar cuando un jugador escribe en el chat
local function onPlayerChatted(player)
	return function(message)
		local messageText = parseMessageCommand(message)
		
		if not messageText then
			return -- No es el comando /msg, ignorar
		end
		
		-- Verificar si el jugador está permitido
		if not isAllowed(player) then
			warn(string.format("[MessageScreen] Usuario no permitido: %s intentó usar /msg", player.Name))
			return
		end
		
		-- Enviar el mensaje a todos los jugadores
		print(string.format("[MessageScreen] %s envió mensaje: %s", player.Name, messageText))
		messageEvent:FireAllClients(messageText, player.Name)
	end
end

-- Conectar el evento de chat para todos los jugadores
Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(onPlayerChatted(player))
end)

-- Conectar para jugadores que ya están en el juego
for _, player in ipairs(Players:GetPlayers()) do
	player.Chatted:Connect(onPlayerChatted(player))
end

