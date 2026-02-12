--[[
    GEMINI ESP LIBRARY - JOIN/LEAVE FIXED
    Optimized for Fluid Menu integration
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- 1. CLEANUP PREVIOUS SESSIONS
if _G.ESP_Cleanup then 
    _G.ESP_Cleanup() 
end

-- 2. SETTINGS
_G.ESPLibrary = {
    Settings = {
        Enabled = true,
        FPSMode = false,
        MaxDistance = 2500,
        ShowName = true,
        NameSize = 20,
        NameBold = true,
        NameOutline = true,
        NameHeightOffset = 15,
        ChamsEnabled = true,
        ChamsOutline = true,
        ChamsFillTransparency = 0.5,
        ShowSkeleton = true,
        SkeletonThickness = 1.5,
        ShowHealth = true,
        HealthBarWidth = 2.5,
        HealthBarOffset = 5,
        HealthBarHeightScale = 1,
        BoxThickness = 1.8,
        CornerRadius = 12,
        Quality = 8,
        Rounded = true,
        FillEnabled = true,
        FillDensity = 35,
        ShowTracer = true,
        TracerOrigin = "Bottom",
        PulseEnabled = true,
        PulseSpeed = 2.5,
        MinTransparency = 0.1,
        MaxTransparency = 0.5,
        BottomColor = Color3.fromRGB(0, 0, 0),
        HealthHigh = Color3.fromRGB(0, 255, 180),
        HealthLow = Color3.fromRGB(255, 30, 30),
    }
}

local ESPTable = {}
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- 3. DRAWING CONSTRUCTOR
local function CreateESP(player)
    if ESPTable[player] then return end -- Prevent double creation
    
    local obj = {
        AllDrawings = {}, 
        FillLines = {},
        L = {}, R = {}, TL = {}, TR = {}, BL = {}, BR = {},
        T = Drawing.new("Line"),
        B = Drawing.new("Line"),
        Name = Drawing.new("Text"), 
        HealthBack = Drawing.new("Line"),
        HealthSegments = {},
        TracerSegments = {},
        SkeletonSegments = {},
        Highlight = nil 
    }

    local hl = Instance.new("Highlight")
    hl.Name = "Gemini_Chams"
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    obj.Highlight = hl

    local function Add(draw, z)
        draw.ZIndex = z
        draw.Visible = false
        table.insert(obj.AllDrawings, draw)
        return draw
    end

    Add(obj.T, 3); Add(obj.B, 3)
    Add(obj.HealthBack, 1)
    obj.Name.Center = true
    Add(obj.Name, 20)

    for i = 1, 20 do table.insert(obj.SkeletonSegments, Add(Drawing.new("Line"), 2)) end
    for i = 1, 10 do table.insert(obj.TracerSegments, Add(Drawing.new("Line"), 1)) end
    for i = 1, 30 do table.insert(obj.HealthSegments, Add(Drawing.new("Line"), 2)) end
    for i = 1, _G.ESPLibrary.Settings.FillDensity do table.insert(obj.FillLines, Add(Drawing.new("Line"), 1)) end

    local parts = {"L", "R", "TL", "TR", "BL", "BR"}
    for _, p in ipairs(parts) do
        for i = 1, 12 do table.insert(obj[p], Add(Drawing.new("Line"), 3)) end
    end

    ESPTable[player] = obj
end

-- 4. CLEANUP FUNCTION (Crucial for Leave Fix)
local function RemoveESP(player)
    local obj = ESPTable[player]
    if obj then
        if obj.Highlight then obj.Highlight:Destroy() end
        for _, drawing in ipairs(obj.AllDrawings) do
            drawing:Remove()
        end
        ESPTable[player] = nil
    end
end

-- 5. RIG RESOLVER
local function GetSkeletonJoints(char)
    local joints = {}
    local isR15 = char:FindFirstChild("UpperTorso") ~= nil
    if isR15 then
        joints = {
            {char:FindFirstChild("Head"), char:FindFirstChild("UpperTorso")},
            {char:FindFirstChild("UpperTorso"), char:FindFirstChild("LowerTorso")},
            {char:FindFirstChild("UpperTorso"), char:FindFirstChild("LeftUpperArm")},
            {char:FindFirstChild("LeftUpperArm"), char:FindFirstChild("LeftLowerArm")},
            {char:FindFirstChild("UpperTorso"), char:FindFirstChild("RightUpperArm")},
            {char:FindFirstChild("RightUpperArm"), char:FindFirstChild("RightLowerArm")},
            {char:FindFirstChild("LowerTorso"), char:FindFirstChild("LeftUpperLeg")},
            {char:FindFirstChild("LeftUpperLeg"), char:FindFirstChild("LeftLowerLeg")},
            {char:FindFirstChild("LowerTorso"), char:FindFirstChild("RightUpperLeg")},
            {char:FindFirstChild("RightUpperLeg"), char:FindFirstChild("RightLowerLeg")}
        }
    else
        joints = {
            {char:FindFirstChild("Head"), char:FindFirstChild("Torso")},
            {char:FindFirstChild("Torso"), char:FindFirstChild("Left Arm")},
            {char:FindFirstChild("Torso"), char:FindFirstChild("Right Arm")},
            {char:FindFirstChild("Torso"), char:FindFirstChild("Left Leg")},
            {char:FindFirstChild("Torso"), char:FindFirstChild("Right Leg")}
        }
    end
    return joints
end

-- 6. RENDER LOGIC
local function SetVisible(obj, state)
    for _, d in ipairs(obj.AllDrawings) do d.Visible = state end
    if obj.Highlight then obj.Highlight.Enabled = state end
end

local function UpdateESP(obj, pos, size, topColor, healthPercent, char, playerName)
    local s = _G.ESPLibrary.Settings
    local botColor = s.BottomColor
    local q = s.FPSMode and 3 or s.Quality
    local r = math.min(s.CornerRadius, size.X * 0.48, size.Y * 0.48)
    local wave = s.PulseEnabled and ((math.sin(tick() * s.PulseSpeed) + 1) / 2) or 1
    local borderPulse = math.clamp(smoothPulse or 0.2 + 0.35, 0.5, 1)

    -- NAMES
    obj.Name.Visible = s.ShowName
    if s.ShowName then
        obj.Name.Text = playerName:upper()
        obj.Name.Color = topColor
        obj.Name.Position = Vector2.new(pos.X + size.X/2, pos.Y - (s.NameSize + s.NameHeightOffset))
    end

    -- CHAMS
    if obj.Highlight then
        obj.Highlight.Enabled = s.ChamsEnabled
        obj.Highlight.Parent = s.ChamsEnabled and char or nil
        obj.Highlight.FillColor = topColor
    end

    -- SKELETON
    if s.ShowSkeleton then
        local connections = GetSkeletonJoints(char)
        for i, line in ipairs(obj.SkeletonSegments) do
            local pair = connections[i]
            if pair and pair[1] and pair[2] then
                local p1, v1 = Camera:WorldToViewportPoint(pair[1].Position)
                local p2, v2 = Camera:WorldToViewportPoint(pair[2].Position)
                if v1 and v2 then
                    line.From = Vector2.new(p1.X, p1.Y)
                    line.To = Vector2.new(p2.X, p2.Y)
                    line.Color = topColor; line.Visible = true
                else line.Visible = false end
            else line.Visible = false end
        end
    end

    -- BOX RENDER
    for i = 1, q do
        local t = (i-1)/q
        obj.L[i].From, obj.L[i].To = pos + Vector2.new(0, r + (size.Y - r*2)*t), pos + Vector2.new(0, r + (size.Y - r*2)*(i/q))
        obj.R[i].From, obj.R[i].To = pos + Vector2.new(size.X, r + (size.Y - r*2)*t), pos + Vector2.new(size.X, r + (size.Y - r*2)*(i/q))
        local group = {obj.L[i], obj.R[i], obj.T, obj.B}
        for _, p in ipairs(group) do p.Visible = true; p.Color = topColor:Lerp(botColor, t) end
    end
end

-- 7. EVENTS (Join/Leave Fix)
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- Init existing players
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end

local Connection = RunService.RenderStepped:Connect(function()
    local s = _G.ESPLibrary.Settings
    if not s.Enabled then
        for _, obj in pairs(ESPTable) do SetVisible(obj, false) end
        return
    end

    for player, obj in pairs(ESPTable) do
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            local hrp = char.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen and (Camera.CFrame.Position - hrp.Position).Magnitude < s.MaxDistance then
                local scale = 1 / (screenPos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 1000
                local w, h = 3.5 * scale, 5.5 * scale
                UpdateESP(obj, Vector2.new(screenPos.X - w/2, screenPos.Y - h/2), Vector2.new(w, h), player.TeamColor.Color, char.Humanoid.Health/char.Humanoid.MaxHealth, char, player.Name)
            else
                SetVisible(obj, false)
            end
        else
            SetVisible(obj, false)
        end
    end
end)

_G.ESP_Cleanup = function()
    Connection:Disconnect()
    for player, _ in pairs(ESPTable) do RemoveESP(player) end
end
