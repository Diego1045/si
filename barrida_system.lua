local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- 🎯 Importar el sistema de estados
local PlayerStateSystem = require(game.ReplicatedStorage.PlayerStateSystem)

local BarridaSystem = {}
local barridaConnections = {} -- Para rastrear conexiones activas

-- ✅ Función para quitar el balón a un jugador
function BarridaSystem.StealBall(fromPlayer, toPlayer)
	if not fromPlayer or not toPlayer then return false end
	
	print("⚽ [BARRIDA] Jugador", toPlayer.Name, "le quitó el balón a", fromPlayer.Name)
	
	-- Notificar al servidor principal que hay que transferir el balón
	-- El servidor manejará el cambio de estados correctamente
	local transferEvent = game.ReplicatedStorage:FindFirstChild("TransferBall")
	if transferEvent then
		transferEvent:FireServer(fromPlayer, toPlayer)
		return true
	else
		warn("[BARRIDA] Evento TransferBall no encontrado")
		return false
	end
end

-- ✅ Función para detectar colisiones durante la barrida
function BarridaSystem.SetupBarridaCollision(player)
	if not player or not player.Character then return end
	
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end
	
	print("🎯 [BARRIDA] Configurando detección de colisiones para", player.Name)
	
	-- Crear conexión para detectar colisiones
	local connection = RunService.Heartbeat:Connect(function()
		-- Verificar si el jugador sigue en estado de barrida
		if not PlayerStateSystem.IsInBarrida(player) then
			connection:Disconnect()
			barridaConnections[player.UserId] = nil
			return
		end
		
		-- Verificar si el jugador sigue siendo válido
		if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
			connection:Disconnect()
			barridaConnections[player.UserId] = nil
			return
		end
		
		-- Buscar jugadores cercanos con balón
		local playerPosition = humanoidRootPart.Position
		local stealRange = 8 -- Rango de la barrida en studs
		
		for _, otherPlayer in Players:GetPlayers() do
			if otherPlayer ~= player and otherPlayer.Character then
				local otherHRP = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
				if otherHRP then
					local distance = (playerPosition - otherHRP.Position).Magnitude
					
					-- Si está en rango y tiene balón
					if distance <= stealRange and PlayerStateSystem.HasBall(otherPlayer) then
						print("⚽ [BARRIDA] Colisión detectada con", otherPlayer.Name, "a distancia", math.floor(distance))
						
						-- Quitar el balón
						BarridaSystem.StealBall(otherPlayer, player)
						
						-- Desconectar la detección de colisiones
						connection:Disconnect()
						barridaConnections[player.UserId] = nil
						
						return
					end
				end
			end
		end
	end)
	
	-- Guardar la conexión
	barridaConnections[player.UserId] = connection
end

-- ✅ Función para iniciar la barrida
function BarridaSystem.StartBarrida(player)
	if not player then return end
	
	print("🚀 [BARRIDA] Falta iniciada por", player.Name)
	
	-- Cambiar estado a barrida
	PlayerStateSystem.SetPlayerState(player, PlayerStateSystem.States.BARRIDA)
	
	-- Configurar detección de colisiones
	BarridaSystem.SetupBarridaCollision(player)
end

-- ✅ Función para terminar la barrida
function BarridaSystem.EndBarrida(player, hasBall)
	if not player then return end
	
	print("🏁 [BARRIDA] Falta terminada para", player.Name)
	
	-- Limpiar conexión de colisiones
	if barridaConnections[player.UserId] then
		barridaConnections[player.UserId]:Disconnect()
		barridaConnections[player.UserId] = nil
	end
	
	-- Cambiar estado según si tiene balón o no
	if hasBall then
		PlayerStateSystem.SetPlayerState(player, PlayerStateSystem.States.BALL)
	else
		PlayerStateSystem.SetPlayerState(player, PlayerStateSystem.States.NO_BALL)
	end
end

-- ✅ Limpiar conexiones cuando un jugador se va
Players.PlayerRemoving:Connect(function(player)
	if barridaConnections[player.UserId] then
		barridaConnections[player.UserId]:Disconnect()
		barridaConnections[player.UserId] = nil
	end
end)

return BarridaSystem
