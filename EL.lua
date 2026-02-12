-- [[ 1. AUTO-CLEANUP ]] --
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

    -- 1. NAMES
    if s.ShowName then
        obj.Name.Text = playerName:upper()
        obj.Name.Color = topColor
        local scaledSize = math.clamp(size.Y * 0.15, s.MinNameSize or 12, s.NameSize or 22)
        obj.Name.Size = scaledSize
        obj.Name.Position = Vector2.new(pos.X + size.X/2, pos.Y - (scaledSize + s.NameHeightOffset))
        obj.Name.Visible = true
    else obj.Name.Visible = false end

    -- 2. SKELETON
    if s.ShowSkeleton then
        local joints = char:FindFirstChild("UpperTorso") and {
            {char.Head, char.UpperTorso}, {char.UpperTorso, char.LowerTorso},
            {char.UpperTorso, char.LeftUpperArm}, {char.LeftUpperArm, char.LeftLowerArm},
            {char.UpperTorso, char.RightUpperArm}, {char.RightUpperArm, char.RightLowerArm},
            {char.LowerTorso, char.LeftUpperLeg}, {char.LeftUpperLeg, char.LeftLowerLeg},
            {char.LowerTorso, char.RightUpperLeg}, {char.RightUpperLeg, char.RightLowerLeg}
        } or {
            {char.Head, char.Torso}, {char:FindFirstChild("Torso"), char:FindFirstChild("Left Arm")}, 
            {char:FindFirstChild("Torso"), char:FindFirstChild("Right Arm")},
            {char:FindFirstChild("Torso"), char:FindFirstChild("Left Leg")}, 
            {char:FindFirstChild("Torso"), char:FindFirstChild("Right Leg")}
        }
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
    end

    -- 3. BOX BORDERS (ROUNDED)
    local q, r = s.Quality, math.min(s.CornerRadius, size.X/2, size.Y/2)
    for i = 1, q do
        local t, hP = (i-1)/q, (math.pi*0.5)/q
        local a1, a2 = (i-1)*hP, i*hP
        obj.L[i].From, obj.L[i].To = pos + Vector2.new(0, r + (size.Y - r*2)*t), pos + Vector2.new(0, r + (size.Y - r*2)*(i/q))
        obj.R[i].From, obj.R[i].To = pos + Vector2.new(size.X, r + (size.Y - r*2)*t), pos + Vector2.new(size.X, r + (size.Y - r*2)*(i/q))
        
        obj.TL[i].From = (pos + Vector2.new(r, r)) + Vector2.new(math.cos(a1 + math.pi), math.sin(a1 + math.pi)) * r
        obj.TL[i].To = (pos + Vector2.new(r, r)) + Vector2.new(math.cos(a2 + math.pi), math.sin(a2 + math.pi)) * r
        
        obj.TR[i].From = (pos + Vector2.new(size.X-r, r)) + Vector2.new(math.cos(a1 - math.pi/2), math.sin(a1 - math.pi/2)) * r
        obj.TR[i].To = (pos + Vector2.new(size.X-r, r)) + Vector2.new(math.cos(a2 - math.pi/2), math.sin(a2 - math.pi/2)) * r
        
        obj.BL[i].From = (pos + Vector2.new(r, size.Y-r)) + Vector2.new(math.cos(a1 + math.pi/2), math.sin(a1 + math.pi/2)) * r
        obj.BL[i].To = (pos + Vector2.new(r, size.Y-r)) + Vector2.new(math.cos(a2 + math.pi/2), math.sin(a2 + math.pi/2)) * r
        
        obj.BR[i].From = (pos + Vector2.new(size.X-r, size.Y-r)) + Vector2.new(math.cos(a1), math.sin(a1)) * r
        obj.BR[i].To = (pos + Vector2.new(size.X-r, size.Y-r)) + Vector2.new(math.cos(a2), math.sin(a2)) * r

        local lines = {obj.L[i], obj.R[i], obj.TL[i], obj.TR[i], obj.BL[i], obj.BR[i]}
        for _, l in ipairs(lines) do 
            l.Color, l.Visible, l.Thickness = topColor, true, s.BoxThickness 
        end
    end
    obj.T.From, obj.T.To = pos + Vector2.new(r, 0), pos + Vector2.new(size.X-r, 0)
    obj.B.From, obj.B.To = pos + Vector2.new(r, size.Y), pos + Vector2.new(size.X-r, size.Y)
    obj.T.Visible, obj.B.Visible, obj.T.Color, obj.B.Color = true, true, topColor, topColor

    -- 4. FILL
    if s.FillEnabled then
        for i, line in ipairs(obj.FillLines) do
            local t = (i-1)/#obj.FillLines
            line.From, line.To = pos + Vector2.new(0, size.Y * t), pos + Vector2.new(size.X, size.Y * t)
            line.Color, line.Transparency, line.Visible = topColor:Lerp(botColor, t), smoothPulse, true
        end
    else for _, l in ipairs(obj.FillLines) do l.Visible = false end end

    -- 5. HEALTH
    if s.ShowHealth then
        local bH, bO = size.Y * s.HealthBarHeightScale, pos - Vector2.new(s.HealthBarOffset, 0)
        obj.HealthBack.From, obj.HealthBack.To = bO, bO + Vector2.new(0, bH)
        obj.HealthBack.Visible, obj.HealthBack.Thickness = true, s.HealthBarWidth + 1
        for i, seg in ipairs(obj.HealthSegments) do
            local tS = (i-1)/#obj.HealthSegments
            if tS < healthPercent then
                seg.From = bO + Vector2.new(0, bH - (bH * tS))
                seg.To = bO + Vector2.new(0, bH - (bH * math.min(i/#obj.HealthSegments, healthPercent)))
                seg.Color, seg.Visible, seg.Thickness = s.HealthLow:Lerp(s.HealthHigh, tS), true, s.HealthBarWidth
            else seg.Visible = false end
        end
    end

    -- 6. CHAMS
    if s.ChamsEnabled and char then
        obj.Highlight.Parent = char
        obj.Highlight.FillColor = topColor
        obj.Highlight.Enabled = true
    else obj.Highlight.Enabled = false end
end

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
