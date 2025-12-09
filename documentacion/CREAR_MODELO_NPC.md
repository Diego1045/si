# 🤖 Cómo Crear un Modelo NPC en Roblox

## 📚 Introducción

Este documento explica cómo crear un modelo NPC (Non-Player Character) programáticamente en Roblox, específicamente para nuestro bot de portero.

---

## 🎯 Métodos para Crear NPCs

### Método 1: Clonar un Character Template (Recomendado)

El método más simple es clonar un modelo de personaje existente:

```lua
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")

-- Obtener el template del personaje
local templateCharacter = StarterPlayer:FindFirstChild("StarterCharacter")
if not templateCharacter then
    -- Si no existe en StarterPlayer, usar el Character de un jugador
    local testPlayer = Players:GetPlayers()[1]
    if testPlayer and testPlayer.Character then
        templateCharacter = testPlayer.Character
    else
        warn("No se encontró template de personaje")
        return
    end
end

-- Clonar el modelo
local botModel = templateCharacter:Clone()
botModel.Name = "GoalkeeperBot"
botModel.Parent = workspace

-- Configurar propiedades
local humanoid = botModel:FindFirstChild("Humanoid")
if humanoid then
    humanoid.Health = math.huge -- Nunca muere
    humanoid.MaxHealth = math.huge
    humanoid.WalkSpeed = 20 -- Velocidad normal
    humanoid.JumpPower = 50
end

-- Posicionar el modelo
local rootPart = botModel:FindFirstChild("HumanoidRootPart")
if rootPart then
    rootPart.CFrame = CFrame.new(0, 5, 0) -- Posición inicial
end

print("✅ Bot creado:", botModel.Name)
```

### Método 2: Crear Modelo desde Cero

Si necesitas crear un modelo completamente personalizado:

```lua
local botModel = Instance.new("Model")
botModel.Name = "GoalkeeperBot"
botModel.Parent = workspace

-- Crear HumanoidRootPart
local rootPart = Instance.new("Part")
rootPart.Name = "HumanoidRootPart"
rootPart.Size = Vector3.new(2, 2, 1)
rootPart.Position = Vector3.new(0, 5, 0)
rootPart.Anchored = false
rootPart.CanCollide = false
rootPart.Transparency = 1 -- Invisible
rootPart.Parent = botModel

-- Crear Humanoid
local humanoid = Instance.new("Humanoid")
humanoid.Health = math.huge
humanoid.MaxHealth = math.huge
humanoid.WalkSpeed = 20
humanoid.JumpPower = 50
humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
humanoid.Parent = botModel

-- Crear Head (necesario para que el Humanoid funcione)
local head = Instance.new("Part")
head.Name = "Head"
head.Size = Vector3.new(2, 1, 1)
head.Shape = Enum.PartType.Ball
head.BrickColor = BrickColor.new("Bright yellow")
head.Parent = botModel

-- Conectar Head al HumanoidRootPart (Motor6D)
local neck = Instance.new("Motor6D")
neck.Name = "Neck"
neck.Part0 = rootPart
neck.Part1 = head
neck.C0 = CFrame.new(0, 1, 0)
neck.Parent = rootPart

-- Configurar referencias del Humanoid
humanoid.RootPart = rootPart
humanoid.RequiresNeck = true

print("✅ Bot creado desde cero:", botModel.Name)
```

### Método 3: Usar Players:CreateLocalPlayer (Avanzado)

Este método crea un "jugador" virtual que puede usar todos los sistemas de Roblox:

```lua
local Players = game:GetService("Players")

-- Crear un jugador local (NPC)
local botPlayer = Players:CreateLocalPlayer(0) -- 0 = sin UserId real
botPlayer.Name = "GoalkeeperBot"
botPlayer.DisplayName = "Portero Bot"

-- Configurar propiedades antes de spawnear
botPlayer.CharacterAppearanceId = 0 -- Usar apariencia por defecto

-- Spawnear el personaje
botPlayer:LoadCharacter()

-- Esperar a que se cargue
local character = botPlayer.CharacterAdded:Wait()

-- Configurar como NPC
local humanoid = character:WaitForChild("Humanoid")
if humanoid then
    humanoid.Health = math.huge
    humanoid.MaxHealth = math.huge
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
end

-- Posicionar
local rootPart = character:WaitForChild("HumanoidRootPart")
rootPart.CFrame = CFrame.new(0, 5, 0)

print("✅ Bot creado con CreateLocalPlayer:", botPlayer.Name)
```

---

## 🔧 Configuración de Propiedades del NPC

### Propiedades Importantes del Humanoid

```lua
local humanoid = botModel:FindFirstChild("Humanoid")

-- Salud
humanoid.Health = math.huge -- Nunca muere
humanoid.MaxHealth = math.huge

-- Movimiento
humanoid.WalkSpeed = 20 -- Velocidad normal (16 es por defecto)
humanoid.JumpPower = 50 -- Poder de salto
humanoid.HipHeight = 2 -- Altura de la cadera

-- Apariencia
humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None -- Sin nombre
humanoid.NameOcclusion = Enum.NameOcclusion.NoOcclusion -- Nombre siempre visible

-- Estado
humanoid.Sit = false -- No sentarse
humanoid.PlatformStand = false -- No estar en plataforma

-- IA
humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false) -- No puede morir
humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) -- No caer
```

### Propiedades Importantes del HumanoidRootPart

```lua
local rootPart = botModel:FindFirstChild("HumanoidRootPart")

-- Física
rootPart.Anchored = false -- Debe poder moverse
rootPart.CanCollide = true -- Puede colisionar (a menos que uses Pathfinding)
rootPart.CanTouch = true -- Puede tocar cosas

-- Apariencia
rootPart.Transparency = 1 -- Hacer invisible (opcional)
rootPart.CanQuery = true -- Para raycasts
```

---

## 🎮 Controlar el NPC

### Usar Humanoid:MoveTo() (Simple)

```lua
local humanoid = botModel:FindFirstChild("Humanoid")
local targetPosition = Vector3.new(10, 5, 10)

-- Mover hacia una posición
humanoid:MoveTo(targetPosition)

-- Esperar a que llegue
humanoid.MoveToFinished:Wait()
print("Bot llegó al destino")
```

### Usar PathfindingService (Avanzado)

```lua
local PathfindingService = game:GetService("PathfindingService")
local humanoid = botModel:FindFirstChild("Humanoid")
local rootPart = botModel:FindFirstChild("HumanoidRootPart")

-- Crear objeto pathfinding
local path = PathfindingService:CreatePath({
    AgentRadius = 2, -- Radio del agente
    AgentHeight = 5, -- Altura del agente
    AgentCanJump = true, -- Puede saltar
    Costs = { -- Costos personalizados
        Water = 10, -- Penalizar agua
    }
})

local function moveToPosition(targetPosition)
    local success, errorMessage = pcall(function()
        -- Calcular ruta
        path:ComputeAsync(rootPart.Position, targetPosition)
    end)
    
    if not success then
        warn("Error al calcular ruta:", errorMessage)
        return false
    end
    
    -- Obtener waypoints
    local waypoints = path:GetWaypoints()
    
    if #waypoints < 2 then
        warn("No hay ruta disponible")
        return false
    end
    
    -- Mover a través de los waypoints
    for i = 2, #waypoints do
        local waypoint = waypoints[i]
        
        humanoid:MoveTo(waypoint.Position)
        
        -- Esperar a que llegue al waypoint
        local finished = false
        local connection
        connection = humanoid.MoveToFinished:Connect(function(reached)
            finished = true
            if connection then connection:Disconnect() end
        end)
        
        -- Timeout de seguridad
        task.delay(5, function()
            if not finished then
                finished = true
                if connection then connection:Disconnect() end
            end
        end)
        
        repeat
            task.wait(0.1)
        until finished
        
        -- Saltar si es necesario
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
            task.wait(0.3) -- Esperar a que salte
        end
    end
    
    return true
end

-- Usar
moveToPosition(Vector3.new(50, 5, 50))
```

---

## 🔍 Detección y Raycasting

### Detectar Objetos Cerca

```lua
local function findObjectsNearby(position, radius, objectName)
    local objects = {}
    
    for _, object in ipairs(workspace:GetDescendants()) do
        if object.Name == objectName and object:IsA("BasePart") then
            local distance = (object.Position - position).Magnitude
            if distance <= radius then
                table.insert(objects, {
                    object = object,
                    distance = distance
                })
            end
        end
    end
    
    -- Ordenar por distancia
    table.sort(objects, function(a, b)
        return a.distance < b.distance
    end)
    
    return objects
end

-- Usar
local nearbyBalls = findObjectsNearby(rootPart.Position, 20, "Ball")
if #nearbyBalls > 0 then
    print("Balón encontrado a", nearbyBalls[1].distance, "studs")
end
```

### Raycasting para Visión

```lua
local function canSeeTarget(origin, target, ignoreList)
    ignoreList = ignoreList or {}
    
    local direction = (target - origin).Unit
    local distance = (target - origin).Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = ignoreList
    
    local raycastResult = workspace:Raycast(origin, direction * distance, raycastParams)
    
    if raycastResult then
        -- Hay algo en el camino
        return false, raycastResult
    else
        -- Puede ver el objetivo
        return true, nil
    end
end

-- Usar
local canSee, hit = canSeeTarget(
    rootPart.Position,
    ball.Position,
    {botModel} -- Ignorar el propio bot
)

if canSee then
    print("El bot puede ver el balón")
else
    print("El balón está bloqueado por:", hit.Instance.Name)
end
```

---

## 🧹 Limpieza y Eliminación

### Eliminar el NPC Correctamente

```lua
local function removeBot(botModel)
    -- Detener todas las conexiones
    -- (guardar referencias de conexiones para desconectarlas)
    
    -- Remover del workspace
    if botModel and botModel.Parent then
        botModel:Destroy()
    end
    
    print("Bot eliminado")
end

-- También limpiar si se elimina el script
script.Parent.AncestryChanged:Connect(function()
    if not script.Parent.Parent then
        -- El script fue eliminado, limpiar el bot
        if botModel and botModel.Parent then
            removeBot(botModel)
        end
    end
end)
```

---

## 📋 Estructura Completa de un NPC Básico

```lua
-- GoalkeeperBot_Creation.server.lua
-- Ubicación: ServerScriptService

local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")

-- Función para crear el bot
local function createGoalkeeperBot()
    -- Obtener template
    local templateCharacter = StarterPlayer:FindFirstChild("StarterCharacter")
    if not templateCharacter then
        warn("No se encontró StarterCharacter")
        return nil
    end
    
    -- Clonar
    local botModel = templateCharacter:Clone()
    botModel.Name = "GoalkeeperBot"
    botModel.Parent = workspace
    
    -- Configurar
    local humanoid = botModel:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Health = math.huge
        humanoid.MaxHealth = math.huge
        humanoid.WalkSpeed = 20
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end
    
    local rootPart = botModel:FindFirstChild("HumanoidRootPart")
    if rootPart then
        -- Posicionar en la portería
        local goalPosition = workspace:FindFirstChild("GK_White.R", true)
        if goalPosition then
            rootPart.CFrame = goalPosition.CFrame
        else
            rootPart.CFrame = CFrame.new(0, 5, 0)
        end
    end
    
    -- Agregar atributo para identificar
    botModel:SetAttribute("IsNPC", true)
    botModel:SetAttribute("BotType", "Goalkeeper")
    
    print("✅ Bot de portero creado:", botModel.Name)
    return botModel
end

-- Crear el bot al iniciar
local botModel = createGoalkeeperBot()

-- Mantener referencia global (opcional)
_G.GoalkeeperBot = botModel

return botModel
```

---

## ⚠️ Notas Importantes

1. **Network Ownership**: Los NPCs no tienen Network Ownership automática. Si necesitas que el servidor controle completamente su física, no asignes Network Ownership.

2. **Replicación**: Los NPCs solo existen en el servidor. Para que los clientes los vean, deben estar en el workspace.

3. **Performance**: Muchos NPCs pueden afectar el rendimiento. Limita la cantidad y optimiza sus scripts.

4. **Collision Groups**: Considera usar PhysicsService para separar NPCs de jugadores si es necesario.

5. **Spawn Point**: Los NPCs no usan SpawnPoints. Posiciónalos manualmente.

---

## 🔗 Referencias

- **Documentación de Roblox**: Humanoid, PathfindingService
- **Proyecto**: `documentacion/BOT_PORTERO_MODELO.md`

---

¡Ahora puedes crear NPCs programáticamente en Roblox! 🤖

