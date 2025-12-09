# Ejemplos Prácticos de Motor6D

## 🎯 Ejemplo 1: Conectar Balón al Jugador

Basado en el código real del proyecto (`Ball.server.lua`):

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local WeldBall = ReplicatedStorage:WaitForChild("WeldBall")
local ball = script.Parent

local currentOwner = nil
local weld

local function welBallFunction(player)
    -- Verificar que el jugador tenga personaje
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Limpiar motor anterior si existe
    if weld then
        weld:Destroy()
        weld = nil
    end
    
    -- Crear nuevo motor
    weld = Instance.new("Motor6D")
    weld.Name = "BallMotor"
    weld.Part0 = rootPart
    weld.Part1 = ball
    weld.Parent = ball
    weld.C0 = CFrame.new(0, -2, -2)  -- Detrás y abajo del jugador
    
    print("Balón conectado a:", character.Name)
end

WeldBall.OnServerEvent:Connect(welBallFunction)
```

**Características:**
- ✅ Limpia motores anteriores antes de crear uno nuevo
- ✅ Verifica que las partes existan
- ✅ Usa offset específico para posicionar el balón
- ✅ Nombre descriptivo para debugging

## 🎯 Ejemplo 2: Sistema de Herramientas

```lua
local Players = game:GetService("Players")

local function equipTool(player, tool)
    local character = player.Character
    if not character then return end
    
    local rightHand = character:FindFirstChild("RightHand")
    if not rightHand then return end
    
    -- Crear motor para conectar herramienta
    local motor = Instance.new("Motor6D")
    motor.Name = "ToolMotor"
    motor.Part0 = rightHand
    motor.Part1 = tool.Handle
    motor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
    motor.C1 = CFrame.new(0, 0, 0)
    motor.Parent = rightHand
    
    -- Configurar herramienta
    tool.Parent = character
    tool:Activate()
end

local function unequipTool(player, tool)
    -- Buscar y destruir motor
    local motor = tool.Handle:FindFirstChild("ToolMotor")
    if motor then
        motor:Destroy()
    end
    
    tool.Parent = player.Backpack
end
```

## 🎯 Ejemplo 3: Conectar Múltiples Partes

```lua
local function connectCharacterParts(character)
    local torso = character:FindFirstChild("Torso")
    if not torso then return end
    
    local parts = {
        {name = "LeftArm", offset = CFrame.new(-1.5, 0.5, 0)},
        {name = "RightArm", offset = CFrame.new(1.5, 0.5, 0)},
        {name = "LeftLeg", offset = CFrame.new(-0.5, -1.5, 0)},
        {name = "RightLeg", offset = CFrame.new(0.5, -1.5, 0)},
        {name = "Head", offset = CFrame.new(0, 1.5, 0)}
    }
    
    local motors = {}
    
    for _, partData in ipairs(parts) do
        local part = character:FindFirstChild(partData.name)
        if part then
            local motor = Instance.new("Motor6D")
            motor.Name = partData.name .. "Motor"
            motor.Part0 = torso
            motor.Part1 = part
            motor.C0 = partData.offset
            motor.C1 = CFrame.new(0, 0, 0)
            motor.Parent = torso
            
            motors[partData.name] = motor
        end
    end
    
    return motors
end

-- Uso
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local motors = connectCharacterParts(character)
        print("Motores creados:", #motors)
    end)
end)
```

## 🎯 Ejemplo 4: Sistema de Objetos Flotantes

```lua
local RunService = game:GetService("RunService")

local function createFloatingObject(basePart, object, floatHeight, floatSpeed)
    -- Crear motor
    local motor = Instance.new("Motor6D")
    motor.Name = "FloatingMotor"
    motor.Part0 = basePart
    motor.Part1 = object
    motor.C0 = CFrame.new(0, floatHeight, 0)
    motor.C1 = CFrame.new(0, 0, 0)
    motor.Parent = basePart
    
    -- Animación de flotación
    local time = 0
    local connection
    
    connection = RunService.Heartbeat:Connect(function(deltaTime)
        time = time + deltaTime * floatSpeed
        local offset = math.sin(time) * 0.5  -- Oscilación de 0.5 unidades
        motor.C0 = CFrame.new(0, floatHeight + offset, 0)
    end)
    
    -- Retornar función de limpieza
    return function()
        if connection then
            connection:Disconnect()
        end
        if motor then
            motor:Destroy()
        end
    end
end

-- Uso
local cleanup = createFloatingObject(
    workspace.Base,
    workspace.FloatingCube,
    5,  -- Altura base: 5 unidades
    2   -- Velocidad de flotación
)

-- Para detener la flotación
-- cleanup()
```

## 🎯 Ejemplo 5: Sistema de Rotación Continua

```lua
local RunService = game:GetService("RunService")

local function createRotatingObject(basePart, object, rotationSpeed)
    -- Crear motor
    local motor = Instance.new("Motor6D")
    motor.Name = "RotatingMotor"
    motor.Part0 = basePart
    motor.Part1 = object
    motor.C0 = CFrame.new(0, 0, 0)
    motor.C1 = CFrame.new(0, 0, 0)
    motor.Parent = basePart
    
    -- Rotación continua
    local angle = 0
    local connection
    
    connection = RunService.Heartbeat:Connect(function(deltaTime)
        angle = angle + rotationSpeed * deltaTime
        motor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, angle, 0)
    end)
    
    return function()
        if connection then
            connection:Disconnect()
        end
        if motor then
            motor:Destroy()
        end
    end
end

-- Uso: Rotar objeto a 90 grados por segundo
local cleanup = createRotatingObject(
    workspace.Base,
    workspace.RotatingPart,
    math.rad(90)  -- 90 grados por segundo
)
```

## 🎯 Ejemplo 6: Sistema de Seguimiento Suave

```lua
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local function createSmoothFollow(basePart, follower, targetOffset)
    -- Crear motor
    local motor = Instance.new("Motor6D")
    motor.Name = "SmoothFollowMotor"
    motor.Part0 = basePart
    motor.Part1 = follower
    motor.C0 = targetOffset
    motor.C1 = CFrame.new(0, 0, 0)
    motor.Parent = basePart
    
    -- Tween suave para cambios de offset
    local function updateOffset(newOffset, duration)
        duration = duration or 0.5
        
        local startC0 = motor.C0
        local tween = TweenService:Create(
            motor,
            TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {C0 = newOffset}
        )
        tween:Play()
    end
    
    return motor, updateOffset
end

-- Uso
local motor, updateOffset = createSmoothFollow(
    workspace.Player.HumanoidRootPart,
    workspace.Follower,
    CFrame.new(0, 2, 0)
)

-- Cambiar offset suavemente
updateOffset(CFrame.new(0, 5, 0), 1)  -- Mover a 5 unidades en 1 segundo
```

## 🎯 Ejemplo 7: Sistema de Desconexión Temporal

```lua
local function createTemporaryMotor(part0, part1, duration)
    -- Crear motor
    local motor = Instance.new("Motor6D")
    motor.Name = "TemporaryMotor"
    motor.Part0 = part0
    motor.Part1 = part1
    motor.C0 = CFrame.new(0, 0, 0)
    motor.C1 = CFrame.new(0, 0, 0)
    motor.Parent = part0
    
    -- Desconectar después de la duración
    task.wait(duration)
    
    -- Desactivar motor
    motor.Enabled = false
    
    -- O destruirlo completamente
    motor:Destroy()
end

-- Uso: Conectar temporalmente por 5 segundos
createTemporaryMotor(
    workspace.Part1,
    workspace.Part2,
    5
)
```

## 🎯 Ejemplo 8: Clase Motor Manager

```lua
local MotorManager = {}
MotorManager.__index = MotorManager

function MotorManager.new()
    local self = setmetatable({}, MotorManager)
    self.motors = {}
    return self
end

function MotorManager:CreateMotor(name, part0, part1, c0, c1)
    -- Destruir motor existente con el mismo nombre
    if self.motors[name] then
        self.motors[name]:Destroy()
    end
    
    -- Crear nuevo motor
    local motor = Instance.new("Motor6D")
    motor.Name = name
    motor.Part0 = part0
    motor.Part1 = part1
    motor.C0 = c0 or CFrame.new(0, 0, 0)
    motor.C1 = c1 or CFrame.new(0, 0, 0)
    motor.Parent = part0
    
    self.motors[name] = motor
    return motor
end

function MotorManager:GetMotor(name)
    return self.motors[name]
end

function MotorManager:DestroyMotor(name)
    if self.motors[name] then
        self.motors[name]:Destroy()
        self.motors[name] = nil
    end
end

function MotorManager:DestroyAll()
    for name, motor in pairs(self.motors) do
        motor:Destroy()
    end
    self.motors = {}
end

-- Uso
local manager = MotorManager.new()

manager:CreateMotor(
    "BallMotor",
    player.Character.HumanoidRootPart,
    ball,
    CFrame.new(0, -2, -2)
)

-- Obtener motor
local motor = manager:GetMotor("BallMotor")

-- Destruir motor específico
manager:DestroyMotor("BallMotor")

-- Destruir todos los motores
manager:DestroyAll()
```

## 🎯 Ejemplo 9: Verificación y Validación

```lua
local function createSafeMotor(config)
    -- Validar configuración
    assert(config.part0, "Part0 es requerido")
    assert(config.part1, "Part1 es requerido")
    assert(config.part0:IsA("BasePart"), "Part0 debe ser BasePart")
    assert(config.part1:IsA("BasePart"), "Part1 debe ser BasePart")
    
    -- Verificar que las partes existan y sean válidas
    if not config.part0.Parent then
        warn("Part0 no tiene parent")
        return nil
    end
    
    if not config.part1.Parent then
        warn("Part1 no tiene parent")
        return nil
    end
    
    -- Crear motor
    local motor = Instance.new("Motor6D")
    motor.Name = config.name or "Motor"
    motor.Part0 = config.part0
    motor.Part1 = config.part1
    motor.C0 = config.c0 or CFrame.new(0, 0, 0)
    motor.C1 = config.c1 or CFrame.new(0, 0, 0)
    motor.Enabled = config.enabled ~= false
    motor.Parent = config.parent or config.part0
    
    print("Motor creado exitosamente:", motor.Name)
    return motor
end

-- Uso con validación
local motor = createSafeMotor({
    part0 = workspace.Part1,
    part1 = workspace.Part2,
    name = "SafeMotor",
    c0 = CFrame.new(0, 2, 0)
})
```

## 🎯 Ejemplo 10: Sistema Completo de Balón

```lua
local BallSystem = {}
BallSystem.motors = {}

function BallSystem.AttachBall(player, ball)
    local character = player.Character
    if not character then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    -- Limpiar motor anterior
    BallSystem.DetachBall(player)
    
    -- Crear nuevo motor
    local motor = Instance.new("Motor6D")
    motor.Name = "BallMotor_" .. player.UserId
    motor.Part0 = rootPart
    motor.Part1 = ball
    motor.C0 = CFrame.new(0, -2, -2)
    motor.C1 = CFrame.new(0, 0, 0)
    motor.Parent = ball
    
    -- Configurar propiedades del balón
    ball.Massless = true
    ball.CanTouch = false
    ball.CanCollide = false
    
    -- Guardar referencia
    BallSystem.motors[player.UserId] = motor
    
    return true
end

function BallSystem.DetachBall(player)
    local motor = BallSystem.motors[player.UserId]
    if motor then
        motor:Destroy()
        BallSystem.motors[player.UserId] = nil
    end
end

function BallSystem.HasBall(player)
    return BallSystem.motors[player.UserId] ~= nil
end

function BallSystem.GetBallMotor(player)
    return BallSystem.motors[player.UserId]
end

-- Uso
BallSystem.AttachBall(player, workspace.Ball)
if BallSystem.HasBall(player) then
    print("Jugador tiene balón")
end
BallSystem.DetachBall(player)
```

## 📚 Siguiente Paso

Aprende las mejores prácticas y cómo evitar errores comunes en el siguiente documento.

---

**Siguiente:** [Mejores Prácticas](./05_mejores_practicas.md)

