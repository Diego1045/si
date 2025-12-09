# Cómo Crear un Motor6D

## 🚀 Método Básico

### Paso 1: Crear la Instancia

```lua
local motor = Instance.new("Motor6D")
```

### Paso 2: Configurar las Partes

```lua
motor.Part0 = part1  -- Parte base (padre)
motor.Part1 = part2  -- Parte conectada (hijo)
```

### Paso 3: Configurar los Offsets (Opcional)

```lua
motor.C0 = CFrame.new(0, 0, 0)  -- Offset inicial de Part0
motor.C1 = CFrame.new(0, 0, 0)  -- Offset relativo de Part1
```

### Paso 4: Establecer el Parent

```lua
motor.Parent = motor.Part0  -- IMPORTANTE: Debe ser hijo de Part0
```

## 📝 Ejemplo Completo

```lua
-- Obtener las partes
local part1 = workspace.Part1
local part2 = workspace.Part2

-- Crear el motor
local motor = Instance.new("Motor6D")
motor.Name = "MyMotor"  -- Nombre opcional pero recomendado
motor.Part0 = part1
motor.Part1 = part2
motor.C0 = CFrame.new(0, 0, 0)
motor.C1 = CFrame.new(0, 0, 0)
motor.Parent = part1  -- Debe ser hijo de Part0

print("Motor creado exitosamente!")
```

## 🎯 Ejemplo del Código del Proyecto

Basado en `Ball.server.lua`:

```lua
-- Crear motor para conectar balón al jugador
local weld = Instance.new("Motor6D")
weld.Name = "BallMotor"
weld.Part0 = rootPart  -- HumanoidRootPart del jugador
weld.Part1 = ball      -- El balón
weld.Parent = ball     -- Parent puede ser Part0 o Part1
weld.C0 = CFrame.new(0, -2, -2)  -- Offset: 2 unidades abajo y 2 atrás
```

## 🔧 Creación con Funciones Auxiliares

### Función Helper Básica

```lua
local function createMotor(part0, part1, c0, c1, name)
    local motor = Instance.new("Motor6D")
    motor.Name = name or "Motor"
    motor.Part0 = part0
    motor.Part1 = part1
    motor.C0 = c0 or CFrame.new()
    motor.C1 = c1 or CFrame.new()
    motor.Parent = part0
    return motor
end

-- Uso
local motor = createMotor(
    workspace.Part1,
    workspace.Part2,
    CFrame.new(0, 2, 0),
    CFrame.new(),
    "ConnectionMotor"
)
```

### Función Helper Avanzada

```lua
local function createMotorAdvanced(config)
    local motor = Instance.new("Motor6D")
    
    -- Propiedades requeridas
    motor.Part0 = config.part0
    motor.Part1 = config.part1
    
    -- Propiedades opcionales
    motor.Name = config.name or "Motor"
    motor.C0 = config.c0 or CFrame.new()
    motor.C1 = config.c1 or CFrame.new()
    motor.Enabled = config.enabled ~= false  -- Por defecto true
    
    -- Parent (debe ser Part0 o Part1)
    motor.Parent = config.parent or config.part0
    
    return motor
end

-- Uso
local motor = createMotorAdvanced({
    part0 = workspace.Part1,
    part1 = workspace.Part2,
    c0 = CFrame.new(0, 2, 0),
    c1 = CFrame.new(),
    name = "CustomMotor",
    enabled = true
})
```

## ⚠️ Errores Comunes y Cómo Evitarlos

### Error 1: Partes No Existen

```lua
-- ❌ MAL - Las partes pueden no existir aún
local motor = Instance.new("Motor6D")
motor.Part0 = workspace.Part1  -- Puede ser nil
motor.Part1 = workspace.Part2  -- Puede ser nil

-- ✅ BIEN - Verificar que existan
local part1 = workspace:WaitForChild("Part1")
local part2 = workspace:WaitForChild("Part2")
local motor = Instance.new("Motor6D")
motor.Part0 = part1
motor.Part1 = part2
motor.Parent = part1
```

### Error 2: Parent Incorrecto

```lua
-- ❌ MAL - Parent no es Part0 ni Part1
motor.Parent = workspace  -- Error!

-- ✅ BIEN - Parent debe ser Part0 o Part1
motor.Parent = motor.Part0  -- Correcto
-- O
motor.Parent = motor.Part1  -- También correcto
```

### Error 3: Crear en el Cliente

```lua
-- ❌ MAL - Motor6D no funciona en el cliente
-- Script LocalScript (cliente)
local motor = Instance.new("Motor6D")  -- No funcionará correctamente

-- ✅ BIEN - Crear en el servidor
-- Script ServerScript (servidor)
local motor = Instance.new("Motor6D")  -- Funciona correctamente
```

### Error 4: No Establecer Part0 y Part1

```lua
-- ❌ MAL - Falta configurar las partes
local motor = Instance.new("Motor6D")
motor.Parent = workspace  -- Error: Part0 y Part1 son nil

-- ✅ BIEN - Configurar todo antes del Parent
local motor = Instance.new("Motor6D")
motor.Part0 = part1
motor.Part1 = part2
motor.Parent = part1  -- Ahora funciona
```

## 🎨 Patrones de Creación Comunes

### Patrón 1: Conectar Múltiples Partes

```lua
local function connectParts(basePart, partsToConnect)
    local motors = {}
    
    for i, part in ipairs(partsToConnect) do
        local motor = Instance.new("Motor6D")
        motor.Name = "Motor_" .. part.Name
        motor.Part0 = basePart
        motor.Part1 = part
        motor.C0 = CFrame.new(0, 0, 0)
        motor.C1 = CFrame.new(0, 0, 0)
        motor.Parent = basePart
        
        table.insert(motors, motor)
    end
    
    return motors
end

-- Uso
local torso = workspace.Torso
local parts = {workspace.LeftArm, workspace.RightArm, workspace.Head}
local motors = connectParts(torso, parts)
```

### Patrón 2: Conectar con Offset Específico

```lua
local function connectWithOffset(part0, part1, offset)
    local motor = Instance.new("Motor6D")
    motor.Part0 = part0
    motor.Part1 = part1
    motor.C0 = offset or CFrame.new()
    motor.C1 = CFrame.new()
    motor.Parent = part0
    return motor
end

-- Uso: Conectar balón 2 unidades arriba
local motor = connectWithOffset(
    player.Character.HumanoidRootPart,
    ball,
    CFrame.new(0, 2, 0)
)
```

### Patrón 3: Crear y Destruir Dinámicamente

```lua
local motor = nil

local function attachBall(player, ball)
    -- Destruir motor anterior si existe
    if motor then
        motor:Destroy()
        motor = nil
    end
    
    -- Crear nuevo motor
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if rootPart and ball then
        motor = Instance.new("Motor6D")
        motor.Name = "BallMotor"
        motor.Part0 = rootPart
        motor.Part1 = ball
        motor.C0 = CFrame.new(0, -2, -2)
        motor.Parent = ball
    end
end

local function detachBall()
    if motor then
        motor:Destroy()
        motor = nil
    end
end
```

## ✅ Checklist de Creación

Antes de crear un Motor6D, asegúrate de:

- [ ] Las partes (`Part0` y `Part1`) existen
- [ ] Estás en un script del servidor (no LocalScript)
- [ ] Has configurado `Part0` y `Part1`
- [ ] Has configurado `C0` y `C1` (o al menos CFrame.new())
- [ ] El `Parent` es `Part0` o `Part1`
- [ ] Has dado un nombre descriptivo al motor (opcional pero recomendado)

## 📚 Siguiente Paso

Ahora que sabes crear un Motor6D, aprende a configurarlo correctamente en el siguiente documento.

---

**Siguiente:** [Configuración de Motor6D](./03_configuracion_motor6d.md)

