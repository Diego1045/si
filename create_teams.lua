local Teams = game:FindFirstChild("Teams")

if not Teams then
    Teams = Instance.new("Folder")
    Teams.Name = "Teams"
    Teams.Parent = game
end

-- Crear equipo Blue Lock si no existe
local blueLock = Teams:FindFirstChild("Blue Lock")
if not blueLock then
    blueLock = Instance.new("Team")
    blueLock.Name = "Blue Lock"
    blueLock.TeamColor = BrickColor.new("Bright blue")
    blueLock.Parent = Teams
end

-- Crear equipo Sub-20 si no existe
local sub20 = Teams:FindFirstChild("Sub-20")
if not sub20 then
    sub20 = Instance.new("Team")
    sub20.Name = "Sub-20"
    sub20.TeamColor = BrickColor.new("Bright red")
    sub20.Parent = Teams
end

-- Crear equipo Vetidores si no existe
local vetidores = Teams:FindFirstChild("Vetidores")
if not vetidores then
    vetidores = Instance.new("Team")
    vetidores.Name = "Vetidores"
    vetidores.TeamColor = BrickColor.new("Medium stone grey")
    vetidores.Parent = Teams
end

-- Asignar a los jugadores al equipo Vetidores cuando se unan
local Players = game:GetService("Players")

-- Función para asignar equipo a un jugador
local function assignTeam(player)
    if vetidores then
        player.Team = vetidores
        print("[Teams] ✅ Jugador", player.Name, "asignado al equipo Vetidores")
    end
end

-- Asignar equipo a jugadores que ya están en el juego
for _, player in pairs(Players:GetPlayers()) do
    assignTeam(player)
end

-- Asignar equipo a nuevos jugadores que se unan
Players.PlayerAdded:Connect(function(player)
    assignTeam(player)
end)

