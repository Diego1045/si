# ¿Qué es Motor6D?

## 📖 Definición

**Motor6D** es un objeto de Roblox que conecta dos partes (`BasePart`) manteniendo una relación de posición y rotación constante entre ellas. Es el método moderno y recomendado para unir partes en Roblox.

## 🎯 Propósito Principal

Motor6D permite:
- ✅ Conectar partes de forma permanente
- ✅ Mantener posiciones relativas entre partes
- ✅ Crear sistemas de animación para personajes
- ✅ Unir herramientas a personajes
- ✅ Crear objetos complejos con múltiples partes conectadas

## 🔄 Historia y Evolución

### Antes (Obsoleto):
- `Weld` - Método antiguo, ya no recomendado
- `ManualWeld` - Método manual, menos eficiente

### Ahora (Recomendado):
- **Motor6D** - Método moderno y optimizado

## 🏗️ Estructura Básica

Un Motor6D necesita:

1. **Part0** - La parte base (padre/ancla)
2. **Part1** - La parte conectada (hijo/seguidor)
3. **C0** - Offset inicial de Part0
4. **C1** - Offset relativo de Part1
5. **Parent** - Debe ser hijo de Part0

## 📊 Diagrama Visual

```
┌─────────┐
│  Part0  │ ← Parte base (ancla)
│ (Padre) │
└────┬────┘
     │ Motor6D conecta
     │
┌────▼────┐
│  Part1  │ ← Parte conectada (seguidor)
│ (Hijo)  │
└─────────┘
```

## 🔑 Características Clave

### 1. Conexión Bidireccional
- Si Part0 se mueve, Part1 se mueve con él
- Si Part1 se mueve físicamente, puede afectar a Part0 (depende de la configuración)

### 2. Mantiene Orientación
- La rotación relativa se mantiene constante
- Los offsets C0 y C1 definen la posición y rotación inicial

### 3. Solo Servidor
- Motor6D solo funciona en scripts del servidor
- No se puede crear desde el cliente directamente

### 4. Automático
- Una vez creado, Roblox maneja la conexión automáticamente
- No necesitas actualizar manualmente la posición cada frame

## 🎮 Casos de Uso Comunes

### 1. Sistema de Personajes
```lua
-- Conectar brazos, piernas, cabeza al torso
motor.Part0 = torso
motor.Part1 = leftArm
```

### 2. Herramientas y Objetos
```lua
-- Conectar un balón a un jugador
motor.Part0 = player.Character.HumanoidRootPart
motor.Part1 = ball
```

### 3. Animaciones
```lua
-- Los motores se usan internamente para animaciones
-- Los AnimationTracks modifican los C0/C1 de los motores
```

### 4. Construcciones Complejas
```lua
-- Conectar múltiples partes para crear objetos complejos
-- Ejemplo: un vehículo con ruedas, puertas, etc.
```

## ⚙️ Diferencias con Otros Métodos

| Método | Uso | Estado |
|--------|-----|--------|
| **Motor6D** | Conexión moderna | ✅ Recomendado |
| Weld | Conexión antigua | ❌ Obsoleto |
| ManualWeld | Conexión manual | ❌ No recomendado |
| Attachment + AlignPosition | Conexión física | ✅ Para física avanzada |

## 🚀 Ventajas de Motor6D

1. **Rendimiento**: Optimizado por Roblox
2. **Simplicidad**: Fácil de crear y configurar
3. **Compatibilidad**: Funciona con animaciones automáticamente
4. **Confiabilidad**: Menos errores que métodos antiguos
5. **Mantenimiento**: Roblox lo mantiene y actualiza

## ⚠️ Limitaciones

1. **Solo servidor**: No funciona en scripts del cliente
2. **Requiere partes**: Ambas partes deben existir antes de crear el motor
3. **No es físico**: No afecta la física directamente (usa Attachment para eso)
4. **Un solo motor por par**: No puedes tener múltiples motores conectando las mismas partes

## 📝 Resumen

Motor6D es la forma moderna y recomendada de conectar partes en Roblox. Es esencial para:
- Sistemas de personajes
- Herramientas y objetos
- Animaciones
- Construcciones complejas

En el siguiente documento aprenderás cómo crear un Motor6D paso a paso.

---

**Siguiente:** [Cómo Crear un Motor6D](./02_como_crear_motor6d.md)

