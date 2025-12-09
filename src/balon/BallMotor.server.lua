--[[
    Script: ball (Script)
    Ubicación: Dentro del objeto "Ball"
    Propósito: Manejar la física del "weld" (soldar) y del "kick" (pateo).
]]

-- Servicios
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local Debris = game:GetService("Debris")

-- Eventos (compatible con ambos nombres)
local wel_ball = ReplicatedStorage:FindFirstChild("wel ball") or ReplicatedStorage:FindFirstChild("WeldBall")
if not wel_ball then
	wel_ball = Instance.new("RemoteEvent")
	wel_ball.Name = "wel ball"
	wel_ball.Parent = ReplicatedStorage
end

local kick_event = ReplicatedStorage:FindFirstChild("kick event")
if not kick_event then
	kick_event = Instance.new("RemoteEvent")
	kick_event.Name = "kick event"
	kick_event.Parent = ReplicatedStorage
end

-- Pelota
local ball = script.Parent

-- Drag BodyForce para resistencia del aire
local dragBodyForce
local dragBodyForceTemplate = ReplicatedStorage:FindFirstChild("drag body force")
if dragBodyForceTemplate and dragBodyForceTemplate:IsA("BodyForce") then
	dragBodyForce = dragBodyForceTemplate:Clone()
	dragBodyForce.Parent = ball
else
	-- Crear uno básico si no existe o si es del tipo incorrecto
	warn("[BallMotor] ⚠️ No se encontró 'drag body force' (BodyForce) en ReplicatedStorage. Creando uno básico.")
	dragBodyForce = Instance.new("BodyForce")
	dragBodyForce.Name = "DragBodyForce"
	dragBodyForce.Parent = ball
end

-- Variables del Script
local BALL_GROUP = "Ball"
local PLAYER_GROUP = "Player"

PhysicsService:RegisterCollisionGroup(BALL_GROUP)
PhysicsService:RegisterCollisionGroup(PLAYER_GROUP)
ball.CollisionGroup = BALL_GROUP

local currentOwner = nil
local weld

-- NUEVAS Variables
local weldedToPlayer = {}

-- Constantes de Física
local MAX_SPEED = 150
local FRICTION = 0.9 -- (No se usa directamente aquí, pero es relevante para la física)
local MIN_POWER = 35
local MAX_POWER = 500
local UP_FORCE_DIVIDE = 300
local UP_FORCE_MIN = 20


-- Funciones (hasBall, isNearBall)
local function hasBall(player)
	local atrib = player:GetAttribute("hasBall")
	return atrib == true
end

local function isNearBall(player, radius)
	local character = player.Character
	if not character then return false end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return false end
	return (rootPart.Position - ball.Position).Magnitude <= radius
end

-- Función para remover el Weld
local function removeWeld(player)
	if weld then
		weld:Destroy()
		weld = nil
	end
	
	if player then
		weldedToPlayer[player.UserId] = nil
		player:SetAttribute("hasBall", false)
	end
	
	ball.Massless = false
	ball.CanTouch = true
	ball.CanCollide = true
	
	currentOwner = nil
end

-- Función para detener el giro
local function stopSpinning()
	local av = ball:FindFirstChild("AngularVelocity")
	if av then
		av.AngularVelocity = Vector3.new(0, 0, 0)
		av.MaxTorque = 0
	end
end

-- Función para aplicar "Drag" (resistencia del aire)
local function applyDrag()
	if not dragBodyForce then return end
	
	local velocity = ball.AssemblyLinearVelocity.Magnitude
	if velocity > 0.1 then
		-- Fórmula de "drag"
		dragBodyForce.Force = -ball.AssemblyLinearVelocity.Unit * (velocity ^ 2) * 0.05
	else
		dragBodyForce.Force = Vector3.new(0, 0, 0)
	end
end

-- Función de Weld
local function welBallFunction(player)
	if hasBall(player) then return end
	if not isNearBall(player, 12) then return end
	
	-- 🔒 IMPORTANTE: Verificar si el balón ya está conectado a otro jugador
	-- Si el balón tiene un Motor6D activo o está en el Character de otro jugador, no permitir tomarlo
	if currentOwner and currentOwner ~= player and Players:IsAncestorOf(currentOwner) then
		-- Verificar si el balón está realmente conectado (tiene Motor6D)
		local ballMotor = ball:FindFirstChild("BallMotor")
		if ballMotor and ballMotor:IsA("Motor6D") then
			-- El balón está conectado a otro jugador, no permitir tomarlo
			return
		end
		-- También verificar si hay un Motor6D en el rootPart del dueño
		if currentOwner.Character then
			local ownerRootPart = currentOwner.Character:FindFirstChild("HumanoidRootPart")
			if ownerRootPart then
				local ownerMotor = ownerRootPart:FindFirstChild("BallMotor")
				if ownerMotor and ownerMotor:IsA("Motor6D") then
					-- El balón está conectado a otro jugador, no permitir tomarlo
					return
				end
			end
		end
		-- También verificar si el balón está dentro del Character del dueño
		if currentOwner.Character and ball.Parent == currentOwner.Character then
			-- El balón está dentro del Character de otro jugador, no permitir tomarlo
			return
		end
	end
	
	-- Si hay un dueño anterior pero el balón ya no está conectado, limpiarlo
	if currentOwner and Players:IsAncestorOf(currentOwner) then
		removeWeld(currentOwner)
	end
	
	currentOwner = player
	player:SetAttribute("hasBall", true)
	weldedToPlayer[player.UserId] = ball
	
	local character = player.Character
	if not character then return end
	
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end
	
	ball.Parent = character
	ball:SetNetworkOwner(player)
	ball.Massless = true
	ball.CanTouch = false
	ball.CanCollide = false
	
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = PLAYER_GROUP
		end
	end
	
	if weld then weld:Destroy() end
	weld = Instance.new("Motor6D")
	weld.Name = "BallMotor"
	weld.Part0 = rootPart
	weld.Part1 = ball
	weld.Parent = ball
	weld.C0 = CFrame.new(0, -2, -2)
end

-- Conexión de Evento (Patear)
kick_event.OnServerEvent:Connect(function(player, cameraDirection, powerValue, upForce)
	-- Verificar si el jugador que disparó es el que tiene la bola
	if not weldedToPlayer[player.UserId] or weldedToPlayer[player.UserId] ~= ball then
		return
	end
	
	local character = player.Character
	if not character then return end
	
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end
	
	-- 🔴 CRÍTICO: Detener TODA velocidad del balón ANTES de remover el weld
	-- Esto previene que el balón se mueva hacia atrás cuando se destruye el Motor6D
	ball.AssemblyLinearVelocity = Vector3.zero
	ball.AssemblyAngularVelocity = Vector3.zero
	
	-- Remover el weld (esto mueve el balón a workspace)
	removeWeld(player)
	
	-- Asegurar que el balón esté en workspace y con física correcta
	if ball.Parent ~= workspace then
		ball.Parent = workspace
	end
	
	-- Física del Pateo
	-- Normalizar y validar la dirección de la cámara
	local movementDirection = cameraDirection
	if movementDirection and movementDirection.Magnitude > 0.1 then
		movementDirection = movementDirection.Unit
	else
		-- Si la dirección es inválida, usar la dirección del rootPart como fallback
		movementDirection = rootPart.CFrame.LookVector.Unit
		warn("[BallMotor] ⚠️ Dirección de cámara inválida, usando dirección del rootPart para:", player.Name)
	end
	
	-- Calcular la fuerza basada en la potencia
	local force = (MIN_POWER + (MAX_POWER - MIN_POWER) * powerValue)
	local finalUpForce = math.max(upForce * (force / UP_FORCE_DIVIDE), UP_FORCE_MIN)
	
	-- Aplicar la velocidad (ahora el balón está limpio y listo)
	local finalVelocity = (movementDirection * force) + Vector3.new(0, finalUpForce, 0)
	ball.AssemblyLinearVelocity = finalVelocity
	
	-- Debug: Verificar dirección (solo en desarrollo, comentar en producción)
	-- print("[BallMotor] ⚽ Pateo - Jugador:", player.Name, "Dirección:", movementDirection, "Fuerza:", math.floor(force))
	
	task.wait(0.3)
	stopSpinning()
end)

-- 🧹 Limpiar cuando el jugador se desconecta
Players.PlayerRemoving:Connect(function(player)
	if currentOwner == player then
		-- Guardar la posición actual del balón ANTES de desconectarlo
		local ballPosition = ball.Position
		
		-- Desconectar el balón del jugador que se va
		removeWeld(player)
		
		-- IMPORTANTE: Mover el balón de vuelta a workspace ANTES de que el Character se elimine
		if ball and ball.Parent ~= workspace then
			ball.Parent = workspace
			-- Restaurar la posición del balón (donde estaba cuando el jugador se desconectó)
			ball.Position = ballPosition
			-- Restaurar propiedades del balón
			ball.Massless = false
			ball.CanTouch = true
			ball.CanCollide = true
			ball:SetNetworkOwner(nil)
		end
		
	end
	-- Limpiar referencia del jugador
	weldedToPlayer[player.UserId] = nil
end)

-- 🔄 Limpiar cuando el personaje se elimina (respawn)
Players.PlayerAdded:Connect(function(player)
	player.CharacterRemoving:Connect(function()
		if currentOwner == player then
			-- Guardar la posición actual del balón ANTES de desconectarlo
			local ballPosition = ball.Position
			
			-- Desconectar el balón del jugador
			removeWeld(player)
			
			-- IMPORTANTE: Mover el balón de vuelta a workspace ANTES de que el Character se elimine
			if ball and ball.Parent ~= workspace then
				ball.Parent = workspace
				-- Restaurar la posición del balón (donde estaba cuando el jugador hizo respawn)
				ball.Position = ballPosition
				-- Restaurar propiedades del balón
				ball.Massless = false
				ball.CanTouch = true
				ball.CanCollide = true
				ball:SetNetworkOwner(nil)
			end
			
		end
		-- Limpiar referencia del jugador
		weldedToPlayer[player.UserId] = nil
	end)
end)

-- 🎯 Detección de Colisiones con Paredes
local ballWallCollisionEvent = ReplicatedStorage:FindFirstChild("BallWallCollision")
if not ballWallCollisionEvent then
	ballWallCollisionEvent = Instance.new("RemoteEvent")
	ballWallCollisionEvent.Name = "BallWallCollision"
	ballWallCollisionEvent.Parent = ReplicatedStorage
end

-- Función para determinar qué cara de la parte fue golpeada
local function getHitNormal(hitPart, ballPosition)
	local hitCFrame = hitPart.CFrame
	local localPos = hitCFrame:PointToObjectSpace(ballPosition)
	local size = hitPart.Size
	
	-- Calcular distancias a cada cara
	local distToFront = math.abs(localPos.Z - size.Z/2)
	local distToBack = math.abs(localPos.Z + size.Z/2)
	local distToRight = math.abs(localPos.X - size.X/2)
	local distToLeft = math.abs(localPos.X + size.X/2)
	local distToTop = math.abs(localPos.Y - size.Y/2)
	local distToBottom = math.abs(localPos.Y + size.Y/2)
	
	-- Encontrar la cara más cercana
	local minDist = math.min(distToFront, distToBack, distToRight, distToLeft, distToTop, distToBottom)
	
	if minDist == distToFront then
		return Enum.NormalId.Front
	elseif minDist == distToBack then
		return Enum.NormalId.Back
	elseif minDist == distToRight then
		return Enum.NormalId.Right
	elseif minDist == distToLeft then
		return Enum.NormalId.Left
	elseif minDist == distToTop then
		return Enum.NormalId.Top
	else
		return Enum.NormalId.Bottom
	end
end

-- Cooldown para evitar spam de colisiones
local lastCollisionTime = 0
local COLLISION_COOLDOWN = 0.1 -- 100ms entre colisiones

-- Detectar colisiones del balón
ball.Touched:Connect(function(hitPart)
	-- Verificar cooldown
	local currentTime = tick()
	if currentTime - lastCollisionTime < COLLISION_COOLDOWN then
		return
	end
	
	-- Verificar que el balón no esté conectado a un jugador
	if currentOwner ~= nil then
		return
	end
	
	-- Verificar que la parte golpeada sea válida
	if not hitPart or not hitPart.Parent then
		return
	end
	
	-- Verificar que sea una BasePart
	if not hitPart:IsA("BasePart") then
		return
	end
	
	-- Verificar que tenga CanCollide (es una pared/obstáculo)
	if not hitPart.CanCollide then
		return
	end
	
	-- Ignorar si es el balón mismo o parte del jugador
	if hitPart == ball or hitPart.Parent == ball then
		return
	end
	
	-- Ignorar si es parte de un Character
	if hitPart.Parent:IsA("Model") and hitPart.Parent:FindFirstChild("Humanoid") then
		return
	end
	
	-- Verificar que el balón tenga velocidad (está en movimiento)
	local ballVelocity = ball.AssemblyLinearVelocity.Magnitude
	if ballVelocity < 5 then -- Solo activar si el balón se mueve con cierta velocidad
		return
	end
	
	-- Determinar qué cara fue golpeada
	local hitNormal = getHitNormal(hitPart, ball.Position)
	
	-- Actualizar cooldown
	lastCollisionTime = currentTime
	
	-- Enviar evento a todos los clientes
	ballWallCollisionEvent:FireAllClients(hitPart, hitNormal, ball.Position, ball.AssemblyLinearVelocity)
end)

-- Conexiones de Eventos
wel_ball.OnServerEvent:Connect(welBallFunction)
RunService.Heartbeat:Connect(applyDrag)
