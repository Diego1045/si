# 💪 Cómo Funciona la Barra de Fuerza para Disparar el Balón

Este documento explica cómo crear una barra de fuerza que funcione igual que la barra de estamina, posicionada al lado del jugador.

## 🎯 Concepto General

La barra de fuerza debe comportarse **exactamente igual** que la barra de estamina (`StaminaBar_actualizado.lua`), pero con estas diferencias:

- **Se muestra solo cuando el jugador está cargando** el disparo (mantiene presionado clic izquierdo)
- **Se llena de 0 a 100** mientras el jugador mantiene presionado
- **Se vacía automáticamente** cuando el jugador suelta el clic
- **Solo funciona si el jugador tiene el balón**

## 📐 Estructura de la UI (Igual que Stamina)

**⚠️ IMPORTANTE: Necesitas crear la estructura de UI en el Character, NO solo scripts.**

La barra de fuerza necesita la misma estructura que la barra de estamina. Si ya tienes una barra de estamina funcionando, puedes copiar su estructura y renombrarla.

### 📍 Dónde crear la UI

La UI debe estar **dentro del Character** (el Model del personaje), no en PlayerGui ni en otro lugar.

```
Character (Model)  ← En Workspace cuando el jugador está en el juego
├── HumanoidRootPart
├── Head
├── Torso
├── Stamina (BillboardGui)  ← Ya existe (copia esta estructura)
│   └── Frame
│       └── Bar
│           └── UIGradient
│
└── Power (BillboardGui)  ← NUEVO: Crear esto manualmente en Roblox Studio
    └── Frame
        └── Bar
            └── UIGradient
```

### 🎨 Pasos para crear la UI en Roblox Studio

1. **Selecciona el Character** en Workspace (cuando un jugador está en el juego)
2. **Crea un BillboardGui**:
   - Click derecho en el Character → Insert Object → BillboardGui
   - Renómbralo a `Power`
3. **Configura el BillboardGui "Power"**:
   - `Adornee`: Arrastra el `HumanoidRootPart` del Character aquí
   - `AlwaysOnTop`: ✅ true
   - `Size`: `{0, 20}, {0, 100}` (mismo tamaño que Stamina)
   - `StudsOffset`: `{2, 0, 0}` (al lado derecho, ajusta según necesites)
   - `Enabled`: ❌ false (comienza oculta)

4. **Crea el Frame contenedor**:
   - Click derecho en `Power` → Insert Object → Frame
   - Configura:
     - `Size`: `{1, 0}, {1, 0}` (ocupa todo el BillboardGui)
     - `BackgroundColor3`: Gris oscuro `{50, 50, 50}`
     - `BackgroundTransparency`: `0.3`
     - `BorderSizePixel`: `2`
     - `BorderColor3`: Blanco `{255, 255, 255}`

5. **Crea la Bar (la barra que se llena)**:
   - Click derecho en `Frame` → Insert Object → Frame
   - Renómbralo a `Bar`
   - Configura:
     - `Size`: `{1, 0}, {0, 0}` (comienza vacía)
     - `Position`: `{0, 0}, {1, 0}` (anclada abajo)
     - `AnchorPoint`: `{0, 1}` (anclada abajo)
     - `BackgroundColor3`: Verde `{0, 255, 0}` (se cambiará dinámicamente)
     - `BorderSizePixel`: `0`

6. **Agrega UIGradient a la Bar**:
   - Click derecho en `Bar` → Insert Object → UIGradient
   - Configura:
     - `Color`: Gradiente verde (se cambiará dinámicamente por el script)
     - `Rotation`: `90` (gradiente vertical)

### ⚙️ Configuración del BillboardGui "Power"

```lua
-- Mismo tamaño que Stamina
Size = UDim2.new(0, 20, 0, 100)

-- Posición al lado del jugador (ajustar según necesites)
StudsOffset = Vector3.new(2, 0, 0)  -- Al lado derecho

-- Comienza oculta
Enabled = false
```

### ⚙️ Configuración de la Bar

```lua
-- Anclada abajo (igual que Stamina)
AnchorPoint = Vector2.new(0, 1)
Position = UDim2.new(0, 0, 1, 0)

-- Comienza vacía
Size = UDim2.new(1, 0, 0, 0)
```

### 💡 Tip: Copiar desde Stamina

Si ya tienes la barra de estamina funcionando:

1. Selecciona el `Stamina` (BillboardGui) en el Character
2. Duplícalo (Ctrl+D o click derecho → Duplicate)
3. Renómbralo a `Power`
4. Cambia el `StudsOffset` para ponerla al otro lado
5. Cambia `Enabled` a `false`
6. Asegúrate de que la `Bar` dentro tenga `Size` en `{1, 0}, {0, 0}` (vacía)

## 🔧 Funcionamiento Técnico

### 1. Módulo PowerBar (Similar a StaminaBar)

El módulo debe seguir el mismo patrón que `StaminaBar_actualizado.lua`:

```lua
function PowerBar.Init(Character : Model)
    local Bar = script.Parent.Parent.Power  -- Accede al BillboardGui
    local ScaleBar = Bar.Frame.Bar
    local MaxOutput = 100
    local Count = Character:GetAttribute("power") or 0
    
    -- La barra comienza oculta
    Bar.Enabled = false
    
    -- Configuración igual que Stamina
    ScaleBar.AnchorPoint = Vector2.new(0, 1)
    ScaleBar.Position = UDim2.new(0, 0, 1, 0)
    
    local function UpdateBar()
        Count = Character:GetAttribute("power") or 0
        local isCharging = Character:GetAttribute("isCharging") or false
        
        -- Mostrar/ocultar según si está cargando
        Bar.Enabled = isCharging or (Count > 0)
        
        -- Calcular ratio de llenado (igual que Stamina)
        local fillRatio = math.clamp(Count / MaxOutput, 0, 1)
        local Goal = {}
        Goal.Size = UDim2.new(1, 0, fillRatio, 0)
        
        -- Animación con TweenService (igual que Stamina)
        local Tween = TweenService:Create(
            ScaleBar,
            TweenInfo.new(.1, Enum.EasingStyle.Quad),
            Goal
        )
        Tween:Play()
        
        -- Cambiar color según la fuerza
        if Count >= 80 then
            -- Rojo: Máxima potencia
            ScaleBar.UIGradient.Color = ColorSequence.new(
                Color3.fromRGB(255, 0, 0),
                Color3.fromRGB(255, 50, 0)
            )
        elseif Count >= 50 then
            -- Amarillo/Naranja: Potencia media
            ScaleBar.UIGradient.Color = ColorSequence.new(
                Color3.fromRGB(255, 200, 0),
                Color3.fromRGB(255, 150, 0)
            )
        else
            -- Verde: Baja potencia
            ScaleBar.UIGradient.Color = ColorSequence.new(
                Color3.fromRGB(0, 255, 0),
                Color3.fromRGB(100, 255, 0)
            )
        end
    end
    
    -- Escuchar cambios (igual que Stamina)
    Character:GetAttributeChangedSignal("power"):Connect(UpdateBar)
    Character:GetAttributeChangedSignal("isCharging"):Connect(UpdateBar)
    UpdateBar()
end
```

### 2. Script Cliente para Cargar la Fuerza

El script cliente debe:

1. **Detectar cuando el jugador tiene el balón** (usando `HasBall` attribute)
2. **Detectar clic izquierdo presionado** → Comenzar a cargar
3. **Incrementar `power` de 0 a 100** mientras se mantiene presionado
4. **Detectar clic izquierdo soltado** → Disparar y resetear

```lua
-- En RunService.Heartbeat
if isCharging and hasBall then
    powerValue = math.clamp(powerValue + chargeSpeed * dt, 0, 100)
    Character:SetAttribute("power", powerValue)
    Character:SetAttribute("isCharging", true)
else
    -- Descargar cuando no se está cargando
    if powerValue > 0 then
        powerValue = math.clamp(powerValue - dischargeSpeed * dt, 0, 100)
        Character:SetAttribute("power", powerValue)
    end
    Character:SetAttribute("isCharging", false)
end
```

### 3. Inicialización en el Character

Similar a cómo se inicializa la barra de estamina en `run_script_corregido.lua`:

```lua
local PowerBar = require(script.PowerBar)
local Character = script.Parent

-- Inicializar valores
Character:SetAttribute("power", 0)
Character:SetAttribute("isCharging", false)

-- Inicializar barra
PowerBar.Init(Character)
```

## 🎨 Diferencias Clave con la Barra de Estamina

| Aspecto | Barra de Estamina | Barra de Fuerza |
|---------|------------------|-----------------|
| **Visibilidad** | Siempre visible (`Bar.Enabled = true`) | Solo cuando carga (`Bar.Enabled = isCharging`) |
| **Se llena** | Al correr (Shift) | Al mantener clic izquierdo |
| **Se vacía** | Al dejar de correr | Al soltar clic o perder balón |
| **Valor máximo** | 100 | 100 |
| **Atributos** | `stamina`, `state` | `power`, `isCharging` |
| **Colores** | Rojo/Amarillo/Original | Verde/Amarillo/Rojo (invertido) |
| **Condición** | Solo si `stamina > 0` | Solo si `HasBall == true` |

## 🔄 Flujo Completo

1. **Jugador toma el balón** → `HasBall = true`
2. **Jugador presiona clic izquierdo** → `isCharging = true`, barra aparece
3. **Mientras mantiene presionado** → `power` aumenta de 0 a 100, barra se llena
4. **Jugador suelta clic** → Se dispara el balón, `power = 0`, `isCharging = false`, barra se oculta
5. **Si pierde el balón** → `power = 0`, `isCharging = false`, barra se oculta

## 📍 Posicionamiento al Lado del Jugador

La barra se posiciona igual que la de estamina usando `BillboardGui`:

- **`Adornee`**: `HumanoidRootPart` del personaje
- **`StudsOffset`**: `Vector3.new(2, 0, 0)` para ponerla al lado derecho
- **`AlwaysOnTop`**: `true` para que siempre sea visible
- **`Size`**: `UDim2.new(0, 20, 0, 100)` (mismo tamaño que Stamina)

Si quieres ponerla al lado izquierdo, usa `Vector3.new(-2, 0, 0)`.

## 🎯 Integración con el Sistema de Lanzamiento

Cuando el jugador suelta el clic:

1. **Convertir `power` (0-100) a valor 0-1** para el servidor
2. **Calcular dirección** usando `camera.CFrame.LookVector`
3. **Calcular ángulo vertical** usando `math.deg(math.asin(lookVector.Y))`
4. **Enviar al servidor** mediante `LaunchBall:FireServer(direction, power/100, angle)`
5. **Resetear valores**: `power = 0`, `isCharging = false`

## ✅ Resumen

### Lo que necesitas crear:

1. **✅ UI en el Character** (BillboardGui "Power" con Frame y Bar) - **DEBES CREARLO MANUALMENTE**
2. **✅ Scripts** (PowerBar.lua, script de inicialización, script cliente)

### La barra de fuerza funciona **exactamente igual** que la barra de estamina:

- ✅ Misma estructura de UI (BillboardGui → Frame → Bar)
- ✅ Mismo sistema de actualización (atributos del Character)
- ✅ Mismas animaciones (TweenService)
- ✅ Mismo posicionamiento (al lado del jugador)
- ✅ Mismo tamaño y estilo visual

**La única diferencia** es que:
- Se muestra solo cuando se está cargando
- Se controla con clic izquierdo en lugar de Shift
- Solo funciona si el jugador tiene el balón

### 📝 Checklist de implementación:

- [ ] Crear BillboardGui "Power" en el Character
- [ ] Crear Frame dentro de Power
- [ ] Crear Bar dentro de Frame
- [ ] Agregar UIGradient a Bar
- [ ] Configurar todos los valores (Size, Position, etc.)
- [ ] Crear módulo PowerBar.lua
- [ ] Crear script de inicialización
- [ ] Crear script cliente para cargar la fuerza

