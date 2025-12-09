# 🥅 Bot de Portero - Sistema con Modelo R6 y Animaciones

## 📚 Introducción

Este documento explica cómo crear un bot de portero que funcione como un **modelo NPC R6** (Non-Player Character) en Roblox, con capacidad para reproducir animaciones al **tirarse (atajar)** y al **disparar (patear)** el balón.

**Importante:** El modelo puede ser **R6** (el modelo clásico de Roblox con 6 partes), que es perfectamente compatible con animaciones y NPCs.

---

## 🎯 Conceptos Clave

### 1. **Modelo R6 vs Jugador Real**

Un bot de portero debe ser un **Modelo R6** en el workspace, NO un jugador real:
- Un **Modelo R6** tiene `Humanoid` y partes clásicas (Head, Torso, Arms, Legs)
- Se controla completamente desde el servidor
- No requiere un cliente conectado
- Puede usar `PathfindingService` para moverse
- **R6 es perfecto para NPCs** - simple, ligero y funcional

### 2. **Estructura del Modelo R6**

El modelo **R6** tiene 6 partes principales:

```
Model (GoalkeeperBot) - R6
├── Humanoid
│   ├── WalkSpeed (velocidad de movimiento)
│   ├── JumpPower (poder de salto)
│   └── Health (vida)
├── HumanoidRootPart (parte invisible para posición)
├── Head
├── Torso (parte principal del cuerpo)
│   ├── Left Shoulder (Motor6D)
│   ├── Right Shoulder (Motor6D)
│   ├── Left Hip (Motor6D)
│   ├── Right Hip (Motor6D)
│   └── Neck (Motor6D)
├── Left Arm
├── Right Arm
├── Left Leg
└── Right Leg
```

**Características de R6:**
- ✅ Modelo clásico y simple (6 partes vs 15 en R15)
- ✅ Más ligero en rendimiento
- ✅ Perfecto para NPCs y bots
- ✅ Animaciones funcionan perfectamente
- ✅ Compatible con todos los sistemas de Roblox

---

## 🎬 Sistema de Animaciones con R6

### Cómo Cargar y Reproducir Animaciones en R6

Las animaciones funcionan **exactamente igual** en R6 que en R15. Basándonos en el código existente del proyecto:

#### **Paso 1: Crear el Objeto Animation**

```lua
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://123456789" -- ID de la animación
```

#### **Paso 2: Cargar la Animación en el Humanoid**

```lua
local humanoid = botModel:FindFirstChild("Humanoid")
local animationTrack = humanoid:LoadAnimation(animation)
```

#### **Paso 3: Configurar Propiedades de la Animación**

```lua
animationTrack.Priority = Enum.AnimationPriority.Action -- Prioridad alta
animationTrack.Looped = false -- No repetir (para animaciones de acción)
```

#### **Paso 4: Reproducir la Animación**

```lua
animationTrack:Play()
```

#### **Paso 5: Detectar cuando Termina**

```lua
animationTrack.Stopped:Connect(function()
    print("Animación terminada")
    -- Restaurar velocidad de movimiento, etc.
end)
```

**Las animaciones automáticamente se aplican a las partes R6 (Torso, Arms, Legs, Head) a través de los Motor6D.**

---

## ⚽ Animaciones para el Portero R6

### 1. **Animación de Ataque (Tirarse)**

**Cuándo reproducir:**
- Cuando el balón se acerca a la portería
- Cuando el balón está en trayectoria hacia el gol
- Cuando necesita interceptar el balón

**Ejemplo de código:**

```lua
-- ID de animación de ataque (necesitas proporcionar el ID real)
local DIVE_ANIMATION_ID = "rbxassetid://123456789"

local diveAnimation = Instance.new("Animation")
diveAnimation.AnimationId = DIVE_ANIMATION_ID

local diveTrack = humanoid:LoadAnimation(diveAnimation)
diveTrack.Priority = Enum.AnimationPriority.Action
diveTrack.Looped = false

-- Función para ejecutar el ataque
local function performDive(direction)
    -- Detener movimiento
    local originalSpeed = humanoid.WalkSpeed
    humanoid.WalkSpeed = 0
    
    -- Rotar hacia la dirección del balón
    local rootPart = botModel:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local lookDirection = direction.Unit
        rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + lookDirection)
    end
    
    -- Reproducir animación (funciona con partes R6)
    diveTrack:Play()
    
    -- Mover hacia la dirección (simular el salto)
    task.spawn(function()
        for i = 1, 10 do
            if rootPart then
                rootPart.CFrame = rootPart.CFrame + (direction.Unit * 2)
            end
            task.wait(0.05)
        end
    end)
    
    -- Restaurar velocidad cuando termine
    diveTrack.Stopped:Connect(function()
        humanoid.WalkSpeed = originalSpeed
    end)
end
```

### 2. **Animación de Disparo (Patear)**

**Cuándo reproducir:**
- Cuando el portero tiene el balón conectado (weld)
- Cuando necesita despejar el balón
- Cuando dispara el balón lejos de la portería

**Ejemplo de código:**

```lua
-- ID de animación de disparo (necesitas proporcionar el ID real)
local KICK_ANIMATION_ID = "rbxassetid://987654321"

local kickAnimation = Instance.new("Animation")
kickAnimation.AnimationId = KICK_ANIMATION_ID

local kickTrack = humanoid:LoadAnimation(kickAnimation)
kickTrack.Priority = Enum.AnimationPriority.Action
kickTrack.Looped = false

-- Función para ejecutar el disparo
local function performKick(cameraDirection, powerValue)
    -- Verificar si tiene el balón
    if not hasBall then
        return
    end
    
    -- Detener movimiento
    local originalSpeed = humanoid.WalkSpeed
    humanoid.WalkSpeed = 0
    
    -- Reproducir animación (funciona con partes R6)
    kickTrack:Play()
    
    -- Enviar evento al servidor para patear (igual que los jugadores)
    local kickEvent = ReplicatedStorage:FindFirstChild("kick event")
    if kickEvent then
        -- El servidor manejará la física del balón
        -- Nota: Esto requiere modificar BallMotor.server.lua para aceptar NPCs
    end
    
    -- Restaurar velocidad cuando termine
    kickTrack.Stopped:Connect(function()
        humanoid.WalkSpeed = originalSpeed
    end)
end
```

---

## 🤖 Crear Bot R6 Programáticamente

### Método 1: Clonar StarterCharacter R6 (Recomendado)

**Primero, configura R6 en Roblox Studio:**
1. Ve a **StarterPlayer** > **StarterCharacter**
2. En **Properties**, cambia **RigType** a **"R6"**
3. Guarda el juego

**Luego, clonar el modelo R6:**

```lua
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")

-- Obtener el template R6
local templateCharacter = StarterPlayer:FindFirstChild("StarterCharacter")
if not templateCharacter then
    -- Fallback: usar Character de un jugador
    local testPlayer = Players:GetPlayers()[1]
    if testPlayer and testPlayer.Character then
        templateCharacter = testPlayer.Character
    else
        warn("No se encontró template de personaje")
        return
    end
end

-- Verificar que sea R6 (tiene "Torso" en lugar de "UpperTorso")
local isR6 = templateCharacter:FindFirstChild("Torso") ~= nil
if not isR6 then
    warn("⚠️ El modelo no es R6. Cambia RigType a R6 en StarterCharacter")
    return
end

-- Clonar el modelo R6
local botModel = templateCharacter:Clone()
botModel.Name = "GoalkeeperBot"
botModel.Parent = workspace

-- Posicionar en la portería
local goalkeeperPosition = workspace:FindFirstChild("GK_White.R", true)
if goalkeeperPosition then
    local rootPart = botModel:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = goalkeeperPosition.CFrame
    end
end

-- Configurar como NPC (no muere, etc.)
local humanoid = botModel:FindFirstChild("Humanoid")
if humanoid then
    humanoid.Health = math.huge -- Nunca muere
    humanoid.MaxHealth = math.huge
    humanoid.WalkSpeed = 20 -- Velocidad normal
    humanoid.JumpPower = 50
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None -- Sin nombre
end

-- Configurar atributos
botModel:SetAttribute("IsNPC", true)
botModel:SetAttribute("BotType", "Goalkeeper")
botModel:SetAttribute("ModelType", "R6")

print("✅ Bot R6 creado:", botModel.Name)
```

### Método 2: Usar Players:CreateLocalPlayer (Avanzado)

```lua
local Players = game:GetService("Players")

-- Crear un "jugador" local (NPC)
local botPlayer = Players:CreateLocalPlayer(0) -- 0 = sin UserId
botPlayer.Name = "GoalkeeperBot"

-- IMPORTANTE: Configurar como R6 antes de spawnear
-- (Requiere configuración especial, ver documentación de Roblox)

-- Spawnear el personaje
botPlayer:LoadCharacter()

-- Configurar propiedades
local character = botPlayer.Character
if character then
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        humanoid.Health = math.huge
        humanoid.MaxHealth = math.huge
    end
end
```

**Recomendación:** Usa el Método 1 (clonar StarterCharacter R6) - es más simple y confiable.

---

## 🎯 Sistema de Detección del Balón

### Cómo Detectar cuando el Balón se Acerca

Basándonos en el código existente (`BallMotor.server.lua` y `GoalDetector.server.lua`):

```lua
local RunService = game:GetService("RunService")
local ball = workspace:WaitForChild("Ball")

local function getBallPosition()
    if ball:IsA("BasePart") then
        return ball.Position
    elseif ball:IsA("Model") then
        local ballPart = ball:FindFirstChildWhichIsA("BasePart", true)
        return ballPart and ballPart.Position or nil
    end
    return nil
end

local function getDistanceToBall(botPosition)
    local ballPos = getBallPosition()
    if not ballPos then return math.huge end
    
    return (botPosition - ballPos).Magnitude
end

-- Monitorear constantemente
RunService.Heartbeat:Connect(function()
    local rootPart = botModel:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local distance = getDistanceToBall(rootPart.Position)
    local DIVE_THRESHOLD = 15 -- Distancia para activar el ataque
    
    if distance < DIVE_THRESHOLD then
        -- Calcular dirección hacia el balón
        local ballPos = getBallPosition()
        if ballPos then
            local direction = (ballPos - rootPart.Position)
            local ballVelocity = ball.AssemblyLinearVelocity or ball.Velocity
            
            -- Verificar si el balón viene hacia la portería
            if ballVelocity and ballVelocity.Magnitude > 10 then -- Balón en movimiento
                performDive(direction)
            end
        end
    end
end)
```

---

## 🚶 Sistema de Movimiento (Pathfinding)

### Usar PathfindingService para Mover el Bot R6

```lua
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

local humanoid = botModel:FindFirstChild("Humanoid")
local rootPart = botModel:FindFirstChild("HumanoidRootPart")

-- Crear objeto pathfinding
local path = PathfindingService:CreatePath({
    AgentRadius = 2,
    AgentHeight = 5,
    AgentCanJump = true
})

local function moveToPosition(targetPosition)
    local success, errorMessage = pcall(function()
        path:ComputeAsync(rootPart.Position, targetPosition)
    end)
    
    if not success then
        warn("Error al calcular ruta:", errorMessage)
        return
    end
    
    local waypoints = path:GetWaypoints()
    
    for i, waypoint in ipairs(waypoints) do
        humanoid:MoveTo(waypoint.Position)
        humanoid.MoveToFinished:Wait()
        
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end
    end
end

-- Mover hacia el balón cuando está cerca
local function followBall()
    local ballPos = getBallPosition()
    if ballPos then
        -- Posición objetivo: intercepción del balón
        moveToPosition(ballPos)
    end
end
```

---

## 🔗 Integración con el Sistema de Balón

### Cómo Conectar el Bot R6 con el Sistema Existente

El bot debe poder:
1. **Tomar el balón** (usar el evento `wel ball`)
2. **Patear el balón** (usar el evento `kick event`)
3. **Verificar si tiene el balón** (usar el atributo `hasBall`)

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Evento para tomar el balón
local weldBallEvent = ReplicatedStorage:FindFirstChild("wel ball")

-- Función para que el bot tome el balón
local function botTakeBall()
    local distance = getDistanceToBall(rootPart.Position)
    if distance <= 12 then -- Rango para tomar el balón (igual que jugadores)
        -- Simular el evento que enviarían los jugadores
        -- Nota: Esto requiere modificar BallMotor.server.lua para aceptar NPCs
        if weldBallEvent then
            -- Crear una función especial en el servidor para NPCs
            -- O modificar el sistema para aceptar modelos además de jugadores
        end
    end
end

-- Verificar si el bot tiene el balón
local function botHasBall()
    -- Revisar si el balón está conectado al modelo
    local ballMotor = rootPart:FindFirstChild("BallMotor")
    return ballMotor ~= nil
end
```

**Nota:** Necesitarás modificar `BallMotor.server.lua` para que acepte modelos R6 además de jugadores.

---

## 📋 Estructura del Script del Bot R6

### Script Completo de Ejemplo (GoalkeeperBot.server.lua)

```lua
-- 🥅 GoalkeeperBot.server.lua
-- Ubicación: ServerScriptService o dentro del modelo
-- Requiere: Modelo R6 configurado en StarterCharacter

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local StarterPlayer = game:GetService("StarterPlayer")

-- Configuración
local BALL_NAME = "Ball"
local GOALKEEPER_POSITION = "GK_White.R"
local DIVE_THRESHOLD = 15 -- Distancia para activar ataque
local INTERCEPT_DISTANCE = 20 -- Distancia para moverse hacia el balón

-- IDs de animaciones (REEMPLAZAR con IDs reales)
local DIVE_ANIMATION_ID = "rbxassetid://123456789"
local KICK_ANIMATION_ID = "rbxassetid://987654321"

-- Variables
local botModel = nil
local humanoid = nil
local rootPart = nil
local ball = workspace:WaitForChild(BALL_NAME)

-- Cargar animaciones
local diveAnimation = Instance.new("Animation")
diveAnimation.AnimationId = DIVE_ANIMATION_ID

local kickAnimation = Instance.new("Animation")
kickAnimation.AnimationId = KICK_ANIMATION_ID

-- Funciones auxiliares
local function createBotR6()
    local templateCharacter = StarterPlayer:FindFirstChild("StarterCharacter")
    if not templateCharacter then
        warn("No se encontró StarterCharacter")
        return nil
    end
    
    -- Verificar que sea R6
    if not templateCharacter:FindFirstChild("Torso") then
        warn("⚠️ StarterCharacter no es R6. Cambia RigType a R6")
        return nil
    end
    
    -- Clonar
    local model = templateCharacter:Clone()
    model.Name = "GoalkeeperBot"
    model.Parent = workspace
    
    -- Configurar
    local hum = model:FindFirstChild("Humanoid")
    if hum then
        hum.Health = math.huge
        hum.MaxHealth = math.huge
        hum.WalkSpeed = 20
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end
    
    -- Posicionar
    local goalPos = workspace:FindFirstChild(GOALKEEPER_POSITION, true)
    if goalPos then
        local rp = model:FindFirstChild("HumanoidRootPart")
        if rp then
            rp.CFrame = goalPos.CFrame
        end
    end
    
    return model
end

local function getBallPosition()
    if ball:IsA("BasePart") then
        return ball.Position
    elseif ball:IsA("Model") then
        local ballPart = ball:FindFirstChildWhichIsA("BasePart", true)
        return ballPart and ballPart.Position or nil
    end
    return nil
end

local diveTrack = nil
local kickTrack = nil

local function initializeAnimations()
    if not humanoid then return end
    
    diveTrack = humanoid:LoadAnimation(diveAnimation)
    diveTrack.Priority = Enum.AnimationPriority.Action
    
    kickTrack = humanoid:LoadAnimation(kickAnimation)
    kickTrack.Priority = Enum.AnimationPriority.Action
end

local function performDive(direction)
    if not diveTrack or diveTrack.IsPlaying then return end
    
    local originalSpeed = humanoid.WalkSpeed
    humanoid.WalkSpeed = 0
    
    if rootPart then
        local lookDirection = direction.Unit
        rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + lookDirection)
    end
    
    diveTrack:Play()
    
    diveTrack.Stopped:Connect(function()
        humanoid.WalkSpeed = originalSpeed
    end)
end

-- Crear el bot
botModel = createBotR6()
if botModel then
    humanoid = botModel:WaitForChild("Humanoid")
    rootPart = botModel:WaitForChild("HumanoidRootPart")
    initializeAnimations()
end

-- Sistema principal
local isDiving = false

RunService.Heartbeat:Connect(function()
    if not (botModel and humanoid and rootPart) then return end
    if isDiving then return end
    
    local ballPos = getBallPosition()
    if not ballPos then return end
    
    local distance = (rootPart.Position - ballPos).Magnitude
    local direction = (ballPos - rootPart.Position)
    
    if distance < DIVE_THRESHOLD then
        local ballVelocity = ball.AssemblyLinearVelocity or ball.Velocity
        if ballVelocity and ballVelocity.Magnitude > 10 then
            isDiving = true
            performDive(direction)
            task.wait(1) -- Cooldown
            isDiving = false
        end
    end
end)

print("✅ Bot de portero R6 inicializado")
```

---

## ⚠️ Consideraciones Importantes

### 1. **Modificar BallMotor.server.lua**

El sistema actual solo acepta `Player` objects. Para que funcione con NPCs R6, necesitas modificar:

```lua
-- En BallMotor.server.lua, cambiar:
local function welBallFunction(player)
    -- Para aceptar tanto jugadores como modelos R6
    local function welBallFunction(entity) -- entity puede ser Player o Model
        local character = entity.Character or entity -- Si es Player, usa .Character; si es Model, usa directamente
        
        -- Verificar que tenga Humanoid (tanto jugadores como NPCs R6)
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        -- Resto del código...
```

### 2. **Verificar Estructura R6**

Asegúrate de que el modelo tenga todas las partes R6 necesarias:

```lua
local function verifyR6Structure(model)
    local requiredParts = {
        "Head", "Torso", "Left Arm", "Right Arm",
        "Left Leg", "Right Leg", "HumanoidRootPart"
    }
    
    for _, partName in ipairs(requiredParts) do
        if not model:FindFirstChild(partName) then
            warn("⚠️ Falta parte R6:", partName)
            return false
        end
    end
    return true
end
```

---

## 🎨 Personalización

### Configuración de Velocidades

```lua
humanoid.WalkSpeed = 20 -- Velocidad normal
humanoid.WalkSpeed = 30 -- Velocidad al perseguir balón
humanoid.WalkSpeed = 0 -- Detener durante animaciones
```

### Configuración de Ranges

```lua
local DIVE_RANGE = 15 -- Distancia para atacar
local FOLLOW_RANGE = 25 -- Distancia para seguir
local INTERCEPT_RANGE = 20 -- Distancia para interceptar
```

### 🎩 Agregar Hats/Accesorios al Bot R6

**¿Los hats afectan el funcionamiento del bot?**
**No, los hats NO afectan el funcionamiento del bot.** Se conectan al `Head` mediante `Attachment` y son completamente visuales. No interfieren con:
- ✅ Animaciones (tirarse, disparar)
- ✅ Movimiento (Pathfinding, WalkSpeed)
- ✅ Sistema de balón
- ✅ Humanoid
- ✅ Motor6D

#### Método 1: Agregar Hat desde el Catálogo

```lua
local function addHatToBot(botModel, hatAssetId)
    -- hatAssetId es el ID del hat de la tienda de Roblox
    -- Ejemplo: "rbxassetid://123456789"
    
    local head = botModel:FindFirstChild("Head")
    if not head then
        warn("No se encontró Head en el bot")
        return
    end
    
    -- Insertar el hat desde el catálogo
    local hat = game:GetService("InsertService"):LoadAsset(hatAssetId):GetChildren()[1]
    if hat then
        -- Clonar para evitar conflictos
        hat = hat:Clone()
        hat.Parent = botModel
        
        -- El Attachment se conecta automáticamente al Head
        print("✅ Hat agregado:", hat.Name)
        return hat
    else
        warn("No se pudo cargar el hat")
        return nil
    end
end

-- Usar
-- Reemplaza 123456789 con el ID real del hat
addHatToBot(botModel, 123456789)
```

#### Método 2: Crear Hat Manualmente (Personalizado)

```lua
local function createCustomHat(botModel, hatPart, position, rotation)
    -- hatPart: Una Part o MeshPart que será el hat
    -- position: Vector3 offset desde el centro del Head
    -- rotation: CFrame rotation (opcional)
    
    local head = botModel:FindFirstChild("Head")
    if not head then
        warn("No se encontró Head")
        return
    end
    
    -- Crear Attachment en el Head (donde se conectará el hat)
    local hatAttachment = Instance.new("Attachment")
    hatAttachment.Name = "HatAttachment"
    hatAttachment.Position = position or Vector3.new(0, 0.5, 0) -- Arriba del Head
    hatAttachment.Parent = head
    
    -- Crear Attachment en el hat
    local hatPartAttachment = Instance.new("Attachment")
    hatPartAttachment.Name = "HatAttachment"
    hatPartAttachment.Position = Vector3.new(0, 0, 0) -- Centro del hat
    hatPartAttachment.Parent = hatPart
    
    -- Conectar con AlignPosition (para que siga al Head)
    local alignPosition = Instance.new("AlignPosition")
    alignPosition.Attachment0 = hatAttachment
    alignPosition.Attachment1 = hatPartAttachment
    alignPosition.MaxForce = math.huge
    alignPosition.Responsiveness = 200
    alignPosition.Parent = hatPart
    
    -- Conectar con AlignOrientation (para que rote con el Head)
    local alignOrientation = Instance.new("AlignOrientation")
    alignOrientation.Attachment0 = hatAttachment
    alignOrientation.Attachment1 = hatPartAttachment
    alignOrientation.MaxTorque = math.huge
    alignOrientation.Responsiveness = 200
    if rotation then
        alignOrientation.CFrame = rotation
    end
    alignOrientation.Parent = hatPart
    
    -- Agregar el hat al modelo
    hatPart.Parent = botModel
    hatPart.Name = "Hat"
    
    print("✅ Hat personalizado agregado")
    return hatPart
end

-- Ejemplo: Crear un sombrero simple
local function createSimpleHat(botModel)
    local hatPart = Instance.new("Part")
    hatPart.Name = "GoalkeeperCap"
    hatPart.Size = Vector3.new(2, 0.5, 2)
    hatPart.Shape = Enum.PartType.Cylinder
    hatPart.BrickColor = BrickColor.new("Bright yellow")
    hatPart.Material = Enum.Material.Fabric
    hatPart.CanCollide = false
    hatPart.Anchored = false
    
    createCustomHat(botModel, hatPart, Vector3.new(0, 0.5, 0))
end

-- Usar
createSimpleHat(botModel)
```

#### Método 3: Usar Hat Existente del StarterCharacter

Si el `StarterCharacter` ya tiene hats, se clonarán automáticamente:

```lua
-- Al clonar el StarterCharacter, los hats se clonan también
local botModel = StarterCharacter:Clone()
botModel.Name = "GoalkeeperBot"
botModel.Parent = workspace

-- Los hats del StarterCharacter ya estarán en el bot
-- Verificar
local hats = {}
for _, child in ipairs(botModel:GetChildren()) do
    if child:IsA("Accessory") or child.Name:find("Hat") then
        table.insert(hats, child)
    end
end

print("Hats encontrados:", #hats)
```

#### Verificar Hats en el Bot

```lua
local function getBotHats(botModel)
    local hats = {}
    
    -- Buscar Accessories (forma moderna de hats)
    for _, child in ipairs(botModel:GetChildren()) do
        if child:IsA("Accessory") then
            table.insert(hats, child)
        end
    end
    
    -- Buscar partes que podrían ser hats (por nombre)
    local head = botModel:FindFirstChild("Head")
    if head then
        for _, attachment in ipairs(head:GetChildren()) do
            if attachment:IsA("Attachment") and attachment.Name:find("Hat") then
                -- Buscar la parte conectada a este attachment
                for _, part in ipairs(botModel:GetDescendants()) do
                    if part:IsA("BasePart") and part:FindFirstChild("HatAttachment") then
                        table.insert(hats, part)
                    end
                end
            end
        end
    end
    
    return hats
end

-- Usar
local botHats = getBotHats(botModel)
print("El bot tiene", #botHats, "hats")
```

#### Ejemplo Completo: Agregar Casco de Portero

```lua
local function addGoalkeeperCap(botModel, assetId)
    -- assetId: ID del hat de la tienda (opcional)
    
    if assetId then
        -- Usar hat de la tienda
        return addHatToBot(botModel, assetId)
    else
        -- Crear casco simple personalizado
        local cap = Instance.new("Part")
        cap.Name = "GoalkeeperCap"
        cap.Size = Vector3.new(2.2, 0.6, 2.2)
        cap.Shape = Enum.PartType.Cylinder
        cap.BrickColor = BrickColor.new("Bright yellow")
        cap.Material = Enum.Material.Plastic
        cap.CanCollide = false
        cap.TopSurface = Enum.SurfaceType.Smooth
        cap.BottomSurface = Enum.SurfaceType.Smooth
        
        -- Crear visera
        local visor = Instance.new("Part")
        visor.Name = "Visor"
        visor.Size = Vector3.new(2.2, 0.1, 1)
        visor.BrickColor = BrickColor.new("Black")
        visor.Material = Enum.Material.Plastic
        visor.CanCollide = false
        visor.Parent = cap
        
        -- Conectar visera al cap
        local visorMotor = Instance.new("Motor6D")
        visorMotor.Name = "VisorMotor"
        visorMotor.Part0 = cap
        visorMotor.Part1 = visor
        visorMotor.C0 = CFrame.new(0, -0.25, 0.5) * CFrame.Angles(math.rad(-15), 0, 0)
        visorMotor.Parent = cap
        
        -- Agregar el hat al bot
        createCustomHat(botModel, cap, Vector3.new(0, 0.6, 0))
        return cap
    end
end

-- Usar
addGoalkeeperCap(botModel) -- Con hat personalizado
-- O
addGoalkeeperCap(botModel, 123456789) -- Con ID de la tienda
```

---

## 📚 Referencias del Proyecto

- **Sistema de Balón**: `src/balon/BallMotor.server.lua`
- **Sistema de Estados**: `player_state_system.lua`
- **Animaciones**: `src/client/BallWeld.client.lua` (líneas 32-45)
- **Sistema de Portería**: `src/server/GoalDetector.server.lua`
- **Posiciones**: `src/server/PositionManager.server.lua`
- **Guía R6**: `documentacion/MODELO_R6_BOT.md`

---

## 🚀 Próximos Pasos

1. **Configurar R6 en tu juego:**
   - Ve a **StarterPlayer** > **StarterCharacter**
   - Cambia **RigType** a **"R6"**
   - Guarda el juego

2. **Crear el modelo del portero R6** (clonar StarterCharacter o crear manualmente)

3. **Obtener IDs de animaciones** de tirarse y disparar (funcionan con R6)

4. **Implementar el script del bot** siguiendo esta guía

5. **Modificar BallMotor.server.lua** para aceptar NPCs además de jugadores

6. **Probar y ajustar** los rangos y velocidades

---

## ❓ Preguntas Frecuentes

**P: ¿R6 funciona con todas las animaciones?**
R: Sí, las animaciones funcionan perfectamente en R6. Roblox convierte automáticamente las animaciones al formato correcto.

**P: ¿El bot puede morir?**
R: Configura `humanoid.Health = math.huge` para que nunca muera, o implementa un sistema de respawn.

**P: ¿Cómo sincronizo las animaciones en todos los clientes?**
R: Usa RemoteEvents para notificar a los clientes cuando el bot reproduce animaciones.

**P: ¿Puedo mezclar R6 y R15 en el mismo juego?**
R: Sí, puedes tener jugadores con R15 y bots con R6 al mismo tiempo.

**P: ¿Los hats afectan el funcionamiento del bot?**
R: No, los hats son completamente visuales y se conectan al `Head` mediante `Attachment`. No afectan animaciones, movimiento, ni el sistema de balón. Puedes agregar todos los hats que quieras.

---

## 📝 Nota sobre R6

**R6 es perfecto para bots:**
- ✅ Modelo clásico más simple
- ✅ 6 partes principales (vs 15 en R15)
- ✅ Más ligero en rendimiento
- ✅ Animaciones funcionan igual que R15
- ✅ Recomendado para NPCs

---

¡Buena suerte creando tu bot de portero R6! 🥅⚽

