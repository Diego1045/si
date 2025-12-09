# Cómo el Sistema Identifica las Partes para el Efecto

## 🎯 Pregunta: ¿Cómo sabe el sistema qué partes tienen el efecto y cuáles son?

---

## 📦 Almacenamiento: La Tabla `TargetParts`

### Estructura de Datos

El sistema usa una tabla llamada `TargetParts` que funciona como un **diccionario**:

```lua
TargetParts = {
    [Part1] = {
        [Enum.NormalId.Front] = { info del efecto },
        [Enum.NormalId.Back] = { info del efecto }
    },
    [Part2] = {
        [Enum.NormalId.Front] = { info del efecto }
    },
    -- etc...
}
```

**Estructura:**
- **Clave principal**: La referencia directa a la `Part` (BasePart)
- **Clave secundaria**: El `NormalId` (Front, Back, Left, Right, Top, Bottom)
- **Valor**: Información del efecto (SurfacePart, SurfaceGui, etc.)

---

## 🔍 Cómo se Identifican las Partes

### 1. **Por Referencia Directa (NO por Nombre)**

El sistema **NO** identifica las partes por su nombre, sino por su **referencia directa en memoria**.

```lua
-- En Hexagon.lua
local partsToAdd = {
    folder:WaitForChild("1"),  -- Obtiene la referencia a la parte "1"
    folder:WaitForChild("2"),  -- Obtiene la referencia a la parte "2"
    -- etc...
}
```

**¿Qué significa esto?**
- Cuando haces `folder:WaitForChild("1")`, obtienes la **referencia directa** a esa parte
- Esa referencia se guarda en la tabla `partsToAdd`
- Esa misma referencia se usa como **clave** en `TargetParts`

### 2. **Agregar Partes al Sistema**

Cuando llamas `AddFace()`, el sistema:

```lua
function DistanceFade:AddFace(targetPart, normal)
    -- targetPart es la REFERENCIA DIRECTA a la parte
    
    if self.TargetParts[targetPart] == nil then
        self.TargetParts[targetPart] = {}  -- Crea entrada si no existe
    end
    
    self.TargetParts[targetPart][normal] = info  -- Guarda la información
end
```

**Ejemplo:**
```lua
-- En Hexagon.lua
local part1 = folder:WaitForChild("1")  -- Referencia a la parte "1"
distanceFade:AddFace(part1, Enum.NormalId.Front)

-- Internamente, el sistema hace:
-- TargetParts[part1][Enum.NormalId.Front] = { info del efecto }
```

---

## 🔄 Cómo se Iteran las Partes

### En la Función `Step()`

```lua
function DistanceFade:Step(targetPos)
    -- Itera sobre TODAS las partes registradas
    for targetPart, faces in self.TargetParts do
        -- targetPart = la referencia directa a la parte
        -- faces = tabla con las caras de esa parte
        
        for face, info in faces do
            -- face = Enum.NormalId (Front, Back, etc.)
            -- info = información del efecto (SurfacePart, SurfaceGui)
            
            -- Calcula distancia y muestra/oculta el efecto
        end
    end
end
```

**Proceso:**
1. Itera sobre `TargetParts` (todas las partes registradas)
2. Para cada parte, itera sobre sus caras (Front, Back, etc.)
3. Calcula la distancia del jugador a esa cara
4. Muestra u oculta el efecto según la distancia

---

## 📋 Partes Registradas en Hexagon.lua

### Partes Iniciales (Siempre Activas)

```lua
local partsToAdd = {
    folder:WaitForChild("1"),  -- Hexágono 1
    folder:WaitForChild("2"),  -- Hexágono 2
    folder:WaitForChild("3"),  -- Hexágono 3
    folder:WaitForChild("4"),  -- Hexágono 4
    folder:WaitForChild("5"),  -- Hexágono 5
    folder:WaitForChild("6"),  -- Hexágono 6
    folder:WaitForChild("7"),  -- Hexágono 7
}
```

**Estas partes se agregan al inicio:**
```lua
for _,basePart in partsToAdd do
    distanceFade:AddFace(basePart, Enum.NormalId.Front)  -- Cara frontal
    distanceFade:AddFace(basePart, Enum.NormalId.Back)     -- Cara trasera
end
```

**Resultado:**
- 7 partes × 2 caras = **14 efectos** siempre activos
- Estas partes están **siempre** en `TargetParts`

### Partes Temporales (Por Colisión)

```lua
-- Cuando el balón choca con una parte 1-7
distanceFade:AddFace(hitPart, normalId)  -- Se agrega temporalmente
```

**Estas partes se agregan cuando:**
- El balón choca con una parte 1-7
- Se agregan a `TargetParts` temporalmente
- Se eliminan después de 1.5 segundos

---

## 🎯 Identificación Específica

### ¿Cómo sabe que es la parte "1" y no otra?

El sistema **NO** identifica por nombre, sino por **referencia directa**:

```lua
-- Cuando obtienes la parte
local part1 = folder:WaitForChild("1")  -- Referencia única a esa parte

-- Cuando la agregas
distanceFade:AddFace(part1, Enum.NormalId.Front)

-- El sistema guarda:
-- TargetParts[part1] = { ... }  -- part1 es la CLAVE
```

**Ventajas:**
- ✅ Más rápido (comparación directa de referencias)
- ✅ Más seguro (no hay confusión con nombres duplicados)
- ✅ Funciona aunque cambies el nombre de la parte

**Desventajas:**
- ⚠️ Si la parte se destruye y se recrea, necesitas agregarla de nuevo

---

## 📊 Ejemplo Completo

### Estado Inicial

```lua
TargetParts = {
    [Part1] = {
        [Front] = { efecto },
        [Back] = { efecto }
    },
    [Part2] = {
        [Front] = { efecto },
        [Back] = { efecto }
    },
    -- ... hasta Part7
}
```

### Después de una Colisión

```lua
-- Balón choca con Part4
distanceFade:AddFace(Part4, Enum.NormalId.Left)

-- TargetParts ahora tiene:
TargetParts = {
    [Part1] = { ... },
    [Part2] = { ... },
    [Part4] = {
        [Front] = { efecto },   -- Ya existía
        [Back] = { efecto },   -- Ya existía
        [Left] = { efecto }     -- NUEVO (por colisión)
    },
    -- ...
}
```

### Después de 1.5 segundos

```lua
-- Se elimina el efecto de colisión
distanceFade:RemoveFace(Part4, Enum.NormalId.Left)

-- TargetParts vuelve a:
TargetParts = {
    [Part4] = {
        [Front] = { efecto },   -- Se mantiene
        [Back] = { efecto }     -- Se mantiene
        -- [Left] eliminado
    },
    -- ...
}
```

---

## 🔑 Puntos Clave

1. **Identificación por Referencia**: Las partes se identifican por su referencia directa, no por nombre
2. **Tabla TargetParts**: Almacena todas las partes con efecto activo
3. **Iteración Completa**: `Step()` revisa TODAS las partes en `TargetParts` cada frame
4. **Partes Permanentes**: Hexágonos 1-7 siempre están registrados
5. **Partes Temporales**: Paredes se agregan/eliminan dinámicamente por colisiones

---

## ✅ Resumen

**¿Cómo sabe qué partes tienen el efecto?**
- Usa la tabla `TargetParts` que almacena referencias directas a las partes
- Las partes se identifican por su referencia en memoria, no por nombre

**¿Cuáles son esas partes?**
- **Permanentes**: Hexágonos 1, 2, 3, 4, 5, 6, 7 (siempre activos)
- **Temporales**: Partes 1-7 cuando el balón choca con ellas (se agregan por 1.5 segundos)

**¿Cómo las encuentra?**
- `Step()` itera sobre `TargetParts` cada frame
- Calcula la distancia del jugador a cada parte
- Muestra/oculta el efecto según la distancia

