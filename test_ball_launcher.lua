-- 🚀 Lanzador de Balón - LocalScript básico
-- Verifica estado directamente con PlayerStateSystem

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Sistema de estados
local PlayerStateSystem = require(ReplicatedStorage:WaitForChild("PlayerStateSystem"))

-- RemoteEvent
local launchBallEvent = ReplicatedStorage:WaitForChild("LaunchBall")

-- Variables
local player = Players.LocalPlayer
local SPEED = 100 -- Velocidad del disparo
local MAX_DISTANCE = 64 -- Distancia máxima

-- Función de lanzamiento
local function launchBall()
	-- Verificación de estado
	if not PlayerStateSystem.HasBall(player) then
		print("❌ No tienes el balón")
		return
	end

	local camera = workspace.CurrentCamera
	if not camera then
		warn("⚠️ Cámara no disponible")
		return
	end

	local direction = camera.CFrame.LookVector

	launchBallEvent:FireServer(direction, SPEED, MAX_DISTANCE)
	print("🚀 Solicitud de lanzamiento enviada")
end

-- Conectar click
local mouse = player:GetMouse()
mouse.Button1Down:Connect(launchBall)
