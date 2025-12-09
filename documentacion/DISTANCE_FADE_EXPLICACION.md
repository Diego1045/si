# Explicación: Sistema Distance Fade

## 📚 Resumen General

El sistema **Distance Fade** es un efecto visual que muestra una textura circular en las caras de partes 3D, que aparece/desaparece según la distancia del jugador. El efecto se vuelve más visible cuando el jugador está cerca y se desvanece cuando se aleja.

---

## 🎯 1. DistanceFade.lua (ModuleScript)

### ¿Qué es?
Es un **ModuleScript** que contiene toda la lógica del efecto. Funciona como una clase que puedes instanciar y configurar.

### Componentes Principales

#### **A. Configuración por Defecto (DEFAULT_SETTINGS)**

```lua
DEFAULT_SETTINGS = {
    ["DistanceOuter"] = 16,      -- Distancia donde el efecto empieza a aparecer
    ["DistanceInner"] = 4,       -- Distancia donde el efecto está completamente visible
    ["EffectRadius"] = 16,       -- Tamaño del efecto cuando está en rango
    ["EffectRadiusMin"] = 0,     -- Tamaño del efecto cuando está fuera de rango
    ["Texture"] = "rbxassetid://...",  -- ID de la textura a mostrar
    ["TextureTransparency"] = 0,  -- Transparencia cuando está cerca (0 = opaco)
    ["TextureTransparencyMin"] = 1, -- Transparencia cuando está lejos (1 = invisible)
    -- ... más configuraciones
}
```

#### **B. Funciones Clave**

1. **`DistanceFade.new()`**
   - Crea una nueva instancia del efecto
   - Inicializa carpetas en `workspace` para almacenar las partes
   - Retorna un objeto con métodos para controlar el efecto

2. **`AddFace(part, normal)`**
   - Agrega una cara de una parte al sistema
   - Crea una `SurfacePart` (parte invisible) y un `SurfaceGui` (interfaz visual)
   - El `SurfaceGui` muestra la textura en la cara especificada

3. **`Step(targetPos)`**
   - **FUNCIÓN PRINCIPAL**: Se llama cada frame (en `RunService.Heartbeat`)
   - Calcula la distancia del jugador a cada cara
   - Ajusta el tamaño y transparencia del efecto según la distancia
   - Mueve y escala el `SurfacePart` para seguir al jugador

4. **`UpdateSettings(settingsTable)`**
   - Permite cambiar la configuración del efecto en tiempo de ejecución

### Cómo Funciona el Efecto

1. **Creación de Superficies**:
   - Para cada cara agregada, se crea una `Part` invisible (`SurfacePart`)
   - Esta parte se posiciona justo en frente de la cara objetivo
   - Se crea un `SurfaceGui` que muestra la textura

2. **Cálculo de Distancia**:
   - Cada frame, se calcula la distancia del jugador a la cara
   - Si la distancia está entre `DistanceInner` y `DistanceOuter`, el efecto aparece gradualmente
   - Si está más cerca que `DistanceInner`, el efecto está completamente visible
   - Si está más lejos que `DistanceOuter`, el efecto está oculto

3. **Ajuste Visual**:
   - El tamaño del efecto se ajusta según la distancia (`EffectRadius` → `EffectRadiusMin`)
   - La transparencia se interpola entre `TextureTransparency` y `TextureTransparencyMin`
   - El efecto sigue al jugador moviéndose sobre la superficie

4. **Sistema de Tiles (Baldosas)**:
   - El efecto se divide en una cuadrícula de 4x4 (16 tiles)
   - Cada tile tiene un `UIGradient` que crea un efecto circular
   - Los tiles de las esquinas y bordes tienen diferentes configuraciones de gradiente

---

## 🎨 2. Hexagon.lua (LocalScript)

### ¿Qué es?
Es un **LocalScript** que usa `DistanceFade` para aplicar el efecto a partes hexagonales específicas.

### Flujo de Funcionamiento

1. **Inicialización**:
   ```lua
   local distanceFade = DistanceFade.new()
   ```
   - Crea una nueva instancia del efecto

2. **Configuración Personalizada**:
   ```lua
   distanceFadeSettings = {
       ["Texture"] = "rbxassetid://18852900044",  -- Textura específica
       ["TextureColor"] = Color3.fromRGB(115, 248, 255),  -- Color cian
       ["TextureSize"] = Vector2.new(6, 5.5),  -- Tamaño de la textura
       ["Brightness"] = 3,  -- Brillo aumentado
   }
   distanceFade:UpdateSettings(distanceFadeSettings)
   ```

3. **Agregar Caras**:
   ```lua
   for _,basePart in partsToAdd do
       distanceFade:AddFace(basePart, Enum.NormalId.Front)  -- Cara frontal
       distanceFade:AddFace(basePart, Enum.NormalId.Back)   -- Cara trasera
   end
   ```
   - Agrega el efecto a las caras frontal y trasera de 7 partes (hexágonos numerados del 1 al 7)

4. **Animación de Offset**:
   ```lua
   local tweenValue = Instance.new("Vector3Value")
   -- Tween que anima el offset de la textura
   TweenService:Create(tweenValue, TweenInfo.new(6, ...), { Value = Vector3.new(-6, 5.5) }):Play()
   ```
   - Crea una animación que mueve la textura continuamente
   - El offset se actualiza cada frame para crear un efecto de movimiento

5. **Loop Principal**:
   ```lua
   RunService.Heartbeat:Connect(function()
       -- Actualiza el offset de cada cara
       for _,v in partsToAdd do
           local offsetX = baseOffsetsX[v.Name]  -- Offset base según el hexágono
           local offsetY = tweenValue.Value.Y     -- Offset animado
           distanceFade:UpdateFaceSettings(v, Enum.NormalId.Front, {
               ["TextureOffset"] = Vector2.new(offsetX, offsetY)
           })
       end
       distanceFade:Step()  -- Actualiza el efecto
   end)
   ```

### Características Especiales

- **Offsets Base**: Cada hexágono tiene un offset X diferente para que el efecto sea continuo entre partes adyacentes
- **Animación Continua**: La textura se mueve verticalmente en un loop infinito
- **Efecto Seamless**: Los offsets están calculados para que el efecto se vea continuo entre hexágonos

---

## 🔄 3. Distance.Fade.Inverse.lua (ModuleScript)

### ¿Qué es?
Es una **variante inversa** de `DistanceFade.lua`. La diferencia principal está en cómo se comporta la transparencia del gradiente.

### Diferencias Clave

#### **A. Transparencia Inversa**

En `DistanceFade.lua` (normal):
```lua
-- El efecto es visible en el centro, invisible en los bordes
NumberSequenceKeypoint.new(0, 1),      -- Borde: transparente (1)
NumberSequenceKeypoint.new(.444, 1),   -- 
NumberSequenceKeypoint.new(.555, 0),   -- Centro: opaco (0)
NumberSequenceKeypoint.new(1, 0)       -- 
```

En `Distance.Fade.Inverse.lua` (inverso):
```lua
-- El efecto es invisible en el centro, visible en los bordes
NumberSequenceKeypoint.new(0, 0),      -- Borde: opaco (0)
NumberSequenceKeypoint.new(.444, 0),   -- 
NumberSequenceKeypoint.new(.555, 1),   -- Centro: transparente (1)
NumberSequenceKeypoint.new(1, 1)       -- 
```

#### **B. Grid Modificado**

En la función `CreateGrid()`:
```lua
if #tiles == 6 or #tiles == 7 or #tiles == 10 or #tiles == 11 then
    tile.Visible = false  -- Oculta tiles centrales
end
```
- Oculta los tiles del centro (6, 7, 10, 11) para crear un efecto de "anillo" o "donut"

### Uso del Efecto Inverso

- **Efecto Normal**: El círculo es más brillante en el centro
- **Efecto Inverso**: El círculo es más brillante en los bordes (como un anillo)

---

## 🔧 Flujo Completo del Sistema

```
1. INICIALIZACIÓN
   └─> DistanceFade.new()
       └─> Crea carpetas en workspace
       └─> Inicializa configuración por defecto

2. CONFIGURACIÓN
   └─> UpdateSettings() - Ajusta parámetros
   └─> AddFace() - Agrega caras al sistema
       └─> Crea SurfacePart (invisible)
       └─> Crea SurfaceGui (visual)
       └─> Crea grid de 16 tiles con gradientes

3. LOOP PRINCIPAL (cada frame)
   └─> Step()
       ├─> Calcula distancia jugador → cara
       ├─> Determina si el efecto debe estar visible
       ├─> Ajusta tamaño del SurfacePart
       ├─> Ajusta transparencia de la textura
       ├─> Mueve SurfacePart para seguir al jugador
       └─> Actualiza posición/transparencia de cada tile

4. LIMPIEZA
   └─> RemoveFace() - Elimina una cara
   └─> Clear() - Elimina todo el efecto
```

---

## 📊 Conceptos Técnicos Importantes

### 1. **SurfaceGui**
- Es un tipo de GUI que se proyecta sobre una superficie 3D
- Se usa para mostrar interfaces en las caras de partes
- `Adornee` = la parte sobre la que se proyecta
- `Face` = qué cara de la parte usar

### 2. **UIGradient**
- Crea un gradiente de transparencia/color
- Se usa en cada tile para crear el efecto circular
- `Transparency` = curva que define cómo cambia la transparencia
- `Rotation` = ángulo del gradiente

### 3. **NumberSequence**
- Define una curva de valores (0 a 1)
- Se usa para la transparencia del gradiente
- `NumberSequenceKeypoint` = punto en la curva (tiempo, valor)

### 4. **Cálculo de Distancia**
- **Normal**: Distancia perpendicular a la cara (más suave)
- **Edge**: Distancia desde los bordes de la cara (más precisa cuando te mueves paralelo)

---

## 🎮 Ejemplo de Uso Básico

```lua
-- En un LocalScript
local DistanceFade = require(script.Parent.DistanceFade)

-- Crear instancia
local effect = DistanceFade.new()

-- Configurar
effect:UpdateSettings({
    ["DistanceOuter"] = 20,
    ["DistanceInner"] = 5,
    ["Texture"] = "rbxassetid://123456789",
    ["TextureColor"] = Color3.fromRGB(255, 0, 0)
})

-- Agregar cara a una parte
local myPart = workspace:FindFirstChild("MyPart")
effect:AddFace(myPart, Enum.NormalId.Front)

-- Actualizar cada frame
game:GetService("RunService").Heartbeat:Connect(function()
    effect:Step()  -- Usa la posición del jugador automáticamente
end)
```

---

## ✅ Resumen

1. **DistanceFade.lua**: Módulo principal que crea el efecto visual
2. **Hexagon.lua**: Ejemplo de uso que aplica el efecto a hexágonos con animación
3. **Distance.Fade.Inverse.lua**: Variante que invierte el efecto (anillo en lugar de círculo)

El sistema es **client-side only** (solo funciona en el cliente) y crea efectos visuales dinámicos que responden a la distancia del jugador.

