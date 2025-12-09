local DistanceFade = require(script.DistanceFade)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- initiate a new distancefade using .new() constructor
local distanceFade = DistanceFade.new()
local distanceFadeSettings = {
	["EdgeDistanceCalculations"] = true,
	["Texture"] = "rbxassetid://18852900044",
	["TextureTransparency"] = .25,
	["BackgroundTransparency"] = 0.95,
	["TextureColor"] = Color3.fromRGB(115, 248, 255),
	["BackgroundColor"] = Color3.fromRGB(0, 153, 255),
	["TextureSize"] = Vector2.new(6, 5.5),
	["TextureOffset"] = Vector2.new(0, .5),
	["Brightness"] = 3,
}
-- update distancefade with initial customization settings
distanceFade:UpdateSettings(distanceFadeSettings)

-- base x axis texture offsets for each face (to make the effect seamless)
local baseOffsetsX = {
	["1"] = -3,
	["2"] = -2,
	["3"] = -1,
	["4"] = 0,
	["5"] = 1,
	["6"] = 2,
	["7"] = 3
}

-- add faces to apply the effect to
local folder = script.Parent
local partsToAdd = {
	folder:WaitForChild("1"),
	folder:WaitForChild("2"),
	folder:WaitForChild("3"),
	folder:WaitForChild("4"),
	folder:WaitForChild("5"),
	folder:WaitForChild("6"),
	folder:WaitForChild("7"),
}
for _,basePart in partsToAdd do
	distanceFade:AddFace(basePart, Enum.NormalId.Front)
	distanceFade:AddFace(basePart, Enum.NormalId.Back)
end

-- tweens vector3 value to animate offset
local tweenValue = Instance.new("Vector3Value")
tweenValue.Parent = script
game:GetService("TweenService"):Create(tweenValue, TweenInfo.new(6, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false), { Value = Vector3.new(-6, 5.5) }):Play() -- offset is same as texture size for perfect loop
-- ============================================
-- EFECTO PARA COLISIONES DEL BALÓN CON PAREDES
-- ============================================
-- Agregar las paredes al mismo sistema de efectos que los hexágonos
-- Cuando el balón choca, la pared se agrega como un hexágono más

-- Tabla para rastrear efectos activos de colisiones en paredes
local activeCollisionEffects = {} -- {[part] = {expireTime, normal}}

-- Duración del efecto de colisión
local COLLISION_EFFECT_DURATION = 1.5

-- Función para verificar si una parte es una de las partes hexagonales (1-7)
local function isHexagonPart(part)
	if not part then return false end
	
	-- Verificar si la parte es una de las partes 1-7
	for _, hexPart in ipairs(partsToAdd) do
		if part == hexPart then
			return true
		end
	end
	
	-- También verificar por nombre (por si acaso)
	local partName = part.Name
	if partName == "1" or partName == "2" or partName == "3" or partName == "4" or 
	   partName == "5" or partName == "6" or partName == "7" then
		-- Verificar que esté en el mismo folder
		if part.Parent == folder then
			return true
		end
	end
	
	return false
end

-- Evento de colisión del balón
local ballWallCollisionEvent = ReplicatedStorage:FindFirstChild("BallWallCollision")
if ballWallCollisionEvent then
	ballWallCollisionEvent.OnClientEvent:Connect(function(hitPart, normalId, ballPosition, ballVelocity)
		-- Verificar que la parte sea válida
		if not hitPart or not hitPart.Parent or not hitPart:IsA("BasePart") then return end
		
		-- ⚠️ IMPORTANTE: Solo activar el efecto si la parte es una de las partes hexagonales (1-7)
		if not isHexagonPart(hitPart) then
			return
		end
		
		-- Verificar que la parte tenga CanCollide (es una pared)
		if not hitPart.CanCollide then return end
		
		-- Ignorar si ya hay un efecto activo en esta parte (evitar spam)
		if activeCollisionEffects[hitPart] then
			-- Actualizar el tiempo de expiración
			activeCollisionEffects[hitPart].expireTime = tick() + COLLISION_EFFECT_DURATION
			return
		end
		
		-- Verificar si el efecto ya está agregado a esta cara
		-- Si no está, agregarlo
		local alreadyHasEffect = false
		if distanceFade.TargetParts[hitPart] and distanceFade.TargetParts[hitPart][normalId] then
			alreadyHasEffect = true
		end
		
		if not alreadyHasEffect then
			-- Agregar el efecto a la cara golpeada usando el mismo distanceFade de hexágonos
			distanceFade:AddFace(hitPart, normalId)
		end
		
		-- Registrar el efecto activo
		activeCollisionEffects[hitPart] = {
			expireTime = tick() + COLLISION_EFFECT_DURATION,
			normal = normalId
		}
		
		-- Remover el efecto después del tiempo especificado
		task.delay(COLLISION_EFFECT_DURATION, function()
			if activeCollisionEffects[hitPart] then
				distanceFade:RemoveFace(hitPart, normalId)
				activeCollisionEffects[hitPart] = nil
			end
		end)
	end)
end

-- ============================================
-- LOOP PRINCIPAL (HEARTBEAT)
-- ============================================
RunService.Heartbeat:Connect(function() -- using Heartbeat for Step() is visually smoother than RenderStepped
	-- Actualizar efecto original de Hexagon
	for _,v in partsToAdd do
		local offsetX = baseOffsetsX[v.Name]-- + tweenValue.Value.X
		local offsetY = tweenValue.Value.Y
		distanceFade:UpdateFaceSettings(v, Enum.NormalId.Front, {["TextureOffset"] = Vector2.new(offsetX, offsetY)})
		distanceFade:UpdateFaceSettings(v, Enum.NormalId.Back, {["TextureOffset"] = Vector2.new(-offsetX, offsetY)})
	end
	
	-- Aplicar la misma animación de offset a las partes que tienen efecto activo por colisión
	-- Usar el mismo offset X que los hexágonos según el nombre de la parte
	for part, data in pairs(activeCollisionEffects) do
		-- Obtener el offset X según el nombre de la parte (igual que los hexágonos)
		local offsetX = baseOffsetsX[part.Name] or 0
		local offsetY = tweenValue.Value.Y
		
		-- Aplicar el mismo offset animado que los hexágonos
		-- Si es Front, usar offsetX positivo; si es Back, usar offsetX negativo
		if data.normal == Enum.NormalId.Front then
			distanceFade:UpdateFaceSettings(part, data.normal, {
				["TextureOffset"] = Vector2.new(offsetX, offsetY)
			})
		elseif data.normal == Enum.NormalId.Back then
			distanceFade:UpdateFaceSettings(part, data.normal, {
				["TextureOffset"] = Vector2.new(-offsetX, offsetY)
			})
		else
			-- Para otras caras (Left, Right, Top, Bottom), usar offset centrado
			distanceFade:UpdateFaceSettings(part, data.normal, {
				["TextureOffset"] = Vector2.new(0, offsetY)
			})
		end
	end
	
	-- Actualizar efecto (hexágonos y paredes) - usa posición del jugador
	-- El efecto en las paredes funciona igual que en los hexágonos (basado en distancia del jugador)
	distanceFade:Step()
	
	-- Limpiar efectos de colisión expirados
	local currentTime = tick()
	for part, data in pairs(activeCollisionEffects) do
		if currentTime >= data.expireTime then
			distanceFade:RemoveFace(part, data.normal)
			activeCollisionEffects[part] = nil
		end
	end
end)
