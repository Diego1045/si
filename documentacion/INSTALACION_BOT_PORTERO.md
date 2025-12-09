# 🚀 Instalación del Bot de Portero

## ✅ ¿Qué tienes ahora?

1. ✅ **Modelo del portero R6** creado
2. ✅ **Script del bot** (`GoalkeeperBot.server.lua`) creado

---

## 📍 Paso 1: Colocar el Script en Roblox Studio

### Ubicación del Script

El script `GoalkeeperBot.server.lua` debe estar en:

**`ServerScriptService`**

### Cómo colocarlo:

1. Abre tu juego en **Roblox Studio**
2. En el **Explorer**, busca **ServerScriptService**
3. Si no existe, créalo: **Insert** → **Service** → **ServerScriptService**
4. **Arrastra** el archivo `src/server/GoalkeeperBot.server.lua` a **ServerScriptService**
   - O haz clic derecho en **ServerScriptService** → **Insert Object** → **Script**
   - Renómbralo a `GoalkeeperBot`
   - Copia y pega el código del archivo

### Verificar ubicación:

```
📁 Workspace
  📦 Ball

📁 ServerScriptService
  📜 GoalkeeperBot.server.lua  ← Debe estar aquí
  📜 GoalDetector.server.lua
  📜 PositionManager.server.lua
```

---

## 🎬 Paso 2: Configurar IDs de Animaciones

### Obtener IDs de Animaciones

Necesitas **2 animaciones**:

1. **Animación de Tirarse (Dive)**: El portero se tira para atajar
2. **Animación de Disparar (Kick)**: El portero patea el balón

### Opciones para obtener animaciones:

**Opción A: Usar animaciones de la tienda de Roblox**
1. Ve a [Creations de Roblox](https://www.roblox.com/develop)
2. Busca animaciones de portero, fútbol, etc.
3. Copia el **Asset ID** (número) de la animación

**Opción B: Crear tus propias animaciones**
1. Usa **Animation Editor** en Roblox Studio
2. Crea la animación
3. Publica la animación
4. Copia el **Asset ID**

### Configurar los IDs en el Script

Abre `GoalkeeperBot.server.lua` y busca estas líneas (alrededor de línea 25-26):

```lua
-- IDs de animaciones (REEMPLAZAR con los IDs reales de tus animaciones)
local DIVE_ANIMATION_ID = "rbxassetid://123456789" -- Animación de tirarse
local KICK_ANIMATION_ID = "rbxassetid://987654321" -- Animación de disparar/patear
```

**Reemplaza los números** con los IDs reales de tus animaciones:

```lua
-- Ejemplo con IDs reales
local DIVE_ANIMATION_ID = "rbxassetid://123456789" -- Tu ID de animación de tirarse
local KICK_ANIMATION_ID = "rbxassetid://987654321" -- Tu ID de animación de disparar
```

**Formato correcto:**
- ✅ `"rbxassetid://123456789"` (con rbxassetid://)
- ❌ `123456789` (sin el prefijo)

---

## 🎯 Paso 3: Verificar Nombres de Objetos

El script busca estos objetos por nombre en el workspace:

### Objetos necesarios:

1. **Balón**: Debe llamarse `"Ball"`
   - Ubicación: `workspace:WaitForChild("Ball")`

2. **Posición del Portero**: Debe llamarse `"GK_White.R"`
   - Ubicación: Puede estar en cualquier parte del workspace
   - Es donde el portero se posicionará al inicio

### Si tus objetos tienen otros nombres:

Edita estas líneas en `GoalkeeperBot.server.lua` (alrededor de línea 12-13):

```lua
-- Si tu balón se llama diferente
local BALL_NAME = "Ball" -- Cambia esto si tu balón tiene otro nombre

-- Si tu posición de portero se llama diferente
local GOALKEEPER_POSITION = "GK_White.R" -- Cambia esto si tiene otro nombre
```

---

## ⚙️ Paso 4: Ajustar Configuración (Opcional)

### Distancias (en studs)

Puedes ajustar estas distancias según tu juego (líneas 15-18):

```lua
local DIVE_THRESHOLD = 12      -- Distancia para activar ataque/atajada
local INTERCEPT_DISTANCE = 25  -- Distancia para moverse hacia el balón
local GRAB_BALL_DISTANCE = 8   -- Distancia para tomar el balón
```

### Velocidades

Ajusta las velocidades del portero (líneas 21-22):

```lua
local NORMAL_SPEED = 18  -- Velocidad normal de caminata
local CHASE_SPEED = 24   -- Velocidad al perseguir el balón
```

---

## 🧪 Paso 5: Probar el Bot

### Verificar que funciona:

1. **Ejecuta el juego** en Roblox Studio (presiona F5)

2. **Verifica en el Output** que aparezcan estos mensajes:
   ```
   [GoalkeeperBot] ✅ Bot R6 creado y posicionado
   [GoalkeeperBot] ✅ Animaciones cargadas
   [GoalkeeperBot] ✅ Bot de portero inicializado completamente
   ```

3. **Verifica en el workspace**:
   - Debe aparecer un modelo llamado `"GoalkeeperBot"`
   - Debe estar posicionado en `GK_White.R`
   - Debe tener todas las partes R6 (Head, Torso, Arms, Legs)

4. **Prueba el comportamiento**:
   - Mueve el balón cerca del portero
   - El portero debería moverse hacia el balón
   - Si el balón se acerca mucho, debería intentar atajar (reproducir animación de tirarse)

---

## ⚠️ Problemas Comunes

### El bot no aparece

**Causa**: No se encontró StarterCharacter o no es R6

**Solución**:
1. Ve a **StarterPlayer** → **StarterCharacter**
2. Verifica que **RigType** esté en **"R6"**
3. Verifica que el StarterCharacter tenga todas las partes R6

### Error: "No se encontró Ball"

**Causa**: El balón no existe o tiene otro nombre

**Solución**:
1. Verifica que el balón se llame exactamente `"Ball"`
2. O cambia `BALL_NAME` en el script al nombre correcto

### Error: "No se encontró GK_White.R"

**Causa**: No existe la posición del portero

**Solución**:
1. Crea una parte en workspace llamada `"GK_White.R"`
2. O cambia `GOALKEEPER_POSITION` en el script
3. El bot usará la posición por defecto (0, 5, 0)

### Las animaciones no funcionan

**Causa**: IDs de animación incorrectos o animaciones no válidas

**Solución**:
1. Verifica que los IDs estén correctos
2. Verifica que las animaciones sean públicas o tengas acceso
3. Verifica que el formato sea `"rbxassetid://123456789"`

### El bot no se mueve

**Causa**: Pathfinding no funciona o hay obstáculos

**Solución**:
1. Verifica que no haya paredes bloqueando el camino
2. El bot usará movimiento directo si pathfinding falla
3. Ajusta `AgentRadius` y `AgentHeight` si es necesario

---

## 🔗 Paso 6: Integración con Sistema de Balón (Opcional)

Para que el bot pueda **tomar y patear el balón**, necesitas modificar `BallMotor.server.lua`.

**Por ahora, el bot:**
- ✅ Detecta el balón
- ✅ Se mueve hacia el balón
- ✅ Se tira cuando el balón se acerca
- ⚠️ **No puede tomar el balón todavía** (requiere modificar BallMotor.server.lua)

**Si quieres que el bot tome el balón:**
1. Abre `src/balon/BallMotor.server.lua`
2. Modifica la función `welBallFunction` para aceptar modelos además de jugadores
3. Ver documentación: `BOT_PORTERO_MODELO.md` sección "Modificar BallMotor.server.lua"

---

## 📋 Checklist Final

Antes de considerar el bot completamente configurado:

- [ ] Script colocado en **ServerScriptService**
- [ ] IDs de animaciones configurados correctamente
- [ ] Nombres de objetos verificados (Ball, GK_White.R)
- [ ] Bot aparece en el juego al ejecutar
- [ ] Bot se mueve hacia el balón
- [ ] Bot reproduce animación de tirarse cuando el balón se acerca
- [ ] (Opcional) Bot puede tomar el balón

---

## 🎮 Próximos Pasos

1. **Probar el bot** con diferentes situaciones
2. **Ajustar distancias y velocidades** según tu juego
3. **Mejorar el sistema** de toma de balón (modificar BallMotor.server.lua)
4. **Agregar más comportamiento** si es necesario

---

## 📚 Documentación Relacionada

- **`BOT_PORTERO_MODELO.md`** - Guía completa del sistema
- **`MODELO_R6_BOT.md`** - Información sobre modelos R6
- **`CREAR_MODELO_NPC.md`** - Cómo crear NPCs

---

¡Tu bot de portero debería estar funcionando ahora! 🥅⚽

