local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

if _G.ESP_Cleanup then 
    _G.ESP_Cleanup() 
end

_G.ESPLibrary = {
    Settings = {
        Enabled = true,
        MaxDistance = 2000,
        TeamCheck = true,
        
        -- Name Settings
        ShowName = true,
        NameSize = 16,
        
        -- Skeleton Settings
        ShowSkeleton = true,
        SkeletonThickness = 2,
        
        -- Box/Fill Settings
        FillEnabled = true,
        BoxFillTransparency = 0.4,
        CornerRadius = 10,
        
        -- Colors (The Granit Blend)
        BottomColor = Color3.fromRGB(0, 0, 0), -- Fade to black
        HealthHigh = Color3.fromRGB(0, 255, 150),
        
        -- Animation
        PulseEnabled = true,
        PulseSpeed = 3
    }
}

local ESPTable = {}
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- GUI Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GranitMaster"
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game:GetService("CoreGui")

-- Helper to create Granit Elements
local function CreateGranit(parent, isText)
    local obj = isText and Instance.new("TextLabel") or Instance.new("Frame")
    obj.BackgroundTransparency = isText and 1 or 0
    obj.BorderSizePixel = 0
    obj.Parent = parent
    
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 90
    gradient.Parent = obj
    
    return obj, gradient
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local obj = {
        Player = player,
        Bones = {},
        BoneGradients = {}
    }
    
    -- Create Box
    obj.Box, obj.BoxGrad = CreateGranit(ScreenGui)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, _G.ESPLibrary.Settings.CornerRadius)
    corner.Parent = obj.Box
    
    -- Create Name
    obj.NameLabel, obj.NameGrad = CreateGranit(ScreenGui, true)
    obj.NameLabel.Font = Enum.Font.GothamBold
    obj.NameLabel.TextStrokeTransparency = 0.5
    
    -- Create Skeleton (10 major bones)
    for i = 1, 10 do
        local b, g = CreateGranit(ScreenGui)
        obj.Bones[i] = b
        obj.BoneGradients[i] = g
    end
    
    ESPTable[player] = obj
end

local function UpdateSkeleton(obj, char, teamCol, botCol)
    local s = _G.ESPLibrary.Settings
    local isR15 = char:FindFirstChild("UpperTorso") ~= nil
    local joints = {}

    if isR15 then
        joints = {
            {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
            {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
            {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"},
            {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
            {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}
        }
    else
        joints = {
            {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
            {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
        }
    end

    for i, bone in ipairs(obj.Bones) do
        local pair = joints[i]
        if s.ShowSkeleton and pair and char:FindFirstChild(pair[1]) and char:FindFirstChild(pair[2]) then
            local p1, vis1 = Camera:WorldToViewportPoint(char[pair[1]].Position)
            local p2, vis2 = Camera:WorldToViewportPoint(char[pair[2]].Position)
            
            if vis1 and vis2 then
                local startPos = Vector2.new(p1.X, p1.Y)
                local endPos = Vector2.new(p2.X, p2.Y)
                local dist = (startPos - endPos).Magnitude
                
                bone.Visible = true
                bone.Size = UDim2.new(0, s.SkeletonThickness, 0, dist)
                bone.Position = UDim2.new(0, (startPos.X + endPos.X)/2, 0, (startPos.Y + endPos.Y)/2)
                bone.AnchorPoint = Vector2.new(0.5, 0.5)
                bone.Rotation = math.deg(math.atan2(endPos.Y - startPos.Y, endPos.X - startPos.X)) - 90
                
                obj.BoneGradients[i].Color = ColorSequence.new(teamCol, botCol)
            else bone.Visible = false end
        else bone.Visible = false end
    end
end

local function UpdateESP()
    local s = _G.ESPLibrary.Settings
    for player, obj in pairs(ESPTable) do
        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if char and hum and hrp and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
            
            if onScreen and dist < s.MaxDistance and (not s.TeamCheck or player.Team ~= LocalPlayer.Team) then
                local scale = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 1000
                local w, h = 4 * scale, 6 * scale
                local x, y = pos.X - w/2, pos.Y - h/2
                
                local teamCol = player.TeamColor.Color
                local botCol = s.BottomColor
                local wave = s.PulseEnabled and ((math.sin(tick() * s.PulseSpeed) + 1) / 2) or 1
                
                -- Update Name (Granit)
                obj.NameLabel.Visible = s.ShowName
                obj.NameLabel.Text = player.Name:upper()
                obj.NameLabel.Size = UDim2.new(0, w, 0, s.NameSize)
                obj.NameLabel.Position = UDim2.new(0, x, 0, y - s.NameSize - 2)
                obj.NameLabel.TextSize = s.NameSize
                obj.NameGrad.Color = ColorSequence.new(teamCol, botCol)
                
                -- Update Box (Granit)
                obj.Box.Visible = s.FillEnabled
                obj.Box.Size = UDim2.new(0, w, 0, h)
                obj.Box.Position = UDim2.new(0, x, 0, y)
                obj.Box.BackgroundTransparency = 1 - (s.BoxFillTransparency * (0.8 + wave * 0.2))
                obj.BoxGrad.Color = ColorSequence.new(teamCol, botCol)
                
                -- Update Skeleton (Granit)
                UpdateSkeleton(obj, char, teamCol, botCol)
            else
                obj.Box.Visible = false; obj.NameLabel.Visible = false
                for _, b in pairs(obj.Bones) do b.Visible = false end
            end
        else
            obj.Box.Visible = false; obj.NameLabel.Visible = false
            for _, b in pairs(obj.Bones) do b.Visible = false end
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p)
    if ESPTable[p] then
        obj.Box:Destroy(); obj.NameLabel:Destroy()
        for _, b in pairs(obj.Bones) do b:Destroy() end
        ESPTable[p] = nil
    end
end)

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end

_G.ESP_Cleanup = function()
    ScreenGui:Destroy()
    table.clear(ESPTable)
end

return _G.ESPLibrary
