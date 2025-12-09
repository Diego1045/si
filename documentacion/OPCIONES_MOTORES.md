# Opciones de "Motores" Físicos en Roblox

Existen varias formas de mover un objeto con física. Aquí te presento las alternativas más configurables:

## 1. LinearVelocity (La que usamos ahora)
-   **¿Qué hace?**: Define la velocidad exacta del objeto.
-   **Configuración**:
    -   `VectorVelocity`: La dirección y velocidad (ej. 30 studs/s hacia el norte).
    -   `MaxForce`: Qué tan fuerte empuja para mantener esa velocidad.
-   **Pros**: Control total de la velocidad constante.
-   **Contras**: No tiene "aceleración" natural, es velocidad instantánea.

## 2. AlignPosition (La que usamos antes)
-   **¿Qué hace?**: Intenta llevar el objeto a una posición específica.
-   **Configuración**:
    -   `Responsiveness`: Qué tan rápido reacciona (suavidad).
    -   `MaxForce`: Fuerza máxima.
    -   `MaxVelocity`: Límite de velocidad.
-   **Pros**: Muy bueno para seguir caminos (trayectorias).
-   **Contras**: A veces pelea con la física si no se configura bien.

## 3. VectorForce (Fuerza Pura) - **La más configurable físicamente**
-   **¿Qué hace?**: Aplica una fuerza constante (como un cohete o el viento). No define velocidad ni posición, solo **empuje**.
-   **Configuración**:
    -   `Force`: Vector de fuerza (Newtons).
    -   `RelativeTo`: Si la fuerza es relativa al objeto o al mundo.
-   **Pros**: Es la física más realista. Permite aceleración, curvas naturales por gravedad, resistencia del aire.
-   **Contras**: Es difícil hacer que siga un camino exacto (Bezier) porque tienes que calcular la fuerza exacta en cada momento para contrarrestar la gravedad y girar.

## 4. RocketPropulsion (Legacy / Clásico)
-   **¿Qué hace?**: Hace que una parte persiga a otra (Target).
-   **Configuración**:
    -   `MaxSpeed`: Velocidad máxima.
    -   `ThrustP`: Potencia del empuje.
    -   `TurnP`: Potencia de giro (qué tan rápido puede dar la vuelta).
    -   `TargetRadius`: A qué distancia se detiene.
    -   `CartoonFactor`: Para hacerlo ver más caricaturesco.
-   **Pros**: Muy fácil para misiles teledirigidos. Tiene configuraciones divertidas de giro.
-   **Contras**: Es antiguo (Legacy), Roblox recomienda usar los nuevos Constraints, pero sigue funcionando.

## 5. Torque / AngularVelocity (Para rotación)
-   Si quieres que el balón gire (efecto/spin) mientras avanza, puedes combinar cualquiera de los anteriores con `AngularVelocity`.

---

### ¿Cuál buscas?
Si quieres que el balón:
-   **Acelere y frene** suavemente: `AlignPosition` con baja `Responsiveness` o `VectorForce`.
-   **Persiga** al jugador como un misil: `RocketPropulsion`.
-   **Tenga efecto de curva realista** (sin camino predefinido): `VectorForce` (pero requiere matemáticas complejas de balística).
