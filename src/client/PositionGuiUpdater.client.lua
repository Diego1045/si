-- 🖼️ Position GUI Updater - LocalScript
-- Este script debe ir en StarterPlayer > StarterPlayerScripts
-- Actualiza la GUI mostrando la foto del jugador sobre el botón de posición ocupada

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperar a que el RemoteEvent exista
local PositionChanged = ReplicatedStorage:WaitForChild("PositionChanged")

-- ⚙️ CONFIGURACIÓN - Ajusta estos valores para cambiar el tamaño y posición de la foto
local CONFIG = {
	-- 📏 TAMAÑO de la foto (en píxeles)
	PhotoWidth = 100,   -- Ancho de la foto
	PhotoHeight = 100,  -- Alto de la foto

	-- 📍 POSICIÓN de la foto relativa al botón
	-- Opciones de posición:
	-- "top-right" = Arriba a la derecha
	-- "top-left" = Arriba a la izquierda
	-- "top-center" = Arriba al centro
	-- "bottom-right" = Abajo a la derecha
	-- "bottom-left" = Abajo a la izquierda
	-- "bottom-center" = Abajo al centro
	-- "center" = Centro del botón
	Position = "top-right",

	-- 🔢 OFFSET (ajuste fino de posición en píxeles)
	-- Ajusta estos valores para mover la foto unos píxeles más arriba/abajo o izquierda/derecha
	OffsetX = 0,  -- Negativo = más a la izquierda, Positivo = más a la derecha
	OffsetY = -100,    -- positivo = más abajo, negativo = más arriba

	-- 🎨 ESTILO
	ShowBorder = false,           -- Mostrar borde alrededor de la foto
	BorderColor = Color3.fromRGB(0, 0, 0),  -- Color del borde (negro)
	BorderThickness = 2,         -- Grosor del borde
	BackgroundColor = Color3.fromRGB(255, 255, 255),  -- Color de fondo (blanco)
	BackgroundTransparency = 1,   -- 0 = opaco, 1 = transparente

	-- 📝 NOMBRE DEL JUGADOR
	ShowPlayerName = false,       -- Mostrar nombre del jugador debajo de la foto
	NameLabelHeight = 12,        -- Alto del label del nombre (en píxeles)
}

-- Mapeo de claves de posición a nombres de botones en la GUI
local positionButtonMap = {
	CF_white = "CF_white",
	RW_white = "RW_white",
	LW_white = "LW_white",
	CM_white = "CM_white",
	GK_white = "GK_white",
}

-- 📍 Calcular posición basada en la configuración
local function calculatePosition(button)
	local buttonSize = button.AbsoluteSize
	local buttonPosition = button.AbsolutePosition
	
	local x, y = 0, 0
	local anchorX, anchorY = 0, 0
	
	if CONFIG.Position == "top-right" then
		x = 1
		y = 0
		anchorX = 1
		anchorY = 0
	elseif CONFIG.Position == "top-left" then
		x = 0
		y = 0
		anchorX = 0
		anchorY = 0
	elseif CONFIG.Position == "top-center" then
		x = 0.5
		y = 0
		anchorX = 0.5
		anchorY = 0
	elseif CONFIG.Position == "bottom-right" then
		x = 1
		y = 1
		anchorX = 1
		anchorY = 1
	elseif CONFIG.Position == "bottom-left" then
		x = 0
		y = 1
		anchorX = 0
		anchorY = 1
	elseif CONFIG.Position == "bottom-center" then
		x = 0.5
		y = 1
		anchorX = 0.5
		anchorY = 1
	elseif CONFIG.Position == "center" then
		x = 0.5
		y = 0.5
		anchorX = 0.5
		anchorY = 0.5
	else
		-- Por defecto: top-right
		x = 1
		y = 0
		anchorX = 1
		anchorY = 0
	end
	
	return UDim2.new(x, CONFIG.OffsetX, y, CONFIG.OffsetY), Vector2.new(anchorX, anchorY)
end

-- 🖼️ Crear ImageLabel con la foto del jugador sobre el botón
local function createPlayerPhotoOnButton(button, userId, username)
	if not button then
		return nil
	end
	
	-- Eliminar ImageLabel anterior si existe
	local existingPhoto = button:FindFirstChild("PlayerPhoto")
	if existingPhoto then
		existingPhoto:Destroy()
	end
	
	-- Calcular posición basada en la configuración
	local position, anchorPoint = calculatePosition(button)
	
	-- Crear Frame contenedor para la foto
	local photoFrame = Instance.new("Frame")
	photoFrame.Name = "PlayerPhoto"
	photoFrame.Size = UDim2.new(0, CONFIG.PhotoWidth, 0, CONFIG.PhotoHeight)
	photoFrame.Position = position
	photoFrame.AnchorPoint = anchorPoint
	photoFrame.BackgroundColor3 = CONFIG.BackgroundColor
	photoFrame.BackgroundTransparency = CONFIG.BackgroundTransparency
	
	if CONFIG.ShowBorder then
		photoFrame.BorderSizePixel = CONFIG.BorderThickness
		photoFrame.BorderColor3 = CONFIG.BorderColor
	else
		photoFrame.BorderSizePixel = 0
	end
	
	photoFrame.ZIndex = button.ZIndex + 1 -- Asegurar que esté por encima
	photoFrame.Parent = button
	
	-- Crear ImageLabel para la foto del jugador
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "PlayerImage"
	imageLabel.Size = UDim2.new(0.85, 0, 0.85, 0)
	imageLabel.Position = UDim2.new(0.075, 0, 0.075, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.BorderSizePixel = 0
	imageLabel.Parent = photoFrame
	
	-- Obtener la imagen del avatar del jugador
	local success, thumbnail = pcall(function()
		return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	end)
	
	if success and thumbnail then
		imageLabel.Image = thumbnail
	else
		-- Imagen por defecto si falla
		imageLabel.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	end
	
	-- Crear TextLabel con el nombre del jugador (si está habilitado)
	if CONFIG.ShowPlayerName then
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "PlayerName"
		nameLabel.Size = UDim2.new(1, 0, 0, CONFIG.NameLabelHeight)
		nameLabel.Position = UDim2.new(0, 0, 1, 0)
		nameLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		nameLabel.BackgroundTransparency = 0.2
		nameLabel.Text = username or ""
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextSize = 8
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextStrokeTransparency = 0.5
		nameLabel.BorderSizePixel = 0
		nameLabel.ZIndex = photoFrame.ZIndex
		nameLabel.Parent = photoFrame
	end
	
	return photoFrame
end

-- 🗑️ Eliminar ImageLabel del botón
local function removePlayerPhotoFromButton(button)
	if not button then
		return
	end
	
	local existingPhoto = button:FindFirstChild("PlayerPhoto")
	if existingPhoto then
		existingPhoto:Destroy()
	end
end

-- 🔍 Buscar el botón de posición en la GUI
local function findPositionButton(positionKey)
	local teamWhite = playerGui:FindFirstChild("Team_White", true)
	if not teamWhite then
		warn("[PositionGuiUpdater] ⚠️ No se encontró Team_White en PlayerGui")
		return nil
	end
	
	local buttonName = positionButtonMap[positionKey]
	if not buttonName then
		warn("[PositionGuiUpdater] ⚠️ No se encontró el nombre del botón para:", positionKey)
		return nil
	end
	
	-- Buscar el botón recursivamente en Team_White
	local button = teamWhite:FindFirstChild(buttonName, true)
	
	if not button then
		-- Intentar buscar con diferentes variaciones del nombre
		warn("[PositionGuiUpdater] ⚠️ No se encontró el botón:", buttonName, "para posición:", positionKey)
		warn("[PositionGuiUpdater] 🔍 Buscando variaciones...")
		
		-- Listar todos los elementos en Team_White para depuración
		print("[PositionGuiUpdater] 📋 Elementos en Team_White:")
		for _, child in ipairs(teamWhite:GetDescendants()) do
			if child:IsA("GuiButton") or child:IsA("TextButton") or child:IsA("ImageButton") or child:IsA("Frame") then
				print("  -", child.Name, "(" .. child.ClassName .. ")")
			end
		end
		
		-- Intentar diferentes variaciones del nombre
		local variations = {
			buttonName,                                    -- Nombre original: "CF_white"
			buttonName:gsub("_", ""),                      -- Sin guion: "CFwhite"
			buttonName:upper(),                            -- Mayúsculas: "CF_WHITE"
			buttonName:lower(),                            -- Minúsculas: "cf_white"
			buttonName:gsub("_white", ""),                 -- Sin "_white": "CF"
			buttonName:gsub("_", " "),                     -- Con espacio: "CF white"
		}
		
		for _, variation in ipairs(variations) do
			button = teamWhite:FindFirstChild(variation, true)
			if button then
				print("[PositionGuiUpdater] ✅ Encontrado con nombre alternativo:", variation)
				break
			end
		end
		
		-- Si aún no se encuentra, buscar por coincidencia parcial
		if not button then
			for _, child in ipairs(teamWhite:GetDescendants()) do
				if (child:IsA("GuiButton") or child:IsA("TextButton") or child:IsA("ImageButton") or child:IsA("Frame")) then
					local childNameLower = child.Name:lower()
					local buttonNameLower = buttonName:lower()
					
					-- Buscar si el nombre contiene la clave de posición
					if childNameLower:find(buttonNameLower:gsub("_white", ""), 1, true) or 
					   childNameLower:find(buttonNameLower, 1, true) then
						print("[PositionGuiUpdater] ✅ Encontrado por coincidencia parcial:", child.Name)
						button = child
						break
					end
				end
			end
		end
	else
		print("[PositionGuiUpdater] ✅ Botón encontrado:", buttonName, "para posición:", positionKey)
	end
	
	return button
end

-- 📢 Escuchar cambios de posición desde el servidor
PositionChanged.OnClientEvent:Connect(function(positionKey, playerData)
	print("[PositionGuiUpdater] 📢 Evento recibido - Posición:", positionKey, "Jugador:", playerData and playerData.username or "nil")
	
	-- Buscar el botón correspondiente en la GUI
	local button = findPositionButton(positionKey)
	
	if not button then
		warn("[PositionGuiUpdater] ❌ No se encontró el botón para la posición:", positionKey)
		warn("[PositionGuiUpdater] 💡 Verifica que el botón exista en Team_White con el nombre correcto")
		return
	end
	
	if playerData and playerData.userId then
		-- Posición ocupada: crear ImageLabel con la foto del jugador
		print("[PositionGuiUpdater] 🖼️ Creando foto para:", playerData.username, "en posición:", positionKey)
		createPlayerPhotoOnButton(button, playerData.userId, playerData.username)
	else
		-- Posición liberada: eliminar ImageLabel
		print("[PositionGuiUpdater] 🗑️ Eliminando foto de posición:", positionKey)
		removePlayerPhotoFromButton(button)
	end
end)

print("[PositionGuiUpdater] ✅ Script inicializado para:", player.Name)

