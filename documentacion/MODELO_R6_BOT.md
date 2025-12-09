# 🤖 Modelo R6 para Bot de Portero

## 📚 Introducción

Este documento explica cómo usar un **modelo R6** (RigType 6) para crear el bot de portero. R6 es el modelo clásico de Roblox y es perfecto para NPCs.

---

## 🎯 ¿Qué es R6?

**R6** es el modelo clásico de Roblox con **6 partes principales**:

```
R6 Model Structure:
├── Head
├── Torso (parte principal del cuerpo)
├── Left Arm
├── Right Arm
├── Left Leg
└── Right Leg
```

**Características:**
- Modelo clásico y simple
- 6 partes principales (vs 15 partes en R15)
- Más ligero en rendimiento
- Perfecto para NPCs y bots
- Animaciones funcionan perfectamente

---

## 🔧 Configurar R6 en tu Juego

### Paso 1: En Roblox Studio

1. Abre tu juego en Roblox Studio
2. En el **Explorer**, encuentra **StarterPlayer**
3. Selecciona **StarterCharacter**
4. En las **Properties**, busca **RigType**
5. Cambia **RigType** a **"R6"**
6. Guarda el juego

### Paso 2: Verificar que sea R6

Puedes verificar si un modelo es R6 con código:

```lua
local function isR6Model(model)
    -- R6 tiene "Torso", R15 tiene "UpperTorso" y "LowerTorso"
    local hasTorso = model:FindFirstChild("Torso") ~= nil
    local hasUpperTorso = model:FindFirstChild("UpperTorso") ~= nil
    
    return hasTorso and not hasUpperTorso
end

-- Usar
local character = workspace:FindFirstChild("GoalkeeperBot")
if character and isR6Model(character) then
    print("✅ Es un modelo R6")
else
    print("⚠️ No es R6")
end
```

---

## 🏗️ Estructura Completa de R6

### Partes del Modelo

```
Model (GoalkeeperBot) - R6
├── Humanoid
│   ├── WalkSpeed
│   ├── JumpPower
│   ├── Health
│   └── MaxHealth
├── HumanoidRootPart (equivale al Torso físicamente)
├── Head
│   └── [Puede tener accesorios, etc.]
├── Torso
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

### Motor6D en R6

Los **Motor6D** conectan las partes en R6:

```lua
-- Estructura de Motor6D en R6
Left Shoulder:
    Part0 = Torso
    Part1 = Left Arm

Right Shoulder:
    Part0 = Torso
    Part1 = Right Arm

Left Hip:
    Part0 = Torso
    Part1 = Left Leg

Right Hip:
    Part0 = Torso
    Part1 = Right Leg

Neck:
    Part0 = Torso
    Part1 = Head
```

---

## 🎬 Animaciones con R6

### Cómo Funcionan las Animaciones en R6

Las animaciones funcionan **exactamente igual** en R6 que en R15:

```lua
local humanoid = botModel:FindFirstChild("Humanoid")

-- Crear animación
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://123456789"

-- Cargar en el Humanoid
local animationTrack = humanoid:LoadAnimation(animation)

-- Reproducir
animationTrack:Play()
```

**Las animaciones automáticamente:**
- ✅ Funcionan con las partes R6 (Torso, Arms, Legs, Head)
- ✅ Se aplican correctamente a través de los Motor6D
- ✅ No necesitas configuración especial

### Verificar que la Animación Funcione

```lua
-- Cargar y probar una animación
local function testAnimation(model, animationId)
    local humanoid = model:FindFirstChild("Humanoid")
    if not humanoid then
        warn("No hay Humanoid")
        return false
    end
    
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. tostring(animationId)
    
    local success, animationTrack = pcall(function()
        return humanoid:LoadAnimation(animation)
    end)
    
    if not success then
        warn("Error al cargar animación:", animationTrack)
        return false
    end
    
    animationTrack:Play()
    print("✅ Animación reproducida")
    return true
end

-- Usar
testAnimation(botModel, 123456789)
```

---

## 🔨 Crear Bot R6 Programáticamente

### Método 1: Clonar StarterCharacter R6

```lua
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")

-- Obtener StarterCharacter (debe ser R6)
local templateCharacter = StarterPlayer:FindFirstChild("StarterCharacter")
if not templateCharacter then
    -- Fallback: usar Character de un jugador
    local testPlayer = Players:GetPlayers()[1]
    if testPlayer and testPlayer.Character then
        templateCharacter = testPlayer.Character
    else
        warn("No se encontró template")
        return
    end
end

-- Verificar que sea R6
local isR6 = templateCharacter:FindFirstChild("Torso") ~= nil
if not isR6 then
    warn("⚠️ El modelo no es R6. Cambia RigType a R6 en StarterCharacter")
    return
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
end

print("✅ Bot R6 creado")
```

### Método 2: Crear R6 desde Cero

Si necesitas crear un modelo R6 completamente desde cero:

```lua
local function createR6Model(position)
    -- Crear modelo
    local model = Instance.new("Model")
    model.Name = "GoalkeeperBot"
    model.Parent = workspace
    
    -- Crear Humanoid
    local humanoid = Instance.new("Humanoid")
    humanoid.Health = math.huge
    humanoid.MaxHealth = math.huge
    humanoid.WalkSpeed = 20
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    humanoid.Parent = model
    
    -- Crear Torso (parte principal)
    local torso = Instance.new("Part")
    torso.Name = "Torso"
    torso.Size = Vector3.new(2, 2, 1)
    torso.BrickColor = BrickColor.new("Bright blue")
    torso.Parent = model
    
    -- Crear HumanoidRootPart (debe ser el Torso en R6)
    local rootPart = Instance.new("Part")
    rootPart.Name = "HumanoidRootPart"
    rootPart.Size = Vector3.new(2, 2, 1)
    rootPart.Transparency = 1
    rootPart.CanCollide = false
    rootPart.CFrame = CFrame.new(position or Vector3.new(0, 5, 0))
    rootPart.Parent = model
    
    -- Conectar HumanoidRootPart al Torso (en R6, son la misma parte)
    local rootMotor = Instance.new("Motor6D")
    rootMotor.Name = "RootJoint"
    rootMotor.Part0 = rootPart
    rootMotor.Part1 = torso
    rootMotor.C0 = CFrame.new(0, 0, 0)
    rootMotor.Parent = rootPart
    
    -- Crear Head
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(2, 1, 1)
    head.Shape = Enum.PartType.Ball
    head.BrickColor = BrickColor.new("Bright yellow")
    head.Parent = model
    
    local neck = Instance.new("Motor6D")
    neck.Name = "Neck"
    neck.Part0 = torso
    neck.Part1 = head
    neck.C0 = CFrame.new(0, 1, 0)
    neck.C1 = CFrame.new(0, -0.5, 0)
    neck.Parent = torso
    
    -- Crear Left Arm
    local leftArm = Instance.new("Part")
    leftArm.Name = "Left Arm"
    leftArm.Size = Vector3.new(1, 2, 1)
    leftArm.BrickColor = BrickColor.new("Bright blue")
    leftArm.Parent = model
    
    local leftShoulder = Instance.new("Motor6D")
    leftShoulder.Name = "Left Shoulder"
    leftShoulder.Part0 = torso
    leftShoulder.Part1 = leftArm
    leftShoulder.C0 = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0)
    leftShoulder.Parent = torso
    
    -- Crear Right Arm
    local rightArm = Instance.new("Part")
    rightArm.Name = "Right Arm"
    rightArm.Size = Vector3.new(1, 2, 1)
    rightArm.BrickColor = BrickColor.new("Bright blue")
    rightArm.Parent = model
    
    local rightShoulder = Instance.new("Motor6D")
    rightShoulder.Name = "Right Shoulder"
    rightShoulder.Part0 = torso
    rightShoulder.Part1 = rightArm
    rightShoulder.C0 = CFrame.new(1.5, 0.5, 0) * CFrame.Angles(0, math.rad(90), 0)
    rightShoulder.Parent = torso
    
    -- Crear Left Leg
    local leftLeg = Instance.new("Part")
    leftLeg.Name = "Left Leg"
    leftLeg.Size = Vector3.new(1, 2, 1)
    leftLeg.BrickColor = BrickColor.new("Bright blue")
    leftLeg.Parent = model
    
    local leftHip = Instance.new("Motor6D")
    leftHip.Name = "Left Hip"
    leftHip.Part0 = torso
    leftHip.Part1 = leftLeg
    leftHip.C0 = CFrame.new(-0.5, -1, 0) * CFrame.Angles(0, math.rad(-90), 0)
    leftHip.Parent = torso
    
    -- Crear Right Leg
    local rightLeg = Instance.new("Part")
    rightLeg.Name = "Right Leg"
    rightLeg.Size = Vector3.new(1, 2, 1)
    rightLeg.BrickColor = BrickColor.new("Bright blue")
    rightLeg.Parent = model
    
    local rightHip = Instance.new("Motor6D")
    rightHip.Name = "Right Hip"
    rightHip.Part0 = torso
    rightHip.Part1 = rightLeg
    rightHip.C0 = CFrame.new(0.5, -1, 0) * CFrame.Angles(0, math.rad(90), 0)
    rightHip.Parent = torso
    
    -- Configurar Humanoid
    humanoid.RootPart = rootPart
    humanoid.RequiresNeck = true
    
    return model
end

-- Usar
local botModel = createR6Model(Vector3.new(0, 5, 0))
botModel:SetAttribute("IsNPC", true)
botModel:SetAttribute("ModelType", "R6")
```

**Nota:** Es más fácil clonar un StarterCharacter R6 que crear uno desde cero.

---

## ✅ Ventajas de R6 para Bots

### 1. **Simplicidad**
- Menos partes que manejar
- Estructura más simple
- Más fácil de entender

### 2. **Rendimiento**
- Menos objetos que actualizar
- Más eficiente para múltiples NPCs
- Menos carga en el servidor

### 3. **Compatibilidad**
- Funciona perfectamente con animaciones
- Compatible con todos los sistemas de Roblox
- Estándar para NPCs en muchos juegos

### 4. **Apariencia**
- Clásico y reconocible
- Perfecto para bots simples
- Funcional sin necesidad de detalles extra

---

## 🔍 Verificar Partes de R6

### Función Helper para Verificar R6

```lua
local function verifyR6Structure(model)
    local requiredParts = {
        "Head",
        "Torso",
        "Left Arm",
        "Right Arm",
        "Left Leg",
        "Right Leg",
        "HumanoidRootPart"
    }
    
    local missingParts = {}
    
    for _, partName in ipairs(requiredParts) do
        if not model:FindFirstChild(partName) then
            table.insert(missingParts, partName)
        end
    end
    
    if #missingParts > 0 then
        warn("⚠️ Faltan partes R6:", table.concat(missingParts, ", "))
        return false
    end
    
    -- Verificar Motor6D
    local torso = model:FindFirstChild("Torso")
    if torso then
        local requiredMotors = {
            "Left Shoulder",
            "Right Shoulder",
            "Left Hip",
            "Right Hip",
            "Neck"
        }
        
        local missingMotors = {}
        for _, motorName in ipairs(requiredMotors) do
            if not torso:FindFirstChild(motorName) then
                table.insert(missingMotors, motorName)
            end
        end
        
        if #missingMotors > 0 then
            warn("⚠️ Faltan Motor6D en Torso:", table.concat(missingMotors, ", "))
            return false
        end
    end
    
    print("✅ Estructura R6 completa")
    return true
end

-- Usar
if verifyR6Structure(botModel) then
    print("Listo para usar")
end
```

---

## 🎨 Personalización de R6

### Cambiar Colores

```lua
local function customizeR6Colors(model, torsoColor, headColor)
    local torso = model:FindFirstChild("Torso")
    if torso then
        torso.BrickColor = BrickColor.new(torsoColor or "Bright blue")
        
        -- Cambiar color de brazos y piernas también
        local partsToColor = {
            "Left Arm", "Right Arm",
            "Left Leg", "Right Leg"
        }
        
        for _, partName in ipairs(partsToColor) do
            local part = model:FindFirstChild(partName)
            if part then
                part.BrickColor = torso.BrickColor
            end
        end
    end
    
    local head = model:FindFirstChild("Head")
    if head then
        head.BrickColor = BrickColor.new(headColor or "Bright yellow")
    end
end

-- Usar
customizeR6Colors(botModel, "Bright red", "Bright yellow")
```

### Agregar Accesorios

```lua
-- Agregar una camiseta de portero
local function addGoalkeeperShirt(model)
    local torso = model:FindFirstChild("Torso")
    if not torso then return end
    
    -- Crear Shirt (camiseta)
    local shirt = Instance.new("Shirt")
    shirt.Name = "Shirt"
    shirt.ShirtTemplate = "rbxassetid://123456789" -- ID de la textura
    shirt.Parent = torso
    
    print("✅ Camiseta agregada")
end

-- Usar
addGoalkeeperShirt(botModel)
```

---

## 📚 Referencias

- **Documentación Roblox**: [Humanoid](https://create.roblox.com/docs/reference/engine/classes/Humanoid)
- **Documentación Roblox**: [RigType](https://create.roblox.com/docs/reference/engine/enums/HumanoidRigType)
- **Proyecto**: `documentacion/BOT_PORTERO_MODELO.md`

---

## ❓ Preguntas Frecuentes

**P: ¿R6 funciona con todas las animaciones?**
R: Sí, las animaciones funcionan igual en R6 y R15. Roblox convierte automáticamente las animaciones al formato correcto.

**P: ¿Puedo mezclar R6 y R15 en el mismo juego?**
R: Sí, puedes tener jugadores con R15 y bots con R6 al mismo tiempo.

**P: ¿R6 es obsoleto?**
R: No, R6 sigue siendo completamente soportado y es perfecto para NPCs.

---

¡R6 es perfecto para tu bot de portero! 🥅⚽

