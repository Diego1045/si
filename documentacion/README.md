# 📚 Documentación Motor6D - Roblox

Bienvenido a la documentación completa sobre **Motor6D** en Roblox.

## 📑 Índice de Documentación

### Motor6D
0. **[Guía Rápida](./GUIA_RAPIDA.md)** - Referencia rápida y código de ejemplo
1. **[¿Qué es Motor6D?](./01_que_es_motor6d.md)** - Introducción y conceptos básicos
2. **[Cómo Crear un Motor6D](./02_como_crear_motor6d.md)** - Guía paso a paso para crear motores
3. **[Configuración de Motor6D](./03_configuracion_motor6d.md)** - Propiedades y parámetros importantes
4. **[Ejemplos Prácticos](./04_ejemplos_practicos.md)** - Casos de uso reales con código
5. **[Mejores Prácticas](./05_mejores_practicas.md)** - Consejos y recomendaciones
6. **[Solución de Problemas](./06_solucion_problemas.md)** - Errores comunes y cómo solucionarlos

### Partes y Objetos
- **[Cómo Crear Partes](./COMO_CREAR_PARTES.md)** - Guía completa para crear partes mediante scripts

### Bot de Portero
- **[Instalación Bot Portero](./INSTALACION_BOT_PORTERO.md)** - 🚀 Guía paso a paso para instalar y configurar el bot de portero
- **[Bot Portero - Modelo y Animaciones](./BOT_PORTERO_MODELO.md)** - Guía completa para crear un bot de portero con modelo NPC y animaciones
- **[Crear Modelo NPC](./CREAR_MODELO_NPC.md)** - Cómo crear modelos NPC programáticamente en Roblox
- **[Modelo R6 para Bot](./MODELO_R6_BOT.md)** - Guía específica para usar modelos R6 (clásico) en el bot de portero

### Otros Documentos
- **[Barra de Fuerza](./BARRA_FUERZA.md)** - Documentación sobre la barra de fuerza
- **[Propiedades del Balón](./PROPIEDADES_BALON.md)** - Propiedades necesarias para el balón
- **[Ubicación GoalDetector](./UBICACION_GOALDETECTOR.md)** - Dónde colocar el detector de goles
- **[Distance Fade - Explicación](./DISTANCE_FADE_EXPLICACION.md)** - Cómo funciona el sistema de efectos de distancia

## 🎯 Inicio Rápido

Si necesitas crear un Motor6D rápidamente:

```lua
-- Crear un Motor6D básico
local motor = Instance.new("Motor6D")
motor.Part0 = part1  -- Parte base (padre)
motor.Part1 = part2  -- Parte conectada (hijo)
motor.C0 = CFrame.new(0, 0, 0)  -- Offset inicial
motor.C1 = CFrame.new(0, 0, 0)  -- Offset relativo
motor.Parent = part1  -- Debe ser hijo de Part0
```

## 📖 Orden Recomendado de Lectura

### Para Principiantes:
1. Empieza con **Guía Rápida** para ver código de ejemplo inmediato
2. Lee **¿Qué es Motor6D?** para entender los conceptos básicos
3. Sigue con **Cómo Crear un Motor6D** para aprender la sintaxis
4. Revisa **Configuración de Motor6D** para entender todas las propiedades
5. Estudia los **Ejemplos Prácticos** para ver casos reales
6. Consulta **Mejores Prácticas** antes de implementar en producción
7. Usa **Solución de Problemas** cuando tengas errores

### Para Usuarios Avanzados:
- Consulta directamente la **Guía Rápida** para referencia
- Revisa **Ejemplos Prácticos** para patrones avanzados
- Consulta **Solución de Problemas** cuando tengas errores específicos

## 🔗 Referencias Útiles

- [Documentación oficial de Roblox - Motor6D](https://create.roblox.com/docs/reference/engine/classes/Motor6D)
- [Documentación oficial de Roblox - CFrame](https://create.roblox.com/docs/reference/engine/datatypes/CFrame)
- [Documentación oficial de Roblox - BasePart](https://create.roblox.com/docs/reference/engine/classes/BasePart)

## 💡 Notas Importantes

- Motor6D es un objeto de **solo servidor** en Roblox
- Se usa principalmente para conectar partes y crear sistemas de animación
- Es esencial para sistemas de personajes, herramientas y objetos conectados
- Reemplazó a `Weld` y `ManualWeld` en versiones modernas de Roblox

---

**Última actualización:** 2024

