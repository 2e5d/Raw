-- [[ 1. AUTO-CLEANUP ]] --
-- Deletes any existing instance to prevent lag or ghost drawings
if _G.ESPLibraryInstance then
    _G.ESPLibraryInstance:Unload()
end

local ESPLibrary = {
    Settings = {
        Enabled = true,
        FPSMode = false,        
        MaxDistance = 2500,
        
        -- NAME SETTINGS (DYNAMIC SCALING)
        ShowName = true,
        NameSize = 22,          
        MinNameSize = 12,       -- Essential to prevent clamp error
        NameBold = true,        
        NameOutline = true,
        NameHeightOffset = 15,  
        
        -- CHAMS SETTINGS
        ChamsEnabled = true,    
        ChamsOutline = true,    
        ChamsFillTransparency = 0.5,
        
        -- SKELETON SETTINGS
        ShowSkeleton = true,    
        SkeletonThickness = 1.2,
        
        -- HEALTH SETTINGS
        ShowHealth = true,      
        HealthBarWidth = 2.5,   
        HealthBarOffset = 5,    
        HealthBarHeightScale = 1, 
        
        -- BOX STYLE
        BoxThickness = 1.8,
        CornerRadius = 12,      
        Quality = 8,            
        Rounded = true,         
        
        -- FILL STYLE
        FillEnabled = true,
        FillHeightScale = 0.95, 
        FillInset = 1,        
        FillDensity = 35,       
        
        -- TRACER SETTINGS
        ShowTracer = true,
        TracerOrigin = "Bottom", 
        
        -- EFFECTS
        PulseEnabled = true,
        PulseSpeed = 2.5,       
        MinTransparency = 0.05,  
        MaxTransparency = 0.45,  
        
        -- COLORS
        BottomColor = Color3.fromRGB(0, 0, 0), 
        HealthHigh = Color3.fromRGB(0, 255, 180), 
        HealthLow = Color3.fromRGB(255, 30, 30),   
    }
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ESPTable = {}
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Connection

-- [[ DRAWING CREATOR ]] --
local function CreateESP(player)
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
    hl.Name = "ESP_Chams"
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    obj.Highlight = hl

    local function Add(draw, z)
        draw.ZIndex = z
        draw.Visible = false
        table.insert(obj.AllDrawings, draw)
        return draw
    end

    Add(obj.T, 3); Add(obj.B, 3); Add(obj.HealthBack, 1)
    obj.Name.Center = true
    obj.Name.Outline = true
    obj.Name.Font = 3
    Add(obj.Name, 20)

    for i = 1, 60 do table.insert(obj.SkeletonSegments, Add(Drawing.new("Line"), 2)) end
    for i = 1, 10 do table.insert(obj.TracerSegments, Add(Drawing.new("Line"), 1)) end
    for i = 1, 30 do table.insert(obj.HealthSegments, Add(Drawing.new("Line"), 2)) end
    for i = 1, 50 do table.insert(obj.FillLines, Add(Drawing.new("Line"), 1)) end

    local parts = {"L", "R", "TL", "TR", "BL", "BR"}
    for _, p in ipairs(parts) do
        for i = 1, 12 do table.insert(obj[p], Add(Drawing.new("Line"), 3)) end
    end
    return obj
end

local function SetVisible(obj, state)
    for i = 1, #obj.AllDrawings do obj.AllDrawings[i].Visible = state end
    if obj.Highlight then obj.Highlight.Enabled = state end
end

local function CleanupPlayer(p)
    if ESPTable[p] then
        if ESPTable[p].Highlight then ESPTable[p].Highlight:Destroy() end
        for _, drawing in ipairs(ESPTable[p].AllDrawings) do drawing:Remove() end
        ESPTable[p] = nil
    end
end

-- [[ CORE UPDATER ]] --
local function UpdateESP(obj, pos, size, topColor, healthPercent, char, playerName)
    local s = ESPLibrary.Settings
    local botColor = s.BottomColor
    local wave = s.PulseEnabled and ((math.sin(tick() * s.PulseSpeed) + 1) / 2) or 1
    local smoothPulse = s.MinTransparency + (s.MaxTransparency - s.MinTransparency) * wave
    local borderPulse = math.clamp(smoothPulse + 0.35, 0.5, 1)

    -- NAMES (SCALING)
    if s.ShowName then
        obj.Name.Text = playerName:upper()
        obj.Name.Color = topColor
        local minSize = s.MinNameSize or 12
        local maxSize = s.NameSize or 22
        local scaledSize = math.clamp(size.Y * 0.15, minSize, maxSize)
        obj.Name.Size = scaledSize
        obj.Name.Position = Vector2.new(pos.X + size.X/2, pos.Y - (scaledSize + s.NameHeightOffset))
        obj.Name.Visible = true
    else obj.Name.Visible = false end

    -- SKELETON (R6/R15)
    if s.ShowSkeleton then
        local joints = {}
        if char:FindFirstChild("UpperTorso") then -- R15
            joints = {
                {char:FindFirstChild("Head"), char:FindFirstChild("UpperTorso")}, {char:FindFirstChild("UpperTorso"), char:FindFirstChild("LowerTorso")},
                {char:FindFirstChild("UpperTorso"), char:FindFirstChild("LeftUpperArm")}, {char:FindFirstChild("LeftUpperArm"), char:FindFirstChild("LeftLowerArm")},
                {char:FindFirstChild("UpperTorso"), char:FindFirstChild("RightUpperArm")}, {char:FindFirstChild("RightUpperArm"), char:FindFirstChild("RightLowerArm")},
                {char:FindFirstChild("LowerTorso"), char:FindFirstChild("LeftUpperLeg")}, {char:FindFirstChild("LeftUpperLeg"), char:FindFirstChild("LeftLowerLeg")},
                {char:FindFirstChild("LowerTorso"), char:FindFirstChild("RightUpperLeg")}, {char:FindFirstChild("RightUpperLeg"), char:FindFirstChild("RightLowerLeg")}
            }
        else -- R6
            joints = {
                {char:FindFirstChild("Head"), char:FindFirstChild("Torso")}, {char:FindFirstChild("Torso"), char:FindFirstChild("Left Arm")}, {char:FindFirstChild("Torso"), char:FindFirstChild("Right Arm")},
                {char:FindFirstChild("Torso"), char:FindFirstChild("Left Leg")}, {char:FindFirstChild("Torso"), char:FindFirstChild("Right Leg")}
            }
        end
        local sIdx = 1
        for _, pair in ipairs(joints) do
            if pair[1] and pair[2] then
                local p1, v1 = Camera:WorldToViewportPoint(pair[1].Position)
                local p2, v2 = Camera:WorldToViewportPoint(pair[2].Position)
                if v1 and v2 then
                    local l = obj.SkeletonSegments[sIdx]
                    if l then
                        l.From, l.To = Vector2.new(p1.X, p1.Y), Vector2.new(p2.X, p2.Y)
                        l.Color, l.Thickness, l.Visible = topColor, s.SkeletonThickness, true
                        sIdx = sIdx + 1
                    end
                end
            end
        end
        for i = sIdx, #obj.SkeletonSegments do obj.SkeletonSegments[i].Visible = false end
    else
        for _, l in ipairs(obj.SkeletonSegments) do l.Visible = false end
    end

    -- CHAMS
    if s.ChamsEnabled and char then
        obj.Highlight.Parent = char
        obj.Highlight.FillColor = topColor
        obj.Highlight.FillTransparency = math.clamp(1 - (s.ChamsFillTransparency * wave), 0.1, 0.9)
        obj.Highlight.Enabled = true
    else obj.Highlight.Enabled = false end

    -- BOXES & FILL
    if s.FillEnabled and not s.FPSMode then
        local fH = size.Y * s.FillHeightScale
        for i, line in ipairs(obj.FillLines) do
            local t = (i-1)/#obj.FillLines
            line.From = pos + Vector2.new(0, size.Y * t)
            line.To = pos + Vector2.new(size.X, size.Y * t)
            line.Color = topColor:Lerp(botColor, t)
            line.Transparency = smoothPulse
            line.Visible = true
        end
    else
        for _, l in ipairs(obj.FillLines) do l.Visible = false end
    end
end

-- [[ LIBRARY METHODS ]] --
function ESPLibrary:Init()
    _G.ESPLibraryInstance = self
    Connection = RunService.RenderStepped:Connect(function()
        if not self.Settings.Enabled then 
            for _, v in pairs(ESPTable) do SetVisible(v, false) end
            return 
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if not ESPTable[player] then ESPTable[player] = CreateESP(player) end
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp, hum = char.HumanoidRootPart, char:FindFirstChild("Humanoid")
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                    if dist < self.Settings.MaxDistance then
                        local w, h = 2300/dist, 3800/dist
                        UpdateESP(ESPTable[player], Vector2.new(pos.X - w/2, pos.Y - h/2), Vector2.new(w, h), player.TeamColor.Color, (hum and hum.Health/hum.MaxHealth or 1), char, player.Name)
                    else SetVisible(ESPTable[player], false) end
                else SetVisible(ESPTable[player], false) end
            else SetVisible(ESPTable[player], false) end
        end
    end)
    Players.PlayerRemoving:Connect(CleanupPlayer)
end

function ESPLibrary:Unload()
    if Connection then Connection:Disconnect() end
    for p, _ in pairs(ESPTable) do CleanupPlayer(p) end
    table.clear(ESPTable)
    _G.ESPLibraryInstance = nil
end

return ESPLibrary
