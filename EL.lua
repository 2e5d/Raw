local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

if _G.ESP_Cleanup then 
    _G.ESP_Cleanup() 
end

_G.ESPLibrary = {
    Settings = {
        Enabled = true,
        MaxDistance = 5000,
        TeamCheck = true,
        
        -- Granit Name Settings
        ShowName = true,
        NameSize = 14,
        
        -- Granit Skeleton Settings
        ShowSkeleton = true,
        SkeletonThickness = 2,
        
        -- Granit Box Settings
        FillEnabled = true,
        BoxFillTransparency = 0.4,
        CornerRadius = 10,
        
        -- Colors
        BottomColor = Color3.fromRGB(0, 0, 0), -- Gradient fades to this
        HealthHigh = Color3.fromRGB(0, 255, 150),
        HealthLow = Color3.fromRGB(255, 50, 50),
        
        PulseEnabled = true,
        PulseSpeed = 3
    }
}

local ESPTable = {}
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GranitVisuals_Full"
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game:GetService("CoreGui")

local function CreateGranitFrame(parent, radius)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.new(1, 1, 1)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 0)
    corner.Parent = frame
    
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 90
    gradient.Parent = frame
    
    return frame, gradient
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local obj = {
        Player = player,
        -- Box
        Box, BoxGradient = CreateGranitFrame(ScreenGui, _G.ESPLibrary.Settings.CornerRadius),
        -- Name (Using TextLabel with UIGradient)
        NameLabel = Instance.new("TextLabel"),
        NameGradient = Instance.new("UIGradient"),
        -- Skeleton (Each bone is a GUI Frame for Granit effect)
        Bones = {},
        BoneGradients = {}
    }
    
    -- Setup Name
    obj.NameLabel.BackgroundTransparency = 1
    obj.NameLabel.Font = Enum.Font.GothamBold
    obj.NameLabel.TextStrokeTransparency = 0.8
    obj.NameLabel.Parent = ScreenGui
    obj.NameGradient.Rotation = 90
    obj.NameGradient.Parent = obj.NameLabel
    
    -- Setup Skeleton Bones (10 standard bones)
    for i = 1, 10 do
        local b, g = CreateGranitFrame(ScreenGui, 5)
        b.Visible = false
        obj.Bones[i] = b
        obj.BoneGradients[i] = g
    end
    
    ESPTable[player] = obj
end

local function UpdateBone(bone, gradient, p1, p2, color1, color2)
    local dist = (p1 - p2).Magnitude
    local center = (p1 + p2) / 2
    local angle = math.atan2(p2.Y - p1.Y, p2.X - p1.X)
    
    bone.Visible = true
    bone.Size = UDim2.new(0, dist, 0, _G.ESPLibrary.Settings.SkeletonThickness)
    bone.Position = UDim2.new(0, center.X - (dist/2), 0, center.Y)
    bone.Rotation = math.deg(angle)
    
    gradient.Color = ColorSequence.new(color1, color2)
end

local function GetJoints(char)
    local hum = char:FindFirstChild("Humanoid")
    local isR15 = hum and hum.RigType == Enum.HumanoidRigType.R15
    if isR15 then
        return {
            {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
            {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
            {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"},
            {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
            {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}
        }
    else
        return {
            {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
            {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
        }
    end
end

local function UpdateESP(obj, player)
    local s = _G.ESPLibrary.Settings
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hrp or not char:FindFirstChild("Humanoid") then
        obj.Box.Visible = false
        obj.NameLabel.Visible = false
        for _, b in pairs(obj.Bones) do b.Visible = false end
        return
    end

    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    if not onScreen or (s.TeamCheck and player.Team == LocalPlayer.Team) then
        obj.Box.Visible = false
        obj.NameLabel.Visible = false
        for _, b in pairs(obj.Bones) do b.Visible = false end
        return
    end

    local teamCol = player.TeamColor.Color
    local scale = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 1000
    local w, h = 4 * scale, 6 * scale
    local x, y = pos.X - w/2, pos.Y - h/2

    -- 1. GRANIT BOX
    obj.Box.Visible = s.FillEnabled
    obj.Box.Position = UDim2.new(0, x, 0, y)
    obj.Box.Size = UDim2.new(0, w, 0, h)
    obj.Box.BackgroundTransparency = 1 - s.BoxFillTransparency
    obj.BoxGradient.Color = ColorSequence.new(teamCol, s.BottomColor)

    -- 2. GRANIT NAME
    obj.NameLabel.Visible = s.ShowName
    obj.NameLabel.Text = player.Name:upper()
    obj.NameLabel.Position = UDim2.new(0, x, 0, y - s.NameSize - 5)
    obj.NameLabel.Size = UDim2.new(0, w, 0, s.NameSize)
    obj.NameLabel.TextSize = s.NameSize
    obj.NameGradient.Color = ColorSequence.new(teamCol, s.BottomColor)

    -- 3. GRANIT SKELETON
    if s.ShowSkeleton then
        local joints = GetJoints(char)
        for i, pair in ipairs(joints) do
            local p1_part = char:FindFirstChild(pair[1])
            local p2_part = char:FindFirstChild(pair[2])
            if p1_part and p2_part and obj.Bones[i] then
                local v1, vis1 = Camera:WorldToViewportPoint(p1_part.Position)
                local v2, vis2 = Camera:WorldToViewportPoint(p2_part.Position)
                if vis1 and vis2 then
                    UpdateBone(obj.Bones[i], obj.BoneGradients[i], Vector2.new(v1.X, v1.Y), Vector2.new(v2.X, v2.Y), teamCol, s.BottomColor)
                else obj.Bones[i].Visible = false end
            end
        end
    else
        for _, b in pairs(obj.Bones) do b.Visible = false end
    end
end

RunService.RenderStepped:Connect(function()
    if not _G.ESPLibrary.Settings.Enabled then ScreenGui.Enabled = false return end
    ScreenGui.Enabled = true
    for player, obj in pairs(ESPTable) do UpdateESP(obj, player) end
end)

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p)
    if ESPTable[p] then
        ESPTable[p].Box:Destroy()
        ESPTable[p].NameLabel:Destroy()
        for _, b in pairs(ESPTable[p].Bones) do b:Destroy() end
        ESPTable[p] = nil
    end
end)

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end

_G.ESP_Cleanup = function()
    ScreenGui:Destroy()
    table.clear(ESPTable)
end

return _G.ESPLibrary
