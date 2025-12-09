# Solución de Problemas con Motor6D

## 🔴 Problemas Comunes y Soluciones

### Problema 1: "Part0/Part1 is nil"

**Síntoma:**
```
Error: Part0 is nil
Error: Part1 is nil
```

**Causa:**
Las partes no existen o no se han encontrado correctamente.

**Solución:**
```lua
-- ❌ MAL
local motor = Instance.new("Motor6D")
motor.Part0 = workspace.Part1  -- Puede ser nil
motor.Part1 = workspace.Part2  -- Puede ser nil

-- ✅ BIEN
local part1 = workspace:WaitForChild("Part1")
local part2 = workspace:WaitForChild("Part2")

local motor = Instance.new("Motor6D")
motor.Part0 = part1
motor.Part1 = part2
motor.Parent = part1
```

### Problema 2: Motor No Conecta las Partes

**Síntoma:**
Las partes no se mueven juntas, el motor existe pero no funciona.

**Causas Posibles:**

1. **Parent incorrecto:**
```lua
-- ❌ MAL
motor.Parent = workspace  -- Incorrecto

-- ✅ BIEN
motor.Parent = motor.Part0  -- Correcto
```

2. **Motor creado en el cliente:**
```lua
-- ❌ MAL - LocalScript
local motor = Instance.new("Motor6D")
motor.Part0 = part1
motor.Part1 = part2
motor.Parent = part1  -- No funcionará en cliente

-- ✅ BIEN - Script (Servidor)
local motor = Instance.new("Motor6D")
motor.Part0 = part1
motor.Part1 = part2
motor.Parent = part1
```

3. **Motor deshabilitado:**
```lua
-- Verificar
if motor.Enabled == false then
    motor.Enabled = true
end
```

### Problema 3: Las Partes se Mueven Incorrectamente

**Síntoma:**
Las partes están conectadas pero en posiciones incorrectas.

**Solución:**
Ajustar C0 y C1:

```lua
-- Ejemplo: Balón muy lejos
motor.C0 = CFrame.new(0, -2, -2)  -- Muy lejos

-- Ajustar
motor.C0 = CFrame.new(0, -1, -1)  -- Más cerca

-- Ejemplo: Rotación incorrecta
motor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
-- Ajustar ángulo
motor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(45), 0)
```

### Problema 4: Múltiples Motores Confligentes

**Síntoma:**
Las partes se comportan de forma extraña, saltan o vibran.

**Causa:**
Múltiples motores conectando las mismas partes.

**Solución:**
```lua
-- Limpiar motores anteriores antes de crear uno nuevo
local function attachBall(player, ball)
    -- Buscar y destruir motores existentes
    for _, motor in ipairs(ball:GetDescendants()) do
        if motor:IsA("Motor6D") then
            motor:Destroy()
        end
    end
    
    -- Crear nuevo motor
    local motor = Instance.new("Motor6D")
    motor.Part0 = player.Character.HumanoidRootPart
    motor.Part1 = ball
    motor.Parent = ball
end
```

### Problema 5: Memory Leaks (Fugas de Memoria)

**Síntoma:**
El juego se vuelve lento después de mucho tiempo.

**Causa:**
Motores no se destruyen cuando ya no se necesitan.

**Solución:**
```lua
-- Guardar referencias y limpiar cuando sea necesario
local motors = {}

local function createMotor(name, part0, part1)
    -- Destruir motor anterior si existe
    if motors[name] then
        motors[name]:Destroy()
    end
    
    local motor = Instance.new("Motor6D")
    motor.Part0 = part0
    motor.Part1 = part1
    motor.Parent = part0
    
    motors[name] = motor
    return motor
end

local function cleanup()
    for name, motor in pairs(motors) do
        motor:Destroy()
    end
    motors = {}
end
```

### Problema 6: Rotaciones en Grados en lugar de Radianes

**Síntoma:**
Las rotaciones son extremas o incorrectas.

**Causa:**
Usar grados directamente en lugar de radianes.

**Solución:**
```lua
-- ❌ MAL
motor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, 90, 0)  -- 90 radianes!

-- ✅ BIEN
motor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0)  -- 90 grados
```

### Problema 7: Partes se Desconectan al Mover Físicamente

**Síntoma:**
Cuando una parte se mueve físicamente, se desconecta del motor.

**Causa:**
El motor no puede mantener la conexión si hay fuerzas físicas fuertes.

**Solución:**
```lua
-- Deshabilitar física en Part1
motor.Part1.Anchored = true  -- Anclar la parte
motor.Part1.CanCollide = false  -- Deshabilitar colisiones
motor.Part1.Massless = true  -- Sin masa (si es posible)

-- O usar Attachment + AlignPosition para física avanzada
```

### Problema 8: Motor No se Encuentra para Destruir

**Síntoma:**
No puedes encontrar el motor para destruirlo.

**Solución:**
```lua
-- Buscar motor de múltiples formas
local function findMotor(part0, part1, name)
    -- Buscar por nombre en Part0
    local motor = part0:FindFirstChild(name)
    if motor and motor:IsA("Motor6D") then
        return motor
    end
    
    -- Buscar por nombre en Part1
    motor = part1:FindFirstChild(name)
    if motor and motor:IsA("Motor6D") then
        return motor
    end
    
    -- Buscar cualquier motor conectando estas partes
    for _, descendant in ipairs(part0:GetDescendants()) do
        if descendant:IsA("Motor6D") and descendant.Part1 == part1 then
            return descendant
        end
    end
    
    for _, descendant in ipairs(part1:GetDescendants()) do
        if descendant:IsA("Motor6D") and descendant.Part0 == part0 then
            return descendant
        end
    end
    
    return nil
end
```

## 🛠️ Herramientas de Debugging

### Función de Diagnóstico

```lua
local function diagnoseMotor(motor)
    print("=== Diagnóstico de Motor ===")
    print("Nombre:", motor.Name)
    print("Tipo:", motor.ClassName)
    print("Enabled:", motor.Enabled)
    print("Parent:", motor.Parent)
    print("Part0:", motor.Part0)
    print("Part1:", motor.Part1)
    print("C0:", motor.C0)
    print("C1:", motor.C1)
    
    -- Verificaciones
    if not motor.Part0 then
        warn("⚠️ Part0 es nil!")
    end
    
    if not motor.Part1 then
        warn("⚠️ Part1 es nil!")
    end
    
    if motor.Parent ~= motor.Part0 and motor.Parent ~= motor.Part1 then
        warn("⚠️ Parent incorrecto!")
    end
    
    if not motor.Enabled then
        warn("⚠️ Motor está deshabilitado!")
    end
    
    print("===========================")
end

-- Uso
local motor = workspace:FindFirstChild("BallMotor")
if motor then
    diagnoseMotor(motor)
end
```

### Función de Listado de Motores

```lua
local function listAllMotors(parent)
    print("=== Motores en", parent.Name, "===")
    local count = 0
    
    for _, motor in ipairs(parent:GetDescendants()) do
        if motor:IsA("Motor6D") then
            count = count + 1
            print(string.format("%d. %s", count, motor.Name))
            print("   Part0:", motor.Part0 and motor.Part0.Name or "nil")
            print("   Part1:", motor.Part1 and motor.Part1.Name or "nil")
            print("   Enabled:", motor.Enabled)
        end
    end
    
    if count == 0 then
        print("No se encontraron motores")
    end
    
    print("===========================")
end

-- Uso
listAllMotors(workspace)
listAllMotors(game.Players.LocalPlayer.Character)
```

### Función de Validación

```lua
local function validateMotor(motor)
    local errors = {}
    
    if not motor:IsA("Motor6D") then
        table.insert(errors, "No es un Motor6D")
        return false, errors
    end
    
    if not motor.Part0 then
        table.insert(errors, "Part0 es nil")
    end
    
    if not motor.Part1 then
        table.insert(errors, "Part1 es nil")
    end
    
    if motor.Parent ~= motor.Part0 and motor.Parent ~= motor.Part1 then
        table.insert(errors, "Parent debe ser Part0 o Part1")
    end
    
    if #errors > 0 then
        return false, errors
    end
    
    return true, nil
end

-- Uso
local isValid, errors = validateMotor(motor)
if not isValid then
    warn("Motor inválido:")
    for _, error in ipairs(errors) do
        warn("  -", error)
    end
end
```

## 📋 Checklist de Troubleshooting

Cuando tengas problemas con un Motor6D, verifica:

1. [ ] ¿El motor existe? (`motor ~= nil`)
2. [ ] ¿Part0 existe? (`motor.Part0 ~= nil`)
3. [ ] ¿Part1 existe? (`motor.Part1 ~= nil`)
4. [ ] ¿El Parent es correcto? (`motor.Parent == motor.Part0 or motor.Parent == motor.Part1`)
5. [ ] ¿El motor está habilitado? (`motor.Enabled == true`)
6. [ ] ¿Está creado en el servidor? (Script, no LocalScript)
7. [ ] ¿Hay múltiples motores conectando las mismas partes?
8. [ ] ¿Los offsets C0 y C1 son correctos?
9. [ ] ¿Las partes tienen física que interfiere?
10. [ ] ¿Se están creando/destruyendo motores correctamente?

## 🔍 Errores Específicos

### Error: "Motor6D.Part0 must be a BasePart"

**Solución:**
```lua
-- Verificar tipo antes de asignar
if part:IsA("BasePart") then
    motor.Part0 = part
else
    warn("Part no es BasePart:", part.ClassName)
end
```

### Error: "Cannot set Parent to nil"

**Solución:**
```lua
-- Establecer Parent después de configurar Part0 y Part1
motor.Part0 = part1
motor.Part1 = part2
motor.Parent = motor.Part0  -- Ahora Part0 no es nil
```

### Error: "Attempt to index nil"

**Solución:**
```lua
-- Verificar que el motor existe antes de usarlo
local motor = part:FindFirstChild("MotorName")
if motor and motor:IsA("Motor6D") then
    motor.C0 = CFrame.new(0, 2, 0)
end
```

## 💡 Consejos Finales

1. **Siempre valida** antes de crear motores
2. **Limpia motores anteriores** antes de crear nuevos
3. **Usa nombres únicos** para facilitar el debugging
4. **Guarda referencias** para poder limpiar después
5. **Prueba en un lugar aislado** antes de integrar
6. **Lee los mensajes de error** - suelen ser muy descriptivos
7. **Usa las herramientas de debugging** proporcionadas arriba

---

**Volver al inicio:** [README](./README.md)

