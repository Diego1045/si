# Configuración de Motor6D

## 📋 Propiedades Principales

### Propiedades Requeridas

#### 1. `Part0` (BasePart)
La parte base que actúa como ancla.

```lua
motor.Part0 = workspace.Part1
```

**Características:**
- Debe ser una instancia de `BasePart` (Part, MeshPart, etc.)
- No puede ser `nil`
- Es la parte "padre" en la relación

#### 2. `Part1` (BasePart)
La parte que se conecta a Part0.

```lua
motor.Part1 = workspace.Part2
```

**Características:**
- Debe ser una instancia de `BasePart`
- No puede ser `nil`
- Es la parte "hijo" en la relación

#### 3. `Parent` (Instance)
Debe ser `Part0` o `Part1`.

```lua
motor.Parent = motor.Part0  -- Recomendado
-- O
motor.Parent = motor.Part1  -- También válido
```

**⚠️ Importante:** El Parent debe establecerse DESPUÉS de configurar Part0 y Part1.

### Propiedades de Offset

#### 4. `C0` (CFrame)
Offset inicial de Part0. Define dónde está el "punto de conexión" en Part0.

```lua
motor.C0 = CFrame.new(0, 0, 0)  -- Sin offset
motor.C0 = CFrame.new(0, 2, 0)  -- 2 unidades arriba
motor.C0 = CFrame.new(0, 0, -2) * CFrame.Angles(0, math.rad(90), 0)  -- Con rotación
```

**Valores comunes:**
- `CFrame.new(0, 0, 0)` - Sin offset
- `CFrame.new(0, 2, 0)` - 2 unidades arriba
- `CFrame.new(0, -2, 0)` - 2 unidades abajo
- `CFrame.new(0, 0, 2)` - 2 unidades adelante
- `CFrame.new(0, 0, -2)` - 2 unidades atrás

#### 5. `C1` (CFrame)
Offset relativo de Part1. Define cómo se orienta Part1 respecto al punto de conexión.

```lua
motor.C1 = CFrame.new(0, 0, 0)  -- Sin offset
motor.C1 = CFrame.Angles(0, math.rad(90), 0)  -- Rotado 90 grados
```

**Uso común:**
- Generalmente se deja en `CFrame.new(0, 0, 0)` para conexiones simples
- Se usa para ajustes finos de orientación

### Propiedades Opcionales

#### 6. `Name` (string)
Nombre del motor (opcional pero recomendado).

```lua
motor.Name = "BallMotor"
motor.Name = "LeftArmMotor"
motor.Name = "WeaponAttachment"
```

**Recomendación:** Usa nombres descriptivos para facilitar el debugging.

#### 7. `Enabled` (boolean)
Activa o desactiva el motor.

```lua
motor.Enabled = true   -- Motor activo (por defecto)
motor.Enabled = false  -- Motor desactivado (las partes se desconectan)
```

**Uso:**
- `true`: Las partes están conectadas
- `false`: Las partes se desconectan temporalmente

## 🎯 Configuraciones Comunes

### Configuración 1: Conexión Simple

```lua
local motor = Instance.new("Motor6D")
motor.Part0 = part1
motor.Part1 = part2
motor.C0 = CFrame.new(0, 0, 0)
motor.C1 = CFrame.new(0, 0, 0)
motor.Parent = part1
```

**Resultado:** Part2 se conecta directamente a Part1 sin offset.

### Configuración 2: Offset Vertical

```lua
local motor = Instance.new("Motor6D")
motor.Part0 = rootPart
motor.Part1 = ball
motor.C0 = CFrame.new(0, 2, 0)  -- 2 unidades arriba
motor.C1 = CFrame.new(0, 0, 0)
motor.Parent = rootPart
```

**Resultado:** El balón flota 2 unidades arriba del rootPart.

### Configuración 3: Offset Frontal

```lua
local motor = Instance.new("Motor6D")
motor.Part0 = character.HumanoidRootPart
motor.Part1 = tool
motor.C0 = CFrame.new(0, 0, -2)  -- 2 unidades adelante
motor.C1 = CFrame.new(0, 0, 0)
motor.Parent = character.HumanoidRootPart
```

**Resultado:** La herramienta está 2 unidades adelante del personaje.

### Configuración 4: Con Rotación

```lua
local motor = Instance.new("Motor6D")
motor.Part0 = torso
motor.Part1 = arm
motor.C0 = CFrame.new(1.5, 0, 0) * CFrame.Angles(0, 0, math.rad(45))
motor.C1 = CFrame.new(0, 0, 0)
motor.Parent = torso
```

**Resultado:** El brazo está a 1.5 unidades a la derecha y rotado 45 grados.

### Configuración 5: Offset Complejo (Balón)

Basado en el código del proyecto:

```lua
local motor = Instance.new("Motor6D")
motor.Name = "BallMotor"
motor.Part0 = rootPart
motor.Part1 = ball
motor.C0 = CFrame.new(0, -2, -2)  -- 2 abajo, 2 atrás
motor.C1 = CFrame.new(0, 0, 0)
motor.Parent = ball
```

**Resultado:** El balón está detrás y debajo del jugador.

## 🔄 Entendiendo C0 y C1

### C0 - Offset de Part0

`C0` define dónde está el "punto de conexión" en Part0.

```
Part0 (Torso)
    │
    │ C0 = (0, 2, 0)  ← Punto de conexión aquí
    │
    ▼
  Part1 (Balón)
```

### C1 - Offset de Part1

`C1` define cómo se orienta Part1 respecto al punto de conexión.

```
Part0
    │
    │ C0
    │
    ▼
  Part1
    │
    │ C1  ← Orientación de Part1
    │
```

### Fórmula de Posición Final

La posición final de Part1 se calcula como:

```
Part1.CFrame = Part0.CFrame * C0 * C1:Inverse()
```

## 🎨 Ejemplos de CFrame

### Crear CFrame con Posición

```lua
-- CFrame.new(x, y, z)
CFrame.new(0, 0, 0)      -- Origen
CFrame.new(0, 5, 0)     -- 5 unidades arriba
CFrame.new(3, 0, -2)    -- 3 derecha, 2 atrás
```

### Crear CFrame con Rotación

```lua
-- CFrame.Angles(rx, ry, rz) en radianes
CFrame.Angles(0, 0, 0)                    -- Sin rotación
CFrame.Angles(0, math.rad(90), 0)         -- 90 grados en Y
CFrame.Angles(math.rad(45), 0, 0)         -- 45 grados en X
CFrame.Angles(0, 0, math.rad(180))       -- 180 grados en Z
```

### Combinar Posición y Rotación

```lua
-- Multiplicar CFrames
CFrame.new(0, 2, 0) * CFrame.Angles(0, math.rad(90), 0)
-- Primero posición, luego rotación

-- O al revés
CFrame.Angles(0, math.rad(90), 0) * CFrame.new(0, 2, 0)
-- Primero rotación, luego posición (diferente resultado)
```

## 📐 Configuraciones por Caso de Uso

### Caso 1: Conectar Brazo al Torso

```lua
motor.Part0 = torso
motor.Part1 = leftArm
motor.C0 = CFrame.new(-1.5, 0.5, 0)  -- Izquierda del torso
motor.C1 = CFrame.new(0, -0.5, 0)     -- Ajuste fino del brazo
motor.Parent = torso
```

### Caso 2: Conectar Cabeza al Torso

```lua
motor.Part0 = torso
motor.Part1 = head
motor.C0 = CFrame.new(0, 1.5, 0)  -- Arriba del torso
motor.C1 = CFrame.new(0, 0, 0)
motor.Parent = torso
```

### Caso 3: Conectar Herramienta a la Mano

```lua
motor.Part0 = leftHand
motor.Part1 = tool.Handle
motor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
motor.C1 = CFrame.new(0, 0, 0)
motor.Parent = leftHand
```

### Caso 4: Conectar Balón al Jugador

```lua
motor.Part0 = player.Character.HumanoidRootPart
motor.Part1 = ball
motor.C0 = CFrame.new(0, -2, -2)  -- Detrás y abajo
motor.C1 = CFrame.new(0, 0, 0)
motor.Parent = ball
```

## 🔧 Funciones Helper para Configuración

### Helper para Offset Simple

```lua
local function setMotorOffset(motor, x, y, z)
    motor.C0 = CFrame.new(x or 0, y or 0, z or 0)
    motor.C1 = CFrame.new(0, 0, 0)
end

-- Uso
setMotorOffset(motor, 0, 2, 0)  -- 2 unidades arriba
```

### Helper para Offset con Rotación

```lua
local function setMotorOffsetWithRotation(motor, x, y, z, rx, ry, rz)
    motor.C0 = CFrame.new(x or 0, y or 0, z or 0) * 
               CFrame.Angles(
                   math.rad(rx or 0),
                   math.rad(ry or 0),
                   math.rad(rz or 0)
               )
    motor.C1 = CFrame.new(0, 0, 0)
end

-- Uso
setMotorOffsetWithRotation(motor, 0, 2, 0, 0, 90, 0)  -- 2 arriba, rotado 90° en Y
```

## ⚙️ Modificar Motor Existente

### Cambiar Offset Dinámicamente

```lua
-- Cambiar C0 mientras el motor está activo
motor.C0 = CFrame.new(0, 3, 0)  -- Cambiar altura

-- Cambiar con rotación
motor.C0 = CFrame.new(0, 2, 0) * CFrame.Angles(0, math.rad(45), 0)
```

### Activar/Desactivar Motor

```lua
-- Desactivar temporalmente
motor.Enabled = false
-- Las partes se desconectan pero el motor sigue existiendo

-- Reactivar
motor.Enabled = true
-- Las partes se vuelven a conectar
```

### Cambiar Partes

```lua
-- Cambiar Part1 (conectar a otra parte)
motor.Part1 = newPart
-- El motor ahora conecta Part0 con newPart
```

## ✅ Mejores Prácticas de Configuración

1. **Siempre configura C0 y C1** (aunque sea CFrame.new())
2. **Usa nombres descriptivos** para facilitar debugging
3. **Verifica que las partes existan** antes de configurar
4. **Establece Parent al final** después de configurar todo
5. **Usa CFrame.Angles con math.rad()** para rotaciones
6. **Documenta offsets complejos** con comentarios

## 📚 Siguiente Paso

Ahora que sabes configurar un Motor6D, ve ejemplos prácticos en el siguiente documento.

---

**Siguiente:** [Ejemplos Prácticos](./04_ejemplos_practicos.md)

