 
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

 
local allowedUsernames = {["f4klnworld69"] = true,

}

local SOUND_NAME = "ChatMusicSound"

local function getOrCreateGlobalSound()
	local sound = SoundService:FindFirstChild(SOUND_NAME)
	if not sound then
		sound = Instance.new("Sound")
		sound.Name = SOUND_NAME
		sound.Parent = SoundService
		sound.Looped = false
		sound.Volume = 0.6
	end
	return sound
end

local function removeGlobalSound()
    local existing = SoundService:FindFirstChild(SOUND_NAME)
    if existing then
        pcall(function()
            existing:Stop()
        end)
        existing:Destroy()
    end
end

local function isAllowed(player)
	if not player or not player.Name then
		return false
	end
	return allowedUsernames[player.Name] == true
end

local function parseMusicCommand(message)
	if type(message) ~= "string" then
		return nil
	end
	local id = string.match(message, "^/music%s+%(?(%d+)%)?%s*$")
	return id
end

local function playById(assetId)
	local sound = getOrCreateGlobalSound()
	sound:Stop()
	sound.SoundId = "rbxassetid://" .. tostring(assetId)
	pcall(function()
		game:GetService("ContentProvider"):PreloadAsync({ sound })
	end)
	sound.TimePosition = 0
	sound:Play()
end

local function onPlayerChatted(player)
	return function(message)
		if string.match(message, "^/unmusic%s*$") then
			if not isAllowed(player) then
				warn(string.format("[ChatMusic] Usuario no permitido: %s intento /unmusic", player.Name))
				return
			end
			print(string.format("[ChatMusic] %s eliminó la música actual", player.Name))
			removeGlobalSound()
			return
		end

		local id = parseMusicCommand(message)
		if not id then
			return
		end

		if not isAllowed(player) then
			warn(string.format("[ChatMusic] Usuario no permitido: %s intento /music %s", player.Name, tostring(id)))
			return
		end

		print(string.format("[ChatMusic] %s reproduciendo id %s", player.Name, tostring(id)))
		playById(id)
 	end
end

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(onPlayerChatted(player))
end)

for _, player in ipairs(Players:GetPlayers()) do
	player.Chatted:Connect(onPlayerChatted(player))
end

