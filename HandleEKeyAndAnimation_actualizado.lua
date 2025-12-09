local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

glocal REMOTE_EVENT_NAME = "PlayerPressedE"
local BARRIDA_EVENT_NAME = "StartBarrida"
local ANIMATION_ID = 130760743624770
local COOLDOWN_TIME = 2 -- segundos
local MOVE_DISTANCE = 20  -- distancia total hacia adelante al presionar E
local MOVE_DURATION = 0.35 -- segundos que dura el movimiento (REDUCIDO)
local MOVE_STEPS = 35 -- cantidad de pasos para el movimiento (REDUCIDO)

local player = Players.LocalPlayer
local lastEPressTime = 0

-- 🎯 Variables para el sistema de estados
local playerHasBall = false

local function onEKeyPressed()
    local currentTime = os.clock()
    if currentTime - lastEPressTime < COOLDOWN_TIME then
        -- Si el cooldown no ha terminado, no hacer nada
        return
    end
    lastEPressTime = currentTime

    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    -- 🚀 INICIAR BARRIDA - Comunicar al servidor
    local barridaEvent = ReplicatedStorage:FindFirstChild(BARRIDA_EVENT_NAME)
    if barridaEvent then
        barridaEvent:FireServer()
    end

    -- Guardar velocidad original y establecer a 0 antes de la acción
    local originalWalkSpeed = humanoid.WalkSpeed
    humanoid.WalkSpeed = 0

    -- Reproducir animación
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. tostring(ANIMATION_ID)
    local track = humanoid:LoadAnimation(animation)
    track:Play()

    -- Mover el personaje hacia adelante de forma suave (no teletransporte)
    local forward = rootPart.CFrame.LookVector
    local stepDistance = MOVE_DISTANCE / MOVE_STEPS
    local stepTime = MOVE_DURATION / MOVE_STEPS

    for i = 1, MOVE_STEPS do
        rootPart.CFrame = rootPart.CFrame + forward * stepDistance
        task.wait(stepTime)
    end

    -- Notificar al servidor que el jugador presionó "E"
    local remoteEvent = ReplicatedStorage:FindFirstChild(REMOTE_EVENT_NAME)
    if remoteEvent then
        remoteEvent:FireServer()
    end

    -- 🏁 TERMINAR BARRIDA - El servidor maneja el estado automáticamente
    print("🏁 [BARRIDA] Falta terminada para", player.Name)

    -- Restaurar velocidad al terminar la animación
    track.Stopped:Connect(function()
        humanoid.WalkSpeed = originalWalkSpeed
    end)

    -- Por si la animación es muy corta, restaurar velocidad después de un tiempo de seguridad
    task.delay(1.5, function()
        humanoid.WalkSpeed = originalWalkSpeed
    end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        -- 🎯 Solo ejecutar si NO tiene balón (sin mensajes)
        if not playerHasBall then
            onEKeyPressed()
        end
        -- Si tiene balón, simplemente no hacer nada (tecla deshabilitada)
    end
end)

-- 🎯 ESCUCHAR CAMBIOS DE ESTADO DESDE EL SERVIDOR
local stateRemoteEvent = ReplicatedStorage:WaitForChild("PlayerStateUpdate")
stateRemoteEvent.OnClientEvent:Connect(function(newState)
    playerHasBall = (newState == "Ball")
    print("🎯 Estado actualizado:", newState)
end)
