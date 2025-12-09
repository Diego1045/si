# Cómo Crear Partes mediante Scripts en Roblox

## 📚 Introducción

En Roblox, puedes crear partes (objetos 3D) dinámicamente mediante scripts usando `Instance.new("Part")`. Esto es útil para crear objetos en tiempo de ejecución, como plataformas, obstáculos, decoraciones, etc.

---

## 🚀 Método Básico

### Paso 1: Crear la Instancia

```lua
local nuevaParte = Instance.new("Part")
```

### Paso 2: Configurar Propiedades

```lua
nuevaParte.Size = Vector3.new(4, 1, 2)  -- Ancho, Alto, Profundidad
nuevaParte.Position = Vector3.new(0, 5, 0)  -- Posición X, Y, Z
nuevaParte.Anchored = true  -- Fijar en su lugar
nuevaParte.Color = Color3.fromRGB(255, 0, 0)  -- Color rojo
```

### Paso 3: Establecer el Parent

```lua
nuevaParte.Parent = workspace  -- Aparece en el juego
```

---

## 📝 Ejemplo Completo Básico

```lua
-- Crear una nueva parte
local nuevaParte = Instance.new("Part")

-- Configurar propiedades básicas
nuevaParte.Name = "MiParte"
nuevaParte.Size = Vector3.new(4, 1, 2)
nuevaParte.Position = Vector3.new(0, 5, 0)
nuevaParte.Anchored = true
nuevaParte.Color = Color3.fromRGB(255, 0, 0)  -- Rojo
nuevaParte.Material = Enum.Material.Plastic

-- Agregar al workspace
nuevaParte.Parent = workspace

print("Parte creada exitosamente!")
```

---

## 🔧 Propiedades Comunes de Part

### Propiedades Básicas

| Propiedad | Tipo | Descripción | Ejemplo |
|-----------|------|-------------|---------|
| `Name` | string | Nombre de la parte | `"MiParte"` |
| `Size` | Vector3 | Tamaño (X, Y, Z) | `Vector3.new(4, 1, 2)` |
| `Position` | Vector3 | Posición en el mundo | `Vector3.new(0, 5, 0)` |
| `Anchored` | boolean | Si está fija (no cae) | `true` o `false` |
| `Color` | Color3 | Color RGB | `Color3.fromRGB(255, 0, 0)` |
| `Material` | Enum.Material | Material/textura | `Enum.Material.Neon` |
| `Shape` | Enum.PartType | Forma de la parte | `Enum.PartType.Ball` |
| `Parent` | Instance | Dónde se coloca | `workspace` |

### Propiedades de Física

| Propiedad | Tipo | Descripción | Ejemplo |
|-----------|------|-------------|---------|
| `CanCollide` | boolean | Si puede chocar con otras partes | `true` |
| `CanTouch` | boolean | Si puede activar eventos Touch | `true` |
| `Massless` | boolean | Si no tiene masa física | `false` |
| `CollisionGroup` | string | Grupo de colisión | `"Default"` |
| `Transparency` | number | Transparencia (0-1) | `0.5` |

### Propiedades de Rotación

| Propiedad | Tipo | Descripción | Ejemplo |
|-----------|------|-------------|---------|
| `CFrame` | CFrame | Posición y rotación | `CFrame.new(0, 5, 0)` |
| `Orientation` | Vector3 | Rotación en grados | `Vector3.new(0, 90, 0)` |

---

## 🎨 Formas de Partes (Shape)

```lua
-- Bloque (por defecto)
part.Shape = Enum.PartType.Block

-- Esfera
part.Shape = Enum.PartType.Ball

-- Cilindro
part.Shape = Enum.PartType.Cylinder
```

---

## 🌈 Materiales Comunes

```lua
-- Plástico (por defecto)
part.Material = Enum.Material.Plastic

-- Neón (brillante)
part.Material = Enum.Material.Neon

-- Metal
part.Material = Enum.Material.Metal

-- Concreto
part.Material = Enum.Material.Concrete

-- Hielo
part.Material = Enum.Material.Ice

-- Vidrio
part.Material = Enum.Material.Glass
```

---

## 🔧 Funciones Helper

### Función Helper Básica

```lua
local function createPart(name, size, position, color, material)
    local part = Instance.new("Part")
    part.Name = name or "Part"
    part.Size = size or Vector3.new(4, 1, 2)
    part.Position = position or Vector3.new(0, 5, 0)
    part.Anchored = true
    part.Color = color or Color3.fromRGB(255, 255, 255)
    part.Material = material or Enum.Material.Plastic
    part.Parent = workspace
    return part
end

-- Uso
local miParte = createPart(
    "MiParte",
    Vector3.new(4, 1, 2),
    Vector3.new(0, 5, 0),
    Color3.fromRGB(255, 0, 0),
    Enum.Material.Neon
)
```

### Función Helper Avanzada

```lua
local function createPartAdvanced(config)
    local part = Instance.new("Part")
    
    -- Propiedades básicas
    part.Name = config.name or "Part"
    part.Size = config.size or Vector3.new(4, 1, 2)
    part.Position = config.position or Vector3.new(0, 5, 0)
    part.CFrame = config.cframe or CFrame.new(config.position or Vector3.new(0, 5, 0))
    
    -- Propiedades visuales
    part.Color = config.color or Color3.fromRGB(255, 255, 255)
    part.Material = config.material or Enum.Material.Plastic
    part.Shape = config.shape or Enum.PartType.Block
    part.Transparency = config.transparency or 0
    
    -- Propiedades físicas
    part.Anchored = config.anchored ~= false  -- Por defecto true
    part.CanCollide = config.canCollide ~= false  -- Por defecto true
    part.CanTouch = config.canTouch ~= false  -- Por defecto true
    part.Massless = config.massless or false
    part.CollisionGroup = config.collisionGroup or "Default"
    
    -- Parent
    part.Parent = config.parent or workspace
    
    return part
end

-- Uso
local miParte = createPartAdvanced({
    name = "MiParte",
    size = Vector3.new(4, 1, 2),
    position = Vector3.new(0, 5, 0),
    color = Color3.fromRGB(255, 0, 0),
    material = Enum.Material.Neon,
    shape = Enum.PartType.Ball,
    anchored = false,
    canCollide = true,
    parent = workspace
})
```

---

## ⚠️ Errores Comunes y Cómo Evitarlos

### Error 1: No Establecer Parent

```lua
-- ❌ MAL - La parte no aparecerá
local part = Instance.new("Part")
part.Size = Vector3.new(4, 1, 2)
-- Falta: part.Parent = workspace

-- ✅ BIEN - La parte aparecerá
local part = Instance.new("Part")
part.Size = Vector3.new(4, 1, 2)
part.Parent = workspace
```

### Error 2: Partes Caen al Vacío

```lua
-- ❌ MAL - La parte cae si no está anclada
local part = Instance.new("Part")
part.Position = Vector3.new(0, 100, 0)
part.Anchored = false  -- Caerá
part.Parent = workspace

-- ✅ BIEN - Anclar o poner en el suelo
local part = Instance.new("Part")
part.Position = Vector3.new(0, 5, 0)
part.Anchored = true  -- No caerá
part.Parent = workspace
```

### Error 3: Usar BrickColor (Deprecated)

```lua
-- ❌ MAL - BrickColor está deprecado
part.BrickColor = BrickColor.new("Bright red")

-- ✅ BIEN - Usar Color
part.Color = Color3.fromRGB(255, 0, 0)
-- O
part.Color = Color3.fromRGB(255, 0, 0)
```

### Error 4: Crear en el Cliente (LocalScript)

```lua
-- ⚠️ ADVERTENCIA - Partes creadas en LocalScript solo son visibles para ese jugador
-- LocalScript (cliente)
local part = Instance.new("Part")
part.Parent = workspace  -- Solo visible para el jugador local

-- ✅ BIEN - Crear en el servidor para que todos lo vean
-- Script (servidor)
local part = Instance.new("Part")
part.Parent = workspace  -- Visible para todos
```

---

## 🎨 Patrones de Creación Comunes

### Patrón 1: Crear Múltiples Partes

```lua
local function createMultipleParts(count, spacing)
    local parts = {}
    
    for i = 1, count do
        local part = Instance.new("Part")
        part.Name = "Part_" .. i
        part.Size = Vector3.new(4, 1, 2)
        part.Position = Vector3.new(i * spacing, 5, 0)
        part.Anchored = true
        part.Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        part.Parent = workspace
        
        table.insert(parts, part)
    end
    
    return parts
end

-- Crear 10 partes con espaciado de 5
local partes = createMultipleParts(10, 5)
```

### Patrón 2: Crear Parte con Hijos

```lua
local function createPartWithChildren()
    local part = Instance.new("Part")
    part.Name = "ParentPart"
    part.Size = Vector3.new(4, 4, 4)
    part.Position = Vector3.new(0, 5, 0)
    part.Anchored = true
    part.Parent = workspace
    
    -- Crear hijo (SurfaceGui, etc.)
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Parent = part
    
    return part
end
```

### Patrón 3: Crear y Destruir Dinámicamente

```lua
local function createTemporaryPart(duration)
    local part = Instance.new("Part")
    part.Name = "TemporaryPart"
    part.Size = Vector3.new(4, 1, 2)
    part.Position = Vector3.new(0, 5, 0)
    part.Anchored = true
    part.Color = Color3.fromRGB(255, 255, 0)  -- Amarillo
    part.Parent = workspace
    
    -- Destruir después de un tiempo
    task.delay(duration, function()
        if part and part.Parent then
            part:Destroy()
        end
    end)
    
    return part
end

-- Crear parte que desaparece después de 5 segundos
local tempPart = createTemporaryPart(5)
```

---

## 📋 Checklist de Creación

Antes de crear una parte, asegúrate de:

- [ ] Usar `Instance.new("Part")`
- [ ] Configurar `Size` (Vector3)
- [ ] Configurar `Position` o `CFrame`
- [ ] Decidir si `Anchored` debe ser `true` o `false`
- [ ] Configurar `Color` o `Material` (opcional)
- [ ] Establecer `Parent` (workspace, modelo, etc.)
- [ ] Configurar `CanCollide` si es necesario
- [ ] Configurar `CanTouch` si necesitas eventos Touch
- [ ] Asignar un `Name` descriptivo

---

## 🔍 Verificar si una Parte Existe

```lua
-- Verificar si existe
local part = workspace:FindFirstChild("MiParte")
if part and part:IsA("BasePart") then
    print("La parte existe!")
else
    print("La parte no existe, creándola...")
    -- Crear la parte
end
```

---

## 📚 Referencias Adicionales

- **Roblox Developer Hub**: [Part Object](https://create.roblox.com/docs/reference/engine/classes/Part)
- **Roblox Developer Hub**: [Instance.new](https://create.roblox.com/docs/reference/engine/functions/Instance/new)
- **Roblox Developer Hub**: [BasePart](https://create.roblox.com/docs/reference/engine/classes/BasePart)

---

## ✅ Resumen

1. **Crear**: `Instance.new("Part")`
2. **Configurar**: Propiedades (Size, Position, Color, etc.)
3. **Parent**: Establecer `Parent` para que aparezca
4. **Verificar**: Comprobar que existe antes de usarla
5. **Destruir**: Usar `:Destroy()` cuando ya no se necesite

¡Ahora puedes crear partes dinámicamente en tus scripts de Roblox!

