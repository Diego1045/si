# 📋 Propiedades Requeridas del Balón

Basado en el análisis del código existente, el balón debe tener las siguientes propiedades:

## ✅ Propiedades Esenciales

### 1. **Nombre**
- **Valor requerido**: `"Ball"` (exactamente)
- **Dónde se usa**: 
  - `workspace:WaitForChild("Ball")`
  - `workspace:FindFirstChild("Ball")`
  - `ball.Name == "Ball"`

### 2. **Tipo de Objeto**
- **Valor requerido**: Debe ser una `BasePart` (Part, MeshPart, etc.)
- **Dónde se usa**: 
  - `ball:IsA("BasePart")`
  - El script debe ser hijo de una BasePart

### 3. **Ubicación Inicial**
- **Valor requerido**: Debe estar en `workspace` al inicio
- **Dónde se usa**: 
  - `workspace:WaitForChild("Ball")`
  - Se mueve a `character` cuando se conecta

## 🔧 Propiedades que se Configuran Automáticamente

Estas propiedades se establecen automáticamente por los scripts:

### Cuando se Conecta al Jugador:
```lua
ball.Parent = character
ball:SetNetworkOwner(player)
ball.Massless = true
ball.CanTouch = false
ball.CanCollide = false
ball.CollisionGroup = "Ball"
```

### Cuando se Lanza:
```lua
ball.Anchored = false
ball.CanCollide = true
ball.AssemblyLinearVelocity = direction * speed
ball.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
ball:SetAttribute("Launched", true)
```

### Cuando se Desconecta:
```lua
ball.Parent = workspace
ball.Massless = false
ball.CanTouch = true
ball.CanCollide = true
ball:SetNetworkOwner(nil)
ball:SetAttribute("Launched", false)
```

## 📝 Resumen de Propiedades Requeridas

| Propiedad | Valor Requerido | Tipo |
|-----------|----------------|------|
| **Nombre** | `"Ball"` | string |
| **Tipo** | `BasePart` | Instance |
| **Parent inicial** | `workspace` | Instance |
| **CollisionGroup** | `"Ball"` (se establece automáticamente) | string |

## ⚠️ Propiedades Opcionales pero Usadas

- **Atributo `"Launched"`**: Se establece cuando el balón se lanza
- **Hijo `"BallMotor"`**: Motor6D que se crea cuando se conecta al jugador

## 🎯 Configuración Mínima del Balón en Roblox Studio

Para que el balón funcione correctamente:

1. **Crear una Part** en workspace
2. **Renombrarla a `"Ball"`** (exactamente)
3. **Ajustar tamaño/forma** según necesites
4. **Colocar el script `BallMotor.server.lua`** como hijo del balón

El script configurará automáticamente:
- ✅ CollisionGroup
- ✅ Propiedades físicas cuando se conecta
- ✅ Motor6D cuando se conecta al jugador

## 📌 Nota Importante

El balón **NO necesita** tener propiedades especiales configuradas manualmente. El script las configura automáticamente. Solo necesita:
- ✅ Nombre: `"Ball"`
- ✅ Tipo: `BasePart`
- ✅ Estar en `workspace` al inicio

