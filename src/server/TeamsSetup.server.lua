local Teams = game:GetService("Teams")
local Players = game:GetService("Players")

-- Configuración de Equipos
local TEAMS_CONFIG = {
	{Name = "Blue Lock", Color = BrickColor.new("Bright blue"), AutoAssignable = false},
	{Name = "Sub-20", Color = BrickColor.new("Bright red"), AutoAssignable = false},
	{Name = "Vetidores", Color = BrickColor.new("Medium stone grey"), AutoAssignable = true} -- Lobby por defecto
}

local function setupTeams()
	for _, teamData in ipairs(TEAMS_CONFIG) do
		local team = Teams:FindFirstChild(teamData.Name)
		if not team then
			team = Instance.new("Team")
			team.Name = teamData.Name
			team.Parent = Teams
		end
		
		team.TeamColor = teamData.Color
		team.AutoAssignable = teamData.AutoAssignable
		print(string.format("[TeamsSetup] Equipo '%s' configurado (AutoAssignable: %s)", team.Name, tostring(team.AutoAssignable)))
	end
end

-- Función para forzar equipo Vetidores al entrar (por si acaso AutoAssignable falla o para lógica custom)
local function onPlayerAdded(player)
	local vetidores = Teams:FindFirstChild("Vetidores")
	if vetidores then
		player.Team = vetidores
		print("[TeamsSetup] Jugador", player.Name, "asignado a Vetidores")
	end
end

-- Inicialización
setupTeams()

Players.PlayerAdded:Connect(onPlayerAdded)

-- Asignar a los que ya están (si se recarga el script)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
