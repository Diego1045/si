# Guía Rápida de Referencia - Motor6D

## ⚡ Creación Rápida

```lua
local motor = Instance.new("Motor6D")
motor.Part0 = part1
motor.Part1 = part2
motor.C0 = CFrame.new(0, 0, 0)
motor.C1 = CFrame.new(0, 0, 0)
motor.Parent = part1
```

## 📋 Propiedades Esenciales

| Propiedad | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `Part0` | BasePart | ✅ Sí | Parte base (ancla) |
| `Part1` | BasePart | ✅ Sí | Parte conectada |
| `Parent` | Instance | ✅ Sí | Debe ser Part0 o Part1 |
| `C0` | CFrame | ⚠️ Recomendado | Offset de Part0 |
| `C1` | CFrame | ⚠️ Recomendado | Offset de Part1 |
| `Name` | string | ❌ No | Nombre del motor |
| `Enabled` | boolean | ❌ No | Activar/desactivar |

## 🎯 Offsets Comunes

```lua
-- Sin offset
CFrame.new(0, 0, 0)

-- Arriba
CFrame.new(0, 2, 0)

-- Abajo
CFrame.new(0, -2, 0)

-- Adelante
CFrame.new(0, 0, -2)

-- Atrás
CFrame.new(0, 0, 2)

-- Con rotación (90 grados en Y)
CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
```

## 🔧 Funciones Helper

### Crear Motor Simple

```lua
local function createMotor(part0, part1, offset, name)
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

### Destruir Motor

```lua
local function destroyMotor(part, motorName)
    local motor = part:FindFirstChild(motorName)
    if motor and motor:IsA("Motor6D") then
        motor:Destroy()
    end
end
```

### Limpiar Todos los Motores

```lua
local function cleanupMotors(parent)
    for _, motor in ipairs(parent:GetDescendants()) do
        if motor:IsA("Motor6D") then
            motor:Destroy()
        end
    end
end
```

## ✅ Checklist Rápido

- [ ] Script del servidor (no LocalScript)
- [ ] Part0 existe y no es nil
- [ ] Part1 existe y no es nil
- [ ] C0 configurado
- [ ] C1 configurado
- [ ] Parent es Part0 o Part1
- [ ] Nombre descriptivo (opcional)

## 🚨 Errores Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| Part0 is nil | Parte no existe | Usar `WaitForChild()` |
| Parent incorrecto | Parent no es Part0/Part1 | `motor.Parent = motor.Part0` |
| No funciona | Creado en cliente | Crear en Script (servidor) |
| Rotación incorrecta | Grados en lugar de radianes | Usar `math.rad()` |

## 📚 Referencias Rápidas

- **CFrame.new(x, y, z)** - Crear CFrame con posición
- **CFrame.Angles(rx, ry, rz)** - Crear CFrame con rotación (radianes)
- **math.rad(grados)** - Convertir grados a radianes
- **motor:Destroy()** - Destruir motor
- **motor.Enabled = false** - Desactivar temporalmente

## 🎮 Ejemplos por Caso de Uso

### Conectar Balón
```lua
motor.C0 = CFrame.new(0, -2, -2)  -- Detrás y abajo
```

### Conectar Herramienta
```lua
motor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
```

### Conectar Brazo
```lua
motor.C0 = CFrame.new(-1.5, 0.5, 0)  -- Izquierda del torso
```

### Conectar Cabeza
```lua
motor.C0 = CFrame.new(0, 1.5, 0)  -- Arriba del torso
```

---

**Para más detalles, consulta la documentación completa en el README.md**

