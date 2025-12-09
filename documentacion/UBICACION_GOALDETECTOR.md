# 📍 Ubicación del Script GoalDetector.server.lua

## ✅ Ubicación Correcta

El script `GoalDetector.server.lua` debe estar en:

**`ServerScriptService`** (Recomendado)

```
📁 ServerScriptService
  📜 GoalDetector.server.lua
```

## 🎯 ¿Por qué ServerScriptService?

1. ✅ **Scripts del servidor**: Todos los scripts que usan `.server.lua` deben estar en el servidor
2. ✅ **Se ejecuta automáticamente**: ServerScriptService ejecuta scripts al iniciar el juego
3. ✅ **Organización**: Mantiene los scripts del servidor organizados
4. ✅ **No se replica**: Los scripts del servidor no se envían a los clientes

## 📋 Estructura Completa Recomendada

```
📁 Workspace
  📦 Ball (Part)
    📜 BallMotor.server.lua  ← Hijo del balón
  
📁 ServerScriptService
  📜 GoalDetector.server.lua  ← Aquí va este script
  📜 LaunchBall.server.lua
  📜 PositionManager.server.lua
  📜 player_state_system.lua (ModuleScript)

📁 ReplicatedStorage
  📡 WeldBall (RemoteEvent)
  📡 GoalScored (RemoteEvent)
  📊 GoalCount (IntValue)
  📡 LaunchBall (RemoteEvent)

📁 StarterPlayer
  📁 StarterPlayerScripts
    📜 BallWeld.client.lua  ← LocalScript
```

## ⚠️ Alternativas (NO Recomendadas)

Aunque técnicamente funcionaría, NO es recomendable ponerlo en:

- ❌ **Workspace** - Los scripts del servidor no deberían estar aquí
- ❌ **ReplicatedStorage** - Se replica a los clientes (innecesario)
- ❌ **StarterGui** - Es para scripts del cliente
- ❌ **Como hijo del balón** - Solo `BallMotor.server.lua` debe estar ahí

## 🔍 ¿Cómo Verificar que Está en el Lugar Correcto?

1. **Abre Roblox Studio**
2. **Ve a la pestaña "View"**
3. **Abre "Explorer"** (si no está visible)
4. **Busca "ServerScriptService"**
5. **Verifica que `GoalDetector.server.lua` esté dentro**

## 📝 Notas Importantes

- El script busca objetos en `workspace` por nombre:
  - `workspace:WaitForChild("Ball")`
  - `workspace:WaitForChild("porteria 1")`
- No importa dónde estén estos objetos en workspace, el script los encontrará
- El script debe ejecutarse en el servidor, por eso va en ServerScriptService

## 🎮 Pasos para Colocarlo Correctamente

1. **Crea un Script** en Roblox Studio
2. **Renómbralo a** `GoalDetector`
3. **Copia el código** de `GoalDetector.server.lua`
4. **Colócalo en ServerScriptService**:
   - Arrastra el script a ServerScriptService en el Explorer
   - O haz clic derecho en ServerScriptService → Insert Object → Script
5. **Verifica que el nombre termine en `.server.lua`** (Roblox lo hace automáticamente)

---

**Resumen**: El script `GoalDetector.server.lua` debe estar en **ServerScriptService** para que funcione correctamente como script del servidor.

