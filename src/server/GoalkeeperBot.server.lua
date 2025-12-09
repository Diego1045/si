-- 🥅 GoalkeeperBot.server.lua
-- Ubicación: ServerScriptService
-- Bot de portero R6 que sigue al balón

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- ⚙️ CONFIGURACIÓN BÁSICA
local BALL_NAME = "Ball"
local BOT_NAME = "GoalkeeperBot"
local GRAB_DISTANCE = 5 -- Distancia en studs para conectar el balón
local GK_AREA_NAME = "GK.area" -- Nombre de la parte que define el área del portero
local BALL_R_NAME = "Ball.R" -- Nombre de la parte hacia donde disparar
local KICK_POWER = 0.7 -- Potencia del disparo (0-1)
local BALL_SPEED = 30 -- ⚡ VELOCIDAD DEL DISPARO: Cambia este valor para modificar la velocidad del lanzamiento (en studs/segundo)

-- Variables globales
local botModel = nil
local humanoid = nil
local rootPart = nil
local ball = nil
local hasBall = false -- Si el bot tiene el balón
local isShooting = false -- Si el bot está disparando (para evitar que lo vuelva a agarrar)
local ballMotor = nil -- Motor6D que conecta el balón al bot
local homePosition = nil -- Posición de spawn del bot
local gkArea = nil -- Parte que define el área del portero
local ballR = nil -- Parte Ball.R hacia donde disparar

-- INICIALIZACIÓN BÁSICA
task.wait(1)

-- Buscar el bot en workspace
botModel = workspace:FindFirstChild(BOT_NAME)
if botModel then
	humanoid = botModel:FindFirstChild("Humanoid")
	rootPart = botModel:FindFirstChild("HumanoidRootPart")
	
	if humanoid and rootPart then
		print("[GoalkeeperBot] ✅ Bot encontrado y configurado")
		
		-- Guardar posición inicial (posición de spawn)
		homePosition = rootPart.Position
		print("[GoalkeeperBot] 📍 Posición de spawn guardada:", homePosition)
		
		-- Configurar propiedades del bot
		humanoid.WalkSpeed = 16 -- Velocidad normal
		humanoid.Health = math.huge
		humanoid.MaxHealth = math.huge
		
		-- Crear BodyGyro para mantener orientación fija (0, 90, 0)
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
		bodyGyro.D = 500 -- Amortiguación
		bodyGyro.P = 3000 -- Potencia
		bodyGyro.CFrame = CFrame.Angles(0, math.rad(90), 0) -- Orientación fija (0, 90, 0)
		bodyGyro.Parent = rootPart
		
		print("[GoalkeeperBot] 🔧 Orientación fijada a (0, 90, 0) usando BodyGyro")
	else
		warn("[GoalkeeperBot] ⚠️ Bot encontrado pero falta Humanoid o RootPart")
	end
else
	warn("[GoalkeeperBot] ⚠️ No se encontró el bot:", BOT_NAME)
end

-- Buscar el área del portero (GK.area)
gkArea = workspace:FindFirstChild(GK_AREA_NAME)
if gkArea and gkArea:IsA("BasePart") then
	print("[GoalkeeperBot] ✅ Área del portero encontrada:", gkArea.Name)
else
	warn("[GoalkeeperBot] ⚠️ No se encontró el área del portero:", GK_AREA_NAME)
end

-- Buscar Ball.R (parte hacia donde disparar)
ballR = workspace:FindFirstChild(BALL_R_NAME, true) -- Buscar en todo el workspace
if ballR and ballR:IsA("BasePart") then
	print("[GoalkeeperBot] ✅ Ball.R encontrado:", ballR.Name)
else
	warn("[GoalkeeperBot] ⚠️ No se encontró Ball.R:", BALL_R_NAME)
end

-- ============================================
-- SISTEMA PARA DETECTAR EL BALÓN
-- ============================================

-- Función para obtener la posición del balón
-- El balón es una BasePart (Part) con hijos, NO un Model
local function getBallPosition()
	-- Buscar el balón si no existe
	if not ball or not ball.Parent then
		ball = workspace:FindFirstChild(BALL_NAME)
		if not ball then
			return nil, nil
		end
	end
	
	-- Verificar que sea una BasePart (Part, MeshPart, etc.)
	if ball:IsA("BasePart") then
		-- El balón es una Part, obtener posición directamente
		return ball.Position, ball.AssemblyLinearVelocity or ball.Velocity
	end
	
	-- Si no es una BasePart, algo está mal
	warn("[GoalkeeperBot] ⚠️ El balón no es una BasePart. Tipo:", ball.ClassName)
	return nil, nil
end

-- Función para obtener la distancia al balón
local function getDistanceToBall()
	if not rootPart then return math.huge end
	
	local ballPos = getBallPosition()
	if not ballPos then return math.huge end
	
	-- Calcular distancia entre el bot y el balón
	local distance = (rootPart.Position - ballPos).Magnitude
	return distance
end

-- ============================================
-- SISTEMA PARA CONECTAR EL BALÓN (Motor6D)
-- ============================================

-- Función para conectar el balón al bot usando Motor6D
local function connectBall()
	if not ball or not rootPart or not botModel then
		return false
	end
	
	-- Si ya tiene el balón, no hacer nada
	if hasBall then
		return true
	end
	
	-- Limpiar motor anterior si existe
	if ballMotor then
		ballMotor:Destroy()
		ballMotor = nil
	end
	
	-- Verificar si hay un motor existente (de otro dueño)
	local existingMotor = ball:FindFirstChild("BallMotor")
	if existingMotor and existingMotor:IsA("Motor6D") then
		existingMotor:Destroy()
	end
	
	-- Mover el balón al bot
	ball.Parent = botModel
	ball.Massless = true
	ball.CanTouch = false
	ball.CanCollide = false
	
	-- Crear Motor6D para conectar el balón al bot
	ballMotor = Instance.new("Motor6D")
	ballMotor.Name = "BallMotor"
	ballMotor.Part0 = rootPart  -- Parte del bot
	ballMotor.Part1 = ball      -- Parte del balón
	ballMotor.Parent = ball
	ballMotor.C0 = CFrame.new(0, -2, -2) -- Detrás y abajo del bot
	
	hasBall = true
	print("[GoalkeeperBot] ✅ Motor6D creado - Balón conectado al bot")
	
	return true
end

-- ============================================
-- SISTEMA DE DISPARO
-- ============================================

-- ============================================
-- ============================================
-- SISTEMA DE DISPARO MEJORADO (Opción 2: Curvas de Bézier - Trayectoria Perfecta)
-- ============================================
print("[GoalkeeperBot] 🚀 Sistema de disparo: Opción 2 (Curvas de Bézier) ACTIVADO")

-- Función para calcular trayectoria con compensación
-- Función de Curva de Bézier Cuadrática
-- B(t) = (1-t)^2 * P0 + 2(1-t)t * P1 + t^2 * P2
local function bezierQuadratic(t, p0, p1, p2)
	return (1 - t)^2 * p0 + 2 * (1 - t) * t * p1 + t^2 * p2
end

-- Función para encontrar un jugador objetivo
local function findTargetPlayer()
	local potentialTargets = {}
	
	for _, player in ipairs(Players:GetPlayers()) do
		-- Verificar si el jugador está en un equipo válido (Blue Lock o Sub-20)
		if player.Team and (player.Team.Name == "Blue Lock" or player.Team.Name == "Sub-20") then
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				table.insert(potentialTargets, player.Character.HumanoidRootPart)
			end
		end
	end
	
	if #potentialTargets > 0 then
		-- Seleccionar uno al azar (o podrías elegir el más cercano)
		return potentialTargets[math.random(1, #potentialTargets)]
	end
	
	return nil
end

-- Función para que el bot dispare el balón usando Curvas de Bézier
local function kickBall()
	if not hasBall or not ball or not rootPart or not ballMotor then
		return false
	end
	
	-- ============================================
	-- 1. IDENTIFICAR OBJETIVO Y APUNTAR (ANTES DE ESPERAR)
	-- ============================================
	local targetPart = findTargetPlayer()
	local targetObj = nil
	local targetName = ""
	
	if targetPart then
		targetObj = targetPart
		targetName = "Jugador (" .. targetPart.Parent.Name .. ")"
	elseif ballR then
		targetObj = ballR
		targetName = "Ball.R (Default)"
	else
		targetName = "Frente (Fallback)"
	end
	
	-- Apuntar hacia el objetivo (Visual feedback)
	if targetObj and rootPart then
		local targetPos = targetObj.Position
		-- Rotar solo en el eje Y para mirar al objetivo
		local lookPos = Vector3.new(targetPos.X, rootPart.Position.Y, targetPos.Z)
		rootPart.CFrame = CFrame.lookAt(rootPart.Position, lookPos)
	end
	
	print("[GoalkeeperBot] 🎯 Objetivo identificado:", targetName)
	print("[GoalkeeperBot] ⏳ Preparando disparo Bézier (2 segundos)...")
	
	-- Marcar como disparando para evitar interrupciones
	isShooting = true
	
	-- Esperar 2 segundos (con verificación de colisión durante la espera)
	local waitTime = 0
	local waitDuration = 2
	while waitTime < waitDuration do
		-- Verificar si el balón fue tomado por un jugador durante la espera
		if ball and ball.Parent then
			local playerMotor = ball:FindFirstChild("BallMotor")
			if playerMotor and playerMotor:IsA("Motor6D") then
				if playerMotor.Part0 and playerMotor.Part0.Parent then
					local parentModel = playerMotor.Part0.Parent
					if parentModel:IsA("Model") and parentModel:FindFirstChild("Humanoid") then
						if parentModel ~= botModel then
							print("[GoalkeeperBot] ⚠️ Balón interceptado durante la espera - Cancelando disparo")
							isShooting = false
							return false
						end
					end
				end
			end
			
			-- También verificar si el balón está dentro del Character de un jugador
			if ball.Parent:IsA("Model") and ball.Parent:FindFirstChild("Humanoid") then
				if ball.Parent ~= botModel then
					print("[GoalkeeperBot] ⚠️ Balón tomado durante la espera - Cancelando disparo")
					isShooting = false
					return false
				end
			end
		end
		
		task.wait(0.1) -- Verificar cada 0.1 segundos
		waitTime = waitTime + 0.1
	end
	
	-- ============================================
	-- 2. VERIFICACIÓN Y DISPARO BÉZIER
	-- ============================================
	
	-- Verificar que todavía tiene el balón
	if not hasBall or not ball or ball.Parent ~= botModel then
		warn("[GoalkeeperBot] ⚠️ El bot perdió el balón durante la espera")
		isShooting = false -- Cancelar estado de disparo
		return false
	end
	
	-- Destruir el Motor6D
	if ballMotor then
		ballMotor:Destroy()
		ballMotor = nil
	end
	
	-- Configurar balón para animación (CON VELOCIDAD LINEAL)
	ball.Parent = workspace
	ball.Massless = true
	ball.CanTouch = true
	ball.CanCollide = true
	ball.Anchored = false
	
	-- Crear Attachment para la velocidad
	local ballAttachment = Instance.new("Attachment")
	ballAttachment.Name = "VelocityAttachment"
	ballAttachment.Parent = ball
	
	-- Crear LinearVelocity (Control directo de velocidad)
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = ballAttachment
	linearVelocity.MaxForce = math.huge -- Fuerza infinita para mantener la velocidad
	linearVelocity.VectorVelocity = Vector3.zero -- Inicialmente quieto
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity.Parent = ball
	
	-- Detener cualquier movimiento previo
	ball.AssemblyLinearVelocity = Vector3.zero
	ball.AssemblyAngularVelocity = Vector3.zero
	
	-- Calcular puntos de la curva
	local p0 = ball.Position -- Punto inicial
	local p2 = nil -- Punto final (Objetivo)
	
	if targetObj then
		p2 = targetObj.Position
	else
		p2 = rootPart.Position + rootPart.CFrame.LookVector * 50
	end
	
	-- Calcular punto de control (P1) para la curva
	-- P1 estará en el medio pero MÁS BAJO (ajustado por petición del usuario: "MAS ABAJO")
	local midPoint = (p0 + p2) / 2
	-- Antes: / 5. Ahora: / 12 (Casi plano)
	local height = math.max((p0 - p2).Magnitude / 12, 3) 
	local p1 = midPoint + Vector3.new(0, height, 0)
	
	-- Ejecutar animación de disparo
	task.spawn(function()
		local t = 0
		
		-- CALCULAR DURACIÓN BASADA EN VELOCIDAD Y DISTANCIA
		local distance = (p2 - p0).Magnitude
		local duration = distance / BALL_SPEED -- Tiempo = Distancia / Velocidad
		
		-- Asegurar un mínimo de tiempo para evitar errores
		if duration < 0.1 then duration = 0.1 end
		
		local startTime = tick()
		local lastPos = p0
		local deltaTime = 0.016 -- Aproximadamente 1 frame a 60 FPS
		
		print("[GoalkeeperBot] 🚀 Iniciando trayectoria Bézier (LinearVelocity)...")
		print("[GoalkeeperBot] 📊 Velocidad configurada:", BALL_SPEED, "studs/seg")
		
		while t < 1 do
			-- ⚠️ DETECTAR SI EL BALÓN COLISIONÓ CON UN JUGADOR (Motor6D activo)
			-- IMPORTANTE: Verificar ANTES de aplicar la velocidad para evitar arrastrar al jugador
			local ballIntercepted = false
			
			if ball and ball.Parent then
				local playerMotor = ball:FindFirstChild("BallMotor")
				if playerMotor and playerMotor:IsA("Motor6D") then
					-- Verificar si el Motor6D conecta a un Character (jugador, no el bot)
					if playerMotor.Part0 and playerMotor.Part0.Parent then
						local parentModel = playerMotor.Part0.Parent
						if parentModel:IsA("Model") and parentModel:FindFirstChild("Humanoid") then
							-- Es un Character (jugador), NO el bot
							if parentModel ~= botModel then
								ballIntercepted = true
							end
						end
					end
				end
				
				-- También verificar si el balón está dentro del Character de un jugador
				if not ballIntercepted and ball.Parent:IsA("Model") and ball.Parent:FindFirstChild("Humanoid") then
					if ball.Parent ~= botModel then
						ballIntercepted = true
					end
				end
			end
			
			-- Si el balón fue interceptado, DETENER TODO INMEDIATAMENTE
			if ballIntercepted then
				print("[GoalkeeperBot] ⚠️ Balón interceptado por jugador - Deteniendo disparo inmediatamente")
				
				-- 🔴 CRÍTICO: Detener el LinearVelocity PRIMERO (antes de cualquier otra cosa)
				if linearVelocity then
					linearVelocity.VectorVelocity = Vector3.zero -- Detener velocidad
					linearVelocity:Destroy() -- Destruir inmediatamente
					linearVelocity = nil
				end
				
				-- Detener cualquier velocidad física del balón
				if ball then
					ball.AssemblyLinearVelocity = Vector3.zero
					ball.AssemblyAngularVelocity = Vector3.zero
				end
				
				-- Limpiar attachment
				if ballAttachment then
					ballAttachment:Destroy()
					ballAttachment = nil
				end
				
				-- Cancelar estado de disparo
				isShooting = false
				
				-- Salir del loop (cancelar el disparo)
				return
			end
			
			-- Solo aplicar velocidad si el balón NO fue interceptado
			local elapsed = tick() - startTime
			t = elapsed / duration
			
			if t > 1 then t = 1 end
			
			-- Calcular la posición actual en la curva Bézier
			local currentPos = bezierQuadratic(t, p0, p1, p2)
			
			-- Calcular la velocidad tangencial a la curva (derivada de la curva Bézier)
			-- Derivada: B'(t) = 2(1-t)(P1-P0) + 2t(P2-P1)
			-- Esto nos da la dirección y magnitud del vector tangente
			local tangent = 2 * (1 - t) * (p1 - p0) + 2 * t * (p2 - p1)
			local tangentDirection = tangent.Unit
			
			-- Aplicar la velocidad tangencial con la magnitud BALL_SPEED
			-- Solo si el LinearVelocity todavía existe (no fue destruido)
			if linearVelocity and linearVelocity.Parent then
				linearVelocity.VectorVelocity = tangentDirection * BALL_SPEED
			end
			
			RunService.Heartbeat:Wait()
		end
		
		-- Al terminar la animación
		print("[GoalkeeperBot] ✅ Balón llegó al objetivo")
		
		-- Limpiar motor físico
		if linearVelocity then linearVelocity:Destroy() end
		if ballAttachment then ballAttachment:Destroy() end
		
		-- Restaurar física del balón
		ball.Massless = false
		
		-- Darle un impulso final usando BALL_SPEED (no un valor hardcodeado)
		local finalDir = (p2 - p1).Unit
		ball.AssemblyLinearVelocity = finalDir * BALL_SPEED
		
		-- IMPORTANTE: Terminar estado de disparo después de un pequeño delay
		-- para asegurar que el balón se aleje lo suficiente
		task.wait(0.5)
		isShooting = false
	end)
	
	-- Actualizar estado
	hasBall = false
	
	return true
end

-- ============================================
-- SISTEMA DE LIMITANTE (GK.area)
-- ============================================

-- Función para restringir una posición al área del portero
local function clampToGKArea(targetPosition)
	if not gkArea then
		return targetPosition -- Si no hay área, devolver posición original
	end
	
	-- Convertir posición global a local del área
	local localPos = gkArea.CFrame:PointToObjectSpace(targetPosition)
	local halfSize = gkArea.Size * 0.5
	
	-- Limitar a los bordes del área
	localPos = Vector3.new(
		math.clamp(localPos.X, -halfSize.X, halfSize.X),
		math.clamp(localPos.Y, -halfSize.Y, halfSize.Y),
		math.clamp(localPos.Z, -halfSize.Z, halfSize.Z)
	)
	
	-- Convertir de vuelta a posición global
	return gkArea.CFrame:PointToWorldSpace(localPos)
end

-- ============================================
-- SISTEMA DE MOVIMIENTO
-- ============================================

-- Función para seguir al balón
local function followBall()
	if not humanoid or not rootPart then
		return false
	end
	
	-- Si está disparando, NO hacer nada (esperar a que termine)
	if isShooting then
		return false
	end
	
	-- Si ya tiene el balón, volver a posición de spawn (limitado por el área)
	if hasBall then
		if homePosition then
			-- Aplicar limitante del área a la posición de spawn
			local targetSpawn = clampToGKArea(homePosition)
			local distanceToSpawn = (rootPart.Position - targetSpawn).Magnitude
			
			if distanceToSpawn > 2 then
				-- Volver a posición de spawn (limitado por el área)
				humanoid.WalkSpeed = 16
				humanoid:MoveTo(targetSpawn)
			else
				-- Ya está en spawn: disparar hacia Ball.R
				humanoid:MoveTo(rootPart.Position) -- Detenerse
				kickBall() -- Disparar hacia Ball.R
			end
		end
		return true
	end
	
	local ballPos, ballVelocity = getBallPosition()
	if not ballPos then
		return false
	end
	
	-- Calcular distancia
	local distance = (rootPart.Position - ballPos).Magnitude
	
	-- Si está a menos de GRAB_DISTANCE, conectar el balón
	if distance < GRAB_DISTANCE then
		humanoid:MoveTo(rootPart.Position) -- Detener movimiento
		connectBall() -- Conectar el balón
		return true
	end
	
	-- Si está muy cerca, detener
	if distance < 3 then
		humanoid:MoveTo(rootPart.Position)
		return true
	end
	
	-- Aplicar limitante del área
	local targetPos = clampToGKArea(ballPos)
	
	-- Mover hacia el balón (limitado por el área)
	humanoid.WalkSpeed = 16 -- Velocidad normal
	humanoid:MoveTo(targetPos)
	
	return true
end

-- Buscar el balón inicialmente
ball = workspace:FindFirstChild(BALL_NAME)
if ball then
	if ball:IsA("BasePart") then
		print("[GoalkeeperBot] ✅ Balón encontrado (Part):", ball.Name)
	else
		warn("[GoalkeeperBot] ⚠️ El balón no es una BasePart. Tipo:", ball.ClassName)
	end
else
	warn("[GoalkeeperBot] ⚠️ No se encontró el balón:", BALL_NAME)
end

-- ============================================
-- LOOP PRINCIPAL: Seguir al balón
-- ============================================

task.spawn(function()
	while true do
		if botModel and humanoid and rootPart then
			-- Verificar si el bot todavía tiene el balón
			if hasBall then
				-- Verificar que el balón sigue conectado
				if not ballMotor or not ballMotor.Parent or not ball or ball.Parent ~= botModel then
					-- El bot perdió el balón
					hasBall = false
					if ballMotor then
						ballMotor = nil
					end
				else
					-- El bot tiene el balón: volver a posición de spawn
					followBall() -- Esta función maneja el regreso a spawn
				end
			else
				-- El bot no tiene el balón, intentar seguirlo
				local ballPos, ballVelocity = getBallPosition()
				
				if ballPos then
					-- Seguir al balón
					followBall()
					
					-- Debug ocasional
					if tick() % 3 < 0.1 then
						local distance = getDistanceToBall()
						if hasBall then
							local distanceToSpawn = homePosition and (rootPart.Position - homePosition).Magnitude or 0
							print("[GoalkeeperBot] ⚽ Bot tiene el balón - Distancia al spawn:", math.floor(distanceToSpawn), "studs")
						else
							print("[GoalkeeperBot] ⚽ Siguiendo al balón - Distancia:", math.floor(distance), "studs")
						end
					end
				end
			end
		end
		
		task.wait(0.3) -- Actualizar cada 0.3 segundos
	end
end)
