# Mejores Prácticas para Motor6D

## ✅ Do's (Hacer)

### 1. Siempre Verificar que las Partes Existan

```lua
-- ✅ BIEN
local part1 = workspace:WaitForChild("Part1")
local part2 = workspace:WaitForChild("Part2")

local motor = Instance.new("Motor6D")
motor.Part0 = part1
motor.Part1 = part2
motor.Parent = part1
```

### 2. Usar Nombres Descriptivos

```lua
-- ✅ BIEN
motor.Name = "BallMotor"
motor.Name = "LeftArmMotor"
motor.Name = "WeaponAttachmentMotor"

-- ❌ MAL
motor.Name = "Motor"
motor.Name = "Motor1"
motor.Name = "asdf"
```

### 3. Limpiar Motores Anteriores

```lua
-- ✅ BIEN
local function attachBall(player, ball)
    -- Buscar y destruir motor anterior
    local existingMotor = ball:FindFirstChild("BallMotor")
    if existingMotor then
        existingMotor:Destroy()
    end
    
    -- Crear nuevo motor
    local motor = Instance.new("Motor6D")
    motor.Name = "BallMotor"
    motor.Part0 = player.Character.HumanoidRootPart
    motor.Part1 = ball
    motor.Parent = ball
end
```

### 4. Configurar C0 y C1 Explícitamente

```lua
-- ✅ BIEN
motor.C0 = CFrame.new(0, 2, 0)
motor.C1 = CFrame.new(0, 0, 0)

-- ⚠️ ACEPTABLE (usa valores por defecto)
motor.C0 = CFrame.new(0, 0, 0)
motor.C1 = CFrame.new(0, 0, 0)
```

### 5. Establecer Parent al Final

```lua
-- ✅ BIEN - Orden correcto
local motor = Instance.new("Motor6D")
motor.Part0 = part1
motor.Part1 = part2
motor.C0 = CFrame.new(0, 0, 0)
motor.C1 = CFrame.new(0, 0, 0)
motor.Parent = part1  -- Al final
```

### 6. Usar math.rad() para Rotaciones

```lua
-- ✅ BIEN
motor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0)

-- ❌ MAL
motor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, 90, 0)  -- Grados en lugar de radianes
```

### 7. Crear en Scripts del Servidor

```lua
-- ✅ BIEN - Script (Servidor)
local motor = Instance.new("Motor6D")
motor.Part0 = part1
motor.Part1 = part2
motor.Parent = part1

-- ❌ MAL - LocalScript (Cliente)
-- Motor6D no funciona correctamente en el cliente
```

### 8. Documentar Offsets Complejos

```lua
-- ✅ BIEN
-- Conectar balón detrás y abajo del jugador
-- Offset: 2 unidades abajo (Y: -2), 2 unidades atrás (Z: -2)
motor.C0 = CFrame.new(0, -2, -2)
```

## ❌ Don'ts (No Hacer)

### 1. No Crear en el Cliente

```lua
-- ❌ MAL
-- LocalScript (Cliente)
local motor = Instance.new("Motor6D")
motor.Part0 = part1
motor.Part1 = part2
motor.Parent = part1  -- No funcionará correctamente
```

### 2. No Olvidar Verificar Partes

```lua
-- ❌ MAL
local motor = Instance.new("Motor6D")
motor.Part0 = workspace.Part1  -- Puede ser nil
motor.Part1 = workspace.Part2  -- Puede ser nil
motor.Parent = workspace  -- Error!
```

### 3. No Usar Parent Incorrecto

```lua
-- ❌ MAL
motor.Part0 = part1
motor.Part1 = part2
motor.Parent = workspace  -- Debe ser part1 o part2

-- ✅ BIEN
motor.Parent = motor.Part0  -- Correcto
```

### 4. No Crear Múltiples Motores para las Mismas Partes

```lua
-- ❌ MAL
local motor1 = Instance.new("Motor6D")
motor1.Part0 = part1
motor1.Part1 = part2
motor1.Parent = part1

local motor2 = Instance.new("Motor6D")
motor2.Part0 = part1
motor2.Part1 = part2  -- Mismas partes!
motor2.Parent = part1  -- Conflicto
```

### 5. No Modificar Part0/Part1 Después de Crear

```lua
-- ❌ MAL - Puede causar errores
motor.Part0 = part1
motor.Part1 = part2
motor.Parent = part1

-- Más tarde...
motor.Part0 = otherPart  -- Cambiar después puede causar problemas
```

### 6. No Olvidar Limpiar Motores

```lua
-- ❌ MAL - Memory leak
local function attachBall(player, ball)
    local motor = Instance.new("Motor6D")
    motor.Part0 = player.Character.HumanoidRootPart
    motor.Part1 = ball
    motor.Parent = ball
    -- Motor anterior nunca se destruye
end
```

## 🎯 Patrones Recomendados

### Patrón 1: Factory Function

```lua
local function createMotor(part0, part1, offset, name)
    -- Validación
    if not part0 or not part1 then
        warn("Partes inválidas para motor")
        return nil
    end
    
    -- Limpiar motor anterior si existe
    local existingMotor = part1:FindFirstChild(name or "Motor")
    if existingMotor then
        existingMotor:Destroy()
    end
    
    -- Crear motor
    local motor = Instance.new("Motor6D")
    motor.Name = name or "Motor"
    motor.Part0 = part0
    motor.Part1 = part1
    motor.C0 = offset or CFrame.new(0, 0, 0)
    motor.C1 = CFrame.new(0, 0, 0)
    motor.Parent = part0
    
    return motor
end
```

### Patrón 2: Manager Class

```lua
local MotorManager = {}
MotorManager.__index = MotorManager

function MotorManager.new()
    local self = setmetatable({}, MotorManager)
    self.motors = {}
    return self
end

function MotorManager:Create(name, part0, part1, c0, c1)
    self:Destroy(name)  -- Limpiar anterior
    
    local motor = Instance.new("Motor6D")
    motor.Name = name
    motor.Part0 = part0
    motor.Part1 = part1
    motor.C0 = c0 or CFrame.new(0, 0, 0)
    motor.C1 = c1 or CFrame.new(0, 0, 0)
    motor.Parent = part0
    
    self.motors[name] = motor
    return motor
end

function MotorManager:Destroy(name)
    if self.motors[name] then
        self.motors[name]:Destroy()
        self.motors[name] = nil
    end
end

function MotorManager:Cleanup()
    for name, motor in pairs(self.motors) do
        motor:Destroy()
    end
    self.motors = {}
end
```

### Patrón 3: Validación Robusta

```lua
local function createValidatedMotor(config)
    -- Validar entrada
    assert(type(config) == "table", "Config debe ser una tabla")
    assert(config.part0, "Part0 es requerido")
    assert(config.part1, "Part1 es requerido")
    assert(config.part0:IsA("BasePart"), "Part0 debe ser BasePart")
    assert(config.part1:IsA("BasePart"), "Part1 debe ser BasePart")
    
    -- Verificar que las partes existan
    if not config.part0.Parent then
        warn("Part0 no tiene parent")
        return nil
    end
    
    if not config.part1.Parent then
        warn("Part1 no tiene parent")
        return nil
    end
    
    -- Crear motor
    local motor = Instance.new("Motor6D")
    motor.Name = config.name or "Motor"
    motor.Part0 = config.part0
    motor.Part1 = config.part1
    motor.C0 = config.c0 or CFrame.new(0, 0, 0)
    motor.C1 = config.c1 or CFrame.new(0, 0, 0)
    motor.Enabled = config.enabled ~= false
    motor.Parent = config.parent or config.part0
    
    return motor
end
```

## 🔍 Debugging Tips

### 1. Verificar que el Motor Existe

```lua
local motor = part:FindFirstChild("MotorName")
if motor and motor:IsA("Motor6D") then
    print("Motor encontrado:", motor.Name)
    print("Part0:", motor.Part0)
    print("Part1:", motor.Part1)
    print("C0:", motor.C0)
    print("C1:", motor.C1)
else
    warn("Motor no encontrado")
end
```

### 2. Verificar Estado del Motor

```lua
if motor.Enabled then
    print("Motor está activo")
else
    print("Motor está desactivado")
end
```

### 3. Listar Todos los Motores

```lua
local function listAllMotors(parent)
    for _, motor in ipairs(parent:GetDescendants()) do
        if motor:IsA("Motor6D") then
            print("Motor:", motor.Name)
            print("  Part0:", motor.Part0)
            print("  Part1:", motor.Part1)
            print("  Enabled:", motor.Enabled)
        end
    end
end

listAllMotors(workspace)
```

## ⚡ Optimización

### 1. Reutilizar Motores cuando sea Posible

```lua
-- En lugar de crear/destruir constantemente
local motor = part:FindFirstChild("Motor") or Instance.new("Motor6D")
motor.Part0 = part0
motor.Part1 = part1
motor.Parent = part0
```

### 2. Agrupar Creaciones de Motores

```lua
-- Crear múltiples motores de una vez
local function createCharacterMotors(character)
    local motors = {}
    local torso = character:FindFirstChild("Torso")
    
    for _, partName in ipairs({"LeftArm", "RightArm", "Head"}) do
        local part = character:FindFirstChild(partName)
        if part then
            local motor = Instance.new("Motor6D")
            motor.Part0 = torso
            motor.Part1 = part
            motor.Parent = torso
            motors[partName] = motor
        end
    end
    
    return motors
end
```

### 3. Usar Enabled en lugar de Destroy/Create

```lua
-- Para conexiones temporales, usar Enabled
motor.Enabled = false  -- Desconectar
-- ... hacer algo ...
motor.Enabled = true   -- Reconectar

-- En lugar de:
-- motor:Destroy()
-- motor = Instance.new("Motor6D")
-- ... recrear ...
```

## 📝 Checklist de Implementación

Antes de implementar un Motor6D, verifica:

- [ ] ¿Estoy en un script del servidor?
- [ ] ¿Las partes existen antes de crear el motor?
- [ ] ¿He verificado que Part0 y Part1 no sean nil?
- [ ] ¿He configurado C0 y C1 explícitamente?
- [ ] ¿El Parent es Part0 o Part1?
- [ ] ¿He usado nombres descriptivos?
- [ ] ¿He limpiado motores anteriores si es necesario?
- [ ] ¿He usado math.rad() para rotaciones?
- [ ] ¿He documentado offsets complejos?

## 📚 Siguiente Paso

Si encuentras problemas, consulta la guía de solución de problemas.

---

**Siguiente:** [Solución de Problemas](./06_solucion_problemas.md)

