-- Server script in ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Your admin user ID
local ADMIN_USER_ID = 10209915029

-- Get the remote events
local kickEvent = ReplicatedStorage:WaitForChild("KickAllEvent")
local killEvent = ReplicatedStorage:WaitForChild("KillAllEvent")
local banEvent = ReplicatedStorage:WaitForChild("BanAllEvent")   -- optional

-- Helper: kick all players except the admin
local function kickAllExcept(adminPlayer)
    local reason = "You have been kicked by an admin."
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= adminPlayer then
            player:Kick(reason)
        end
    end
    print(adminPlayer.Name .. " kicked everyone else.")
end

-- Helper: kill all players except the admin
local function killAllExcept(adminPlayer)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= adminPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
        end
    end
    print(adminPlayer.Name .. " killed everyone else.")
end

-- Helper: ban all players except the admin (example using a ban list)
-- This is a simplified example – you'd normally store bans in a datastore
local bannedUsers = {}   -- in-memory ban list (resets when server restarts)
local function banAllExcept(adminPlayer)
    local banReason = "You have been banned by an admin."
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= adminPlayer then
            -- Add to ban list
            bannedUsers[player.UserId] = true
            -- Kick them with ban message
            player:Kick("Banned: " .. banReason)
        end
    end
    print(adminPlayer.Name .. " banned everyone else.")
end

-- Connect remote events, with admin verification
kickEvent.OnServerEvent:Connect(function(playerWhoClicked)
    if playerWhoClicked.UserId == ADMIN_USER_ID then
        kickAllExcept(playerWhoClicked)
    else
        warn("Unauthorised kick attempt by " .. playerWhoClicked.Name)
    end
end)

killEvent.OnServerEvent:Connect(function(playerWhoClicked)
    if playerWhoClicked.UserId == ADMIN_USER_ID then
        killAllExcept(playerWhoClicked)
    else
        warn("Unauthorised kill attempt by " .. playerWhoClicked.Name)
    end
end)

banEvent.OnServerEvent:Connect(function(playerWhoClicked)
    if playerWhoClicked.UserId == ADMIN_USER_ID then
        banAllExcept(playerWhoClicked)
    else
        warn("Unauthorised ban attempt by " .. playerWhoClicked.Name)
    end
end)
