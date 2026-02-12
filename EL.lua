-- [[ 1. AUTO-CLEANUP ]] --
-- Prevents overlapping if the script is run multiple times
if _G.ESPLibraryInstance then
    _G.ESPLibraryInstance:Unload()
end

local ESPLibrary = {
    Settings = {
        Enabled = true,
        FPSMode = false,        
        MaxDistance = 2500,
        
        -- NAME SETTINGS
        ShowName = true,
        NameSize = 22,          
        MinNameSize = 12,       
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

-- Internal: Drawing Creator
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
    obj.Name.Outline = ESPLibrary.Settings.NameOutline
    obj.Name.Font = ESPLibrary.Settings.NameBold and 3 or 2
    Add(obj.Name, 20)

    for i = 1, 60 do table.insert(obj.SkeletonSegments, Add(Drawing.new("Line"), 2)) end
    for i = 1, 10 do table.insert(obj.TracerSegments, Add(Drawing.new("Line"), 1)) end
    for i = 1, 30 do table.insert(obj.HealthSegments, Add(Drawing.new("Line"), 2)) end
    for i = 1, ESPLibrary.Settings.FillDensity do table.insert(obj.FillLines, Add(Drawing.new("Line"), 1)) end

    local parts = {"L", "R", "TL", "TR", "BL", "BR"}
    for _, p in ipairs(parts) do
        for i = 1, ESPLibrary.Settings.Quality do table.insert(obj[p], Add(Drawing.new("Line"), 3)) end
    end
    return obj
end

-- Internal: Visibility Switch
local function SetVisible(obj, state)
    for i = 1, #obj.AllDrawings do obj.AllDrawings[i].Visible = state end
    if obj.Highlight then obj.Highlight.Enabled = state end
end

-- Internal: Player Cleanup
local function CleanupPlayer(p)
    if ESPTable[p] then
        if ESPTable[p].Highlight then ESPTable[p].Highlight:Destroy() end
        for _, drawing in ipairs(ESPTable[p].AllDrawings) do drawing:Remove() end
        ESPTable[p] = nil
    end
end

-- Internal: Core Update Logic
local function UpdateESP(obj, pos, size, topColor, healthPercent, char, playerName)
    local s = ESPLibrary.Settings
    local botColor = s.BottomColor
    local q = s.FPSMode and 3 or s.Quality
    local r = math.min(s.CornerRadius, size.X * 0.48, size.Y * 0.48)
    
    local wave = s.PulseEnabled and ((math.sin(tick() * s.PulseSpeed) + 1) / 2) or 1
    local smoothPulse = s.MinTransparency + (s.MaxTransparency - s.MinTransparency) * wave
    local borderPulse = math.clamp(smoothPulse + 0.35, 0.5, 1)

    -- Name Scaling
    if s.ShowName then
        obj.Name.Text = playerName:upper()
        obj.Name.Color = topColor
        obj.Name.Size = math.clamp(size.Y * 0.12, s.MinNameSize or 12, s.NameSize)
        obj.Name.Position = Vector2.new(pos.X + size.X/2, pos.Y - (obj.Name.Size + s.NameHeightOffset))
        obj.Name.Visible = true
    end

    -- Skeleton Support (R6 & R15)
    if s.ShowSkeleton then
        local joints = {}
        if char:FindFirstChild("UpperTorso") then -- R15
            joints = {
                {char.Head, char.UpperTorso}, {char.UpperTorso, char.LowerTorso},
                {char.UpperTorso, char.LeftUpperArm}, {char.LeftUpperArm, char.LeftLowerArm},
                {char.UpperTorso, char.RightUpperArm}, {char.RightUpperArm, char.RightLowerArm},
                {char.LowerTorso, char.LeftUpperLeg}, {char.LeftUpperLeg, char.LeftLowerLeg},
                {char.LowerTorso, char.RightUpperLeg}, {char.RightUpperLeg, char.RightLowerLeg}
            }
        else -- R6
            joints = {
                {char.Head, char.Torso}, {char.Torso, char:FindFirstChild("Left Arm")}, 
                {char.Torso, char:FindFirstChild("Right Arm")}, {char.Torso, char:FindFirstChild("Left Leg")}, 
                {char.Torso, char:FindFirstChild("Right Leg")}
            }
        end

        local sIdx = 1
        for _, pair in ipairs(joints) do
            if pair[1] and pair[2] then
                local p1, v1 = Camera:WorldToViewportPoint(pair[1].Position)
                local p2, v2 = Camera:WorldToViewportPoint(pair[2].Position)
                if v1 and v2 then
                    local line = obj.SkeletonSegments[sIdx]
                    if line then
                        line.From, line.To = Vector2.new(p1.X, p1.Y), Vector2.new(p2.X, p2.Y)
                        line.Color, line.Thickness, line.Visible = topColor, s.SkeletonThickness, true
                        sIdx = sIdx + 1
                    end
                end
            end
        end
    end

    -- Chams
    if s.ChamsEnabled and char then
        obj.Highlight.Parent = char
        obj.Highlight.FillColor = topColor
        obj.Highlight.FillTransparency = math.clamp(1 - (s.ChamsFillTransparency * wave), 0.1, 0.9)
        obj.Highlight.Enabled = true
    end

    -- Health Bar Logic
    if s.ShowHealth then
        local barH, barOffset = size.Y * s.HealthBarHeightScale, pos - Vector2.new(s.HealthBarOffset, 0)
        obj.HealthBack.From, obj.HealthBack.To = barOffset, barOffset + Vector2.new(0, barH)
        obj.HealthBack.Thickness, obj.HealthBack.Visible = s.HealthBarWidth + 1.5, true
        for i, seg in ipairs(obj.HealthSegments) do
            local tS = (i - 1) / #obj.HealthSegments
            if tS < healthPercent then
                seg.From = barOffset + Vector2.new(0, barH - (barH * tS))
                seg.To = barOffset + Vector2.new(0, barH - (barH * math.min(i / #obj.HealthSegments, healthPercent)))
                seg.Color, seg.Thickness, seg.Visible = s.HealthLow:Lerp(s.HealthHigh, tS), s.HealthBarWidth, true
            else seg.Visible = false end
        end
    end

    -- Box Fill Gradient
    if s.FillEnabled and not s.FPSMode then
        local fH = size.Y * s.FillHeightScale
        for i, line in ipairs(obj.FillLines) do
            local t = (i-1)/(#obj.FillLines-1)
            line.From, line.To = pos + Vector2.new(s.FillInset, size.Y * t), pos + Vector2.new(size.X - s.FillInset, size.Y * t)
            line.Color, line.Transparency, line.Visible = topColor:Lerp(botColor, t), smoothPulse, (fH / #obj.FillLines) + 0.8, true
        end
    end

    -- Rounded Box Borders
    for i = 1, q do
        local t, hP = (i-1)/q, (math.pi*0.5)/q
        local a1, a2 = (i-1)*hP, i*hP
        obj.L[i].From, obj.L[i].To = pos + Vector2.new(0, r + (size.Y - r*2)*t), pos + Vector2.new(0, r + (size.Y - r*2)*(i/q))
        obj.R[i].From, obj.R[i].To = pos + Vector2.new(size.X, r + (size.Y - r*2)*t), pos + Vector2.new(size.X, r + (size.Y - r*2)*(i/q))
        
        obj.TL[i].From = (pos + Vector2.new(r, r)) + Vector2.new(math.cos(a1 + math.pi), math.sin(a1 + math.pi)) * r
        obj.TL[i].To = (pos + Vector2.new(r, r)) + Vector2.new(math.cos(a2 + math.pi), math.sin(a2 + math.pi)) * r
        obj.TR[i].From = (pos + Vector2.new(size.X - r, r)) + Vector2.new(math.cos(a1 - math.pi/2), math.sin(a1 - math.pi/2)) * r
        obj.TR[i].To = (pos + Vector2.new(size.X - r, r)) + Vector2.new(math.cos(a2 - math.pi/2), math.sin(a2 - math.pi/2)) * r
        obj.BL[i].From = (pos + Vector2.new(r, size.Y - r)) + Vector2.new(math.cos(a1 + math.pi/2), math.sin(a1 + math.pi/2)) * r
        obj.BL[i].To = (pos + Vector2.new(r, size.Y - r)) + Vector2.new(math.cos(a2 + math.pi/2), math.sin(a2 + math.pi/2)) * r
        obj.BR[i].From = (pos + Vector2.new(size.X - r, size.Y - r)) + Vector2.new(math.cos(a1), math.sin(a1)) * r
        obj.BR[i].To = (pos + Vector2.new(size.X - r, size.Y - r)) + Vector2.new(math.cos(a2), math.sin(a2)) * r

        local pG = {obj.L[i], obj.R[i], obj.TL[i], obj.TR[i], obj.BL[i], obj.BR[i]}
        for _, p in ipairs(pG) do 
            p.Transparency, p.Visible, p.Color, p.Thickness = borderPulse, true, topColor, s.BoxThickness 
        end
    end
    obj.T.From, obj.T.To = pos + Vector2.new(r, 0), pos + Vector2.new(size.X - r, 0)
    obj.B.From, obj.B.To = pos + Vector2.new(r, size.Y), pos + Vector2.new(size.X - r, size.Y)
    obj.T.Color, obj.B.Color, obj.T.Visible, obj.B.Visible = topColor, botColor, true, true
end

-- Public Methods
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
            local obj, char = ESPTable[player], player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local hrp, hum = char.HumanoidRootPart, char.Humanoid
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                    if dist < self.Settings.MaxDistance then
                        local w, h = 2300/dist, 3800/dist
                        UpdateESP(obj, Vector2.new(pos.X - w/2, pos.Y - h/2), Vector2.new(w, h), player.TeamColor.Color, hum.Health/hum.MaxHealth, char, player.Name)
                    else SetVisible(obj, false) end
                else SetVisible(obj, false) end
            else SetVisible(obj, false) end
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
