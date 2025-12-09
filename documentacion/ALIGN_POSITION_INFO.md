# AlignPosition en Roblox

## ¿Qué es AlignPosition?
**AlignPosition** es una restricción física (Constraint) que aplica fuerza para mover dos accesorios (Attachments) o un accesorio y una posición objetivo para que coincidan en el espacio.

A diferencia de modificar la propiedad `Position` o `CFrame` directamente (que "teletransporta" el objeto), AlignPosition usa el motor de física, lo que permite:
-   Movimiento suave.
-   Interacción con otras fuerzas (gravedad, colisiones).
-   Respetar la velocidad y masa del objeto.

## Configuración Principal

### 1. Modos (`Mode`)
-   **TwoAttachment**: Intenta juntar `Attachment0` y `Attachment1`. Ambos objetos se moverán a menos que uno esté anclado.
-   **OneAttachment**: Mueve `Attachment0` hacia una posición global definida en la propiedad `Position`. Es útil para mover un objeto a un punto específico sin necesitar un segundo objeto físico.

### 2. Fuerza y Velocidad
-   **MaxForce**: La fuerza máxima que el motor puede aplicar.
    -   `math.huge` (Infinito): El objeto se moverá sin importar su masa o resistencia.
    -   Valor bajo: El objeto podría no moverse si es muy pesado o si algo lo bloquea.
-   **MaxVelocity**: La velocidad máxima permitida (en studs/segundo).
    -   Útil para crear movimientos lentos y controlados (como el tiro del bot).

### 3. Comportamiento (`Responsiveness` vs `RigidityEnabled`)
-   **Responsiveness** (0 - 200+): Controla qué tan rápido reacciona el motor para alcanzar el objetivo.
    -   Alto (200): Movimiento muy rápido y preciso ("Snappy").
    -   Bajo (5-20): Movimiento suave y amortiguado ("Floaty").
-   **RigidityEnabled**: Si es `true`, ignora la física de fuerza/amortiguación e intenta unir los puntos instantáneamente (como una soldadura móvil). Es muy estable pero menos "físico".

## Limitaciones y Consideraciones

1.  **Objetos Anclados (`Anchored`)**:
    -   AlignPosition **NO** funciona si el objeto que intentas mover (`Attachment0`) está en una parte con `Anchored = true`. La física no afecta a objetos anclados.
    -   Para usarlo, la parte debe estar desanclada (`Anchored = false`).

2.  **Propiedad de Red (Network Ownership)**:
    -   Si el movimiento se ve con "lag" o tirones, puede ser un problema de quién calcula la física (Servidor vs Cliente).
    -   Para proyectiles controlados por el servidor (como el balón del bot), es mejor establecer `Part:SetNetworkOwner(nil)` para que el servidor tenga el control total.

3.  **Conflictos de Física**:
    -   Si usas `AlignPosition` junto con `AlignOrientation` o colisiones fuertes, el objeto puede volverse inestable o vibrar si las fuerzas son contradictorias (ej. intentar atravesar una pared con fuerza infinita).

4.  **Attachments Requeridos**:
    -   Siempre necesitas al menos un `Attachment` dentro de la parte que quieres mover. No puedes aplicar AlignPosition directamente a una Part sin un Attachment.
## Profundizando: MaxForce vs MaxVelocity

Entender cómo interactúan estas dos propiedades es clave para controlar el movimiento.

### 1. MaxForce (Fuerza Máxima)
Es el "músculo" del motor. Define qué tan fuerte puede empujar para llegar al destino.
-   **Unidad**: Newtons.
-   **Cómo afecta**:
    -   Si el objeto es muy pesado (Masa alta), necesitas más fuerza para moverlo.
    -   Si hay gravedad o fricción, necesitas fuerza para vencerlas.
    -   **Ejemplo**: Si tienes un balón de plomo (masa 100) y `MaxForce` es 10, el balón apenas se moverá. Si `MaxForce` es 10000, se moverá fácilmente.

### 2. MaxVelocity (Velocidad Máxima)
Es el "límite de velocidad" legal. No importa qué tan fuerte sea el motor, no se le permite ir más rápido que esto.
-   **Unidad**: Studs por segundo.
-   **Cómo afecta**:
    -   Actúa como un freno automático. Si el motor empuja fuerte y el objeto empieza a acelerar, `MaxVelocity` lo frena para que no pase el límite.
    -   Es ideal para movimientos constantes (como una plataforma móvil o un tiro lento).

### 3. ¿Cómo usarlos juntos?

| Escenario | Configuración Recomendada | Resultado |
| :--- | :--- | :--- |
| **Teletransporte Físico** | `MaxForce = math.huge`, `MaxVelocity = math.huge` | El objeto llega al destino lo más rápido posible (instantáneo si `Responsiveness` es alto). |
| **Movimiento Lento y Fuerte** | `MaxForce = math.huge`, `MaxVelocity = 5` | El objeto se mueve lento (5 studs/s) pero es IMPARABLE. Empujará cualquier cosa en su camino. |
| **Movimiento Débil** | `MaxForce = 500`, `MaxVelocity = math.huge` | El objeto intenta ir rápido, pero si choca con algo o es pesado, se detendrá o irá lento. |
| **Tiro Controlado (Nuestro Caso)** | `MaxForce = 10000`, `MaxVelocity = 20` | El balón tiene fuerza suficiente para moverse, pero está limitado a ir lento para el efecto visual. |

### Consejo Práctico
-   Si quieres que algo llegue **sí o sí** a un lugar, usa `MaxForce` infinito.
-   Si quieres controlar **cuánto tarda** en llegar, usa `MaxVelocity`.
