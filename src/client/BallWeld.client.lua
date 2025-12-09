-- 🎯 Ball Weld Client - LocalScript
-- Este script debe ir en StarterPlayer > StarterPlayerScripts
-- Detecta cuando el jugador está cerca del balón y envía señal al servidor
-- También maneja el pateo del balón cuando el jugador tiene el balón

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local ball = workspace:WaitForChild("Ball")

-- Helper robusto para obtener el Character y el HumanoidRootPart
local function ensureCharacter()
	-- Esperar al Character de forma segura (incluye respawns rápidos)
	local char = player.Character
	if not char or not char.Parent then
		char = player.CharacterAdded:Wait()
	end
	-- Asegurar Humanoid presente antes de pedir HRP
	char:WaitForChild("Humanoid")
	return char
end

local character = ensureCharacter()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- 🎬 Animaciones de carga (mientras se mantiene click) y de soltado
local chargingAnimId = "rbxassetid://123401211024413"
local releaseAnimId = "rbxassetid://114066407142790"
local chargingAnimTrack, releaseAnimTrack do
	local a1 = Instance.new("Animation")
	a1.AnimationId = chargingAnimId
	local a2 = Instance.new("Animation")
	a2.AnimationId = releaseAnimId
	chargingAnimTrack = humanoid:LoadAnimation(a1)
	releaseAnimTrack = humanoid:LoadAnimation(a2)
	chargingAnimTrack.Looped = true
	chargingAnimTrack.Priority = Enum.AnimationPriority.Action
	releaseAnimTrack.Priority = Enum.AnimationPriority.Action
end

-- RemoteEvents para comunicarse con el servidor (compatible con ambos nombres)
local remoteWeldBall = ReplicatedStorage:FindFirstChild("wel ball") or ReplicatedStorage:FindFirstChild("WeldBall")
if not remoteWeldBall then
	remoteWeldBall = Instance.new("RemoteEvent")
	remoteWeldBall.Name = "wel ball"
	remoteWeldBall.Parent = ReplicatedStorage
end

local kickEvent = ReplicatedStorage:FindFirstChild("kick event")
if not kickEvent then
	kickEvent = Instance.new("RemoteEvent")
	kickEvent.Name = "kick event"
	kickEvent.Parent = ReplicatedStorage
end

-- ⚙️ Configuración de Weld
local weldDistance = 4  -- Distancia para detectar el balón (compatible con sistema existente)
local weldCooldown = false
local cooldownTime = 2  -- Tiempo de cooldown entre intentos
local kickCooldown = false
local kickCooldownTime = 0.5  -- Cooldown después de patear para evitar reconexión inmediata (reducido de 1.5 a 0.5)
local lastKickTime = 0  -- Tiempo del último pateo

-- ⚙️ Configuración de Pateo (inspirado en el script de referencia)
local MIN_POWER = 35
local MAX_POWER = 100
local UP_FORCE_DIVIDE = 300
local UP_FORCE_MIN = 20
local MAX_POWER_VALUE = 97  -- Valor máximo de la barra (se llena hasta 97)
local CHARGE_SPEED = 97  -- Velocidad de carga por segundo (0-97 en 1 segundo)
local DISCHARGE_SPEED = 30  -- Velocidad de descarga por segundo
-- Auto-disparo si mantiene potencia >= 40 por 3 segundos
local AUTO_SHOOT_THRESHOLD = 40
local AUTO_SHOOT_HOLD_SECONDS = 3

-- Variables de estado para pateo
local isCharging = false
local powerValue = 0
local mouseButton1Down = false
local timeAboveAutoThreshold = 0

-- Variables para la barra de fuerza
local powerBarGui = nil
local powerBarScale = nil

-- 🛡️ Asegurar que solo veas tus propias barras (Power bar / Stamina)
local function hideOtherPlayersBillboards()
	for _, plr in ipairs(Players:GetPlayers()) do
		local char = plr.Character
		if char and char ~= character then
			local pb = char:FindFirstChild("Power bar")
			if pb and pb:IsA("BillboardGui") then
				pb.Enabled = false
			end
			local sb = char:FindFirstChild("Stamina")
			if sb and sb:IsA("BillboardGui") then
				sb.Enabled = false
			end
		end
	end
end

-- Ejecutar al inicio y escuchar nuevos elementos que aparezcan
hideOtherPlayersBillboards()
workspace.DescendantAdded:Connect(function(obj)
	if not character then return end
	if obj:IsA("BillboardGui") and (obj.Name == "Power bar" or obj.Name == "Stamina") then
		local parentModel = obj:FindFirstAncestorOfClass("Model")
		if parentModel and parentModel ~= character then
			obj.Enabled = false
		end
	end
end)

-- 🔄 Inicializar la barra de fuerza (BillboardGui "Power bar")
local function initializePowerBar(char)
	if not char then return end
	
	-- Buscar el BillboardGui "Power bar" en el Character
	powerBarGui = char:FindFirstChild("Power bar")
	if not powerBarGui then
		warn("[BallWeldClient] ⚠️ No se encontró el BillboardGui 'Power bar' en el Character")
		return
	end
	
	-- Buscar la barra dentro del BillboardGui
	local frame = powerBarGui:FindFirstChild("Frame")
	if frame then
		powerBarScale = frame:FindFirstChild("Bar")
	end
	
	if not powerBarScale then
		warn("[BallWeldClient] ⚠️ No se encontró la Bar dentro de 'Power bar'")
		return
	end
	
	-- Asegurar que la Power bar esté anclada al jugador (no al balón)
	-- 1) Reparentar al Character si está en otro contenedor
	if powerBarGui.Parent ~= char then
		powerBarGui.Parent = char
	end
	-- 2) Forzar que el Adornee sea el HumanoidRootPart del jugador
	if powerBarGui:IsA("BillboardGui") then
		powerBarGui.Adornee = char:FindFirstChild("HumanoidRootPart")
		powerBarGui.AlwaysOnTop = true
	end
	
	-- Configurar la barra (igual que StaminaBar)
	powerBarScale.AnchorPoint = Vector2.new(0, 1)
	powerBarScale.Position = UDim2.new(0, 0, 1, 0)
	powerBarGui.Enabled = false  -- Comienza oculta
	
	print("[BallWeldClient] ✅ Barra de fuerza inicializada")
end

-- 🎨 Actualizar la barra de fuerza visualmente
local function updatePowerBar()
	if not powerBarGui or not powerBarScale then return end
	
	local power = character:GetAttribute("power") or 0
	local isChargingAttr = character:GetAttribute("isCharging") or false
	
	-- Mostrar/ocultar según si está cargando
	powerBarGui.Enabled = isChargingAttr or (power > 0)
	
	-- Calcular ratio de llenado (0-1) basado en MAX_POWER_VALUE (97)
	local fillRatio = math.clamp(power / MAX_POWER_VALUE, 0, 1)
	local goalSize = UDim2.new(1, 0, fillRatio, 0)
	
	-- Animación con TweenService (igual que StaminaBar)
	local tween = TweenService:Create(
		powerBarScale,
		TweenInfo.new(0.1, Enum.EasingStyle.Quad),
		{Size = goalSize}
	)
	tween:Play()
	
	-- Cambiar color según la fuerza (INVERTIDO: rojo → amarillo → verde)
	if power < 50 then
		-- Rojo: Baja potencia (0-49)
		if powerBarScale:FindFirstChild("UIGradient") then
			powerBarScale.UIGradient.Color = ColorSequence.new(
				Color3.fromRGB(255, 0, 0),
				Color3.fromRGB(255, 50, 0)
			)
		end
	elseif power < 80 then
		-- Amarillo/Naranja: Potencia media (50-79)
		if powerBarScale:FindFirstChild("UIGradient") then
			powerBarScale.UIGradient.Color = ColorSequence.new(
				Color3.fromRGB(255, 200, 0),
				Color3.fromRGB(255, 150, 0)
			)
		end
	else
		-- Verde: Máxima potencia (80-97)
		if powerBarScale:FindFirstChild("UIGradient") then
			powerBarScale.UIGradient.Color = ColorSequence.new(
				Color3.fromRGB(0, 255, 0),
				Color3.fromRGB(100, 255, 0)
			)
		end
	end
end

-- 🔄 Inicializar atributos del Character para la barra de fuerza
local function initializeCharacterAttributes(char)
	if not char then return end
	
	-- Inicializar atributos (compatible con sistema de barra de fuerza)
	char:SetAttribute("power", 0)
	char:SetAttribute("isCharging", false)
	
	-- Inicializar la barra visual
	initializePowerBar(char)
end

-- 🔄 Manejar cuando el personaje se respawnea
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	rootPart = newCharacter:WaitForChild("HumanoidRootPart")
	
	-- Inicializar atributos y barra de fuerza
	initializeCharacterAttributes(character)
	
	-- Escuchar cambios en los atributos para actualizar la barra
	if character then
		character:GetAttributeChangedSignal("power"):Connect(updatePowerBar)
		character:GetAttributeChangedSignal("isCharging"):Connect(updatePowerBar)
		updatePowerBar()  -- Actualizar inicial
	end
	
	-- Resetear estado de pateo
	isCharging = false
	powerValue = 0
	mouseButton1Down = false
end)

-- Escuchar cambios en el personaje actual
if character then
	character:GetAttributeChangedSignal("power"):Connect(updatePowerBar)
	character:GetAttributeChangedSignal("isCharging"):Connect(updatePowerBar)
end

-- Inicializar atributos del personaje actual
initializeCharacterAttributes(character)

-- 🎯 Función para intentar conectar el balón
local function WeldCall()
	-- Verificar cooldowns
	if weldCooldown or kickCooldown then
		return
	end
	
	-- Verificar que el balón y el personaje existan
	if not ball or not ball.Parent then
		return
	end
	
	if not rootPart or not rootPart.Parent then
		return
	end
	
	-- Verificar que el jugador no tenga ya el balón
	if player:GetAttribute("HasBall") == true then
		return
	end
	
	-- Verificar que el balón no esté en movimiento rápido SOLO durante el cooldown
	-- Después del cooldown, se puede obtener sin importar la velocidad
	local timeSinceKick = os.clock() - lastKickTime
	
	-- Solo verificar velocidad si aún está en cooldown
	if timeSinceKick < kickCooldownTime then
		local ballVelocity = ball.AssemblyLinearVelocity.Magnitude
		if ballVelocity > 5 then  -- Si el balón se mueve rápido durante cooldown, no conectar
			return
		end
	end
	-- Después del cooldown, permitir conexión sin importar la velocidad
	
	-- Calcular distancia
	local distance = (ball.Position - rootPart.Position).Magnitude
	
	-- Si está dentro del rango, enviar señal al servidor
	if distance <= weldDistance then
		weldCooldown = true
		remoteWeldBall:FireServer()
		
		-- Activar cooldown
		task.wait(cooldownTime)
		weldCooldown = false
	end
end

-- 🎯 Función para calcular la dirección de la cámara
local function getCameraDirection()
	if not Camera then
		Camera = workspace.CurrentCamera
	end
	
	if not Camera then
		-- Fallback: usar dirección del rootPart
		if rootPart then
			return rootPart.CFrame.LookVector.Unit
		end
		return Vector3.new(0, 0, -1)  -- Dirección por defecto
	end
	
	-- Obtener la dirección hacia donde mira la cámara
	local cameraCFrame = Camera.CFrame
	if not cameraCFrame then
		-- Si no hay CFrame válido, usar rootPart
		if rootPart then
			return rootPart.CFrame.LookVector.Unit
		end
		return Vector3.new(0, 0, -1)
	end
	
	local lookVector = cameraCFrame.LookVector
	
	-- Validar y normalizar el vector
	-- Verificar que el vector sea válido (no NaN, no infinito, con magnitud razonable)
	if lookVector and lookVector.Magnitude > 0.01 and lookVector.Magnitude < math.huge then
		lookVector = lookVector.Unit
		
		-- Verificar que la normalización fue exitosa
		if lookVector.Magnitude > 0.9 and lookVector.Magnitude < 1.1 then
			return lookVector
		end
	end
	
	-- Si el vector es inválido, usar dirección del rootPart como fallback
	if rootPart then
		local rootLook = rootPart.CFrame.LookVector
		if rootLook and rootLook.Magnitude > 0.01 then
			return rootLook.Unit
		end
	end
	
	-- Último fallback: dirección por defecto
	return Vector3.new(0, 0, -1)
end

-- 🎯 Función para calcular la fuerza vertical basada en el ángulo
local function calculateUpForce(cameraDirection)
	-- Calcular el ángulo vertical (elevación)
	local angle = math.deg(math.asin(cameraDirection.Y))
	
	-- Convertir ángulo a fuerza vertical (más ángulo = más fuerza hacia arriba)
	local upForce = math.abs(angle) * 2  -- Factor de multiplicación ajustable
	
	return upForce
end

-- 🎯 Función para patear el balón
local function kickBall()
	-- Verificar que el jugador tenga el balón
	if not player:GetAttribute("hasBall") or player:GetAttribute("hasBall") ~= true then
		return
	end
	
	-- Verificar que haya potencia mínima
	if powerValue < 10 then
		powerValue = 0
		isCharging = false
		return
	end
	
	-- Calcular dirección de la cámara
	local cameraDirection = getCameraDirection()
	
	-- Calcular fuerza vertical
	local upForce = calculateUpForce(cameraDirection)
	
	-- Convertir powerValue (0-100) a valor 0-1 para el servidor
	local powerNormalized = powerValue / 100
	
	-- Enviar evento al servidor (compatible con el script de referencia)
	kickEvent:FireServer(cameraDirection, powerNormalized, upForce)
	
	-- Registrar tiempo del pateo
	lastKickTime = os.clock()
	
	-- Activar cooldown después de patear para evitar reconexión inmediata
	kickCooldown = true
	task.spawn(function()
		task.wait(kickCooldownTime)
		kickCooldown = false
	end)
	
	-- Resetear valores
	powerValue = 0
	isCharging = false
	mouseButton1Down = false
	
	-- Actualizar atributos para la barra de fuerza (BillboardGui)
	-- Esto ocultará la barra automáticamente
	if character then
		character:SetAttribute("power", 0)
		character:SetAttribute("isCharging", false)
	end
end

-- 🎮 Manejar input del mouse para patear
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
		-- Detectar clic izquierdo
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			-- Solo cargar si el jugador tiene el balón
			if player:GetAttribute("hasBall") == true and character then
			mouseButton1Down = true
			isCharging = true
			
			-- Actualizar atributos para la barra de fuerza (BillboardGui)
			character:SetAttribute("isCharging", true)
			character:SetAttribute("power", 0)  -- Comenzar desde 0
			
			-- Reproducir animación de carga
			if chargingAnimTrack then
				chargingAnimTrack:Play(0.1, 1, 1)
			end
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	-- Detectar cuando se suelta el clic izquierdo
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if mouseButton1Down and player:GetAttribute("hasBall") == true then
			-- Patear el balón
			kickBall()
		end
		-- Detener animación de carga y reproducir de soltado
		if chargingAnimTrack and chargingAnimTrack.IsPlaying then
			chargingAnimTrack:Stop(0.1)
		end
		if releaseAnimTrack then
			releaseAnimTrack:Play(0.05, 1, 1)
		end
		mouseButton1Down = false
	end
end)

-- 🔄 Actualizar carga de potencia cada frame
RunService.Heartbeat:Connect(function(deltaTime)
	local hasBall = player:GetAttribute("hasBall") == true
	
	-- Cargar potencia si está cargando y tiene el balón
	if isCharging and mouseButton1Down and hasBall and character then
		powerValue = math.clamp(powerValue + CHARGE_SPEED * deltaTime, 0, MAX_POWER_VALUE)
		
		-- Actualizar atributos para la barra de fuerza (BillboardGui)
		-- La barra se actualizará automáticamente mediante GetAttributeChangedSignal
		character:SetAttribute("power", powerValue)
		character:SetAttribute("isCharging", true)  -- Asegurar que esté en true
		
		-- Auto-disparo: si la potencia supera el umbral por cierto tiempo
		if powerValue >= AUTO_SHOOT_THRESHOLD then
			timeAboveAutoThreshold = timeAboveAutoThreshold + deltaTime
			if timeAboveAutoThreshold >= AUTO_SHOOT_HOLD_SECONDS then
				-- Parar animación de carga
				if chargingAnimTrack and chargingAnimTrack.IsPlaying then
					chargingAnimTrack:Stop(0.1)
				end
				-- Disparar
				kickBall()
				-- Reset locales
				mouseButton1Down = false
				isCharging = false
				timeAboveAutoThreshold = 0
			end
		else
			timeAboveAutoThreshold = 0
		end
	else
		-- Actualizar isCharging cuando no está cargando
		if character and isCharging then
			character:SetAttribute("isCharging", false)
		end
		
		-- Si dejó de cargar (por perder el balón, etc.), asegurar parar animación de carga
		if not mouseButton1Down and chargingAnimTrack and chargingAnimTrack.IsPlaying then
			chargingAnimTrack:Stop(0.1)
		end
		
		-- Descargar potencia si no está cargando (pero aún tiene valor)
		if powerValue > 0 and character then
			powerValue = math.clamp(powerValue - DISCHARGE_SPEED * deltaTime, 0, MAX_POWER_VALUE)
			character:SetAttribute("power", powerValue)
		end
		
		-- Si no tiene el balón, resetear todo
		if not hasBall and character then
			powerValue = 0
			isCharging = false
			mouseButton1Down = false
			timeAboveAutoThreshold = 0
			
			-- Resetear atributos (ocultará la barra)
			character:SetAttribute("power", 0)
			character:SetAttribute("isCharging", false)
		end
	end
	
	-- Intentar conectar el balón (solo si no tiene el balón)
	if not hasBall then
		WeldCall()
	end
end)

