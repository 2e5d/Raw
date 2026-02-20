local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- 1. CLEANUP PREVIOUS SESSIONS
if _G.ESP_Cleanup then 
    _G.ESP_Cleanup() 
end

-- 2. GLOBAL SETTINGS
_G.ESPLibrary = {
    Settings = {
        Enabled = true,
        FPSMode = false,
        MaxDistance = 2500,
        
        -- NAMES
        ShowName = true,
        NameSize = 20,
        NameBold = true,
        NameOutline = true,
        NameHeightOffset = 15,
        
        -- CHAMS
        ChamsEnabled = true,
        ChamsOutline = true,
        ChamsFillTransparency = 0.5,
        
        -- SKELETON
        ShowSkeleton = true,
        SkeletonThickness = 1.5,
        
        -- HEALTH
        ShowHealth = true,
        HealthBarWidth = 2.5,
        HealthBarOffset = 5,
        HealthBarHeightScale = 1,
        
        -- BOX & STYLE
        BoxThickness = 1.8,
        CornerRadius = 12,
        Quality = 8, -- This controls the number of gradient segments
        Rounded = true,
        FillEnabled = true,
        FillDensity = 35,
        FillInset = 2,
        
        -- TRACERS
        ShowTracer = true,
        TracerOrigin = "Bottom",
        
        -- EFFECTS
        PulseEnabled = true,
        PulseSpeed = 2.5,
        MinTransparency = 0.1,
        MaxTransparency = 0.5,
        
        -- COLORS
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
    if player == LocalPlayer then return end
    if ESPTable[player] then return end

    local obj = {
        Player = player,
        AllDrawings = {}, 
        FillLines = {},
        L = {}, R = {}, TL = {}, TR = {}, BL = {}, BR = {},
        -- Gradient Box Arrays
        BoxTop = {},
        BoxBottom = {},
        BoxLeft = {},
        BoxRight = {},
        
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

    -- Initialize Gradient Box Segments based on Quality
    local q = _G.ESPLibrary.Settings.Quality
    for i = 1, q do
        table.insert(obj.BoxTop, Add(Drawing.new("Line"), 3))
        table.insert(obj.BoxBottom, Add(Drawing.new("Line"), 3))
        table.insert(obj.BoxLeft, Add(Drawing.new("Line"), 3))
        table.insert(obj.BoxRight, Add(Drawing.new("Line"), 3))
    end

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

local function RemoveESP(player)
    local obj = ESPTable[player]
    if obj then
        if obj.Highlight then obj.Highlight:Destroy() end
        for _, d in ipairs(obj.AllDrawings) do
            d.Visible = false
            d:Remove()
        end
        ESPTable[player] = nil
    end
end

local function SetVisible(obj, state)
    for i = 1, #obj.AllDrawings do obj.AllDrawings[i].Visible = state end
    if obj.Highlight then obj.Highlight.Enabled = state end
end

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

-- 5. UPDATE ENGINE (With Gradient Box Logic)
local function UpdateESP(obj, pos, size, topColor, healthPercent, char, playerName)
    local s = _G.ESPLibrary.Settings
    local botColor = s.BottomColor
    local q = s.FPSMode and 3 or s.Quality
    local r = s.Rounded and math.min(s.CornerRadius, size.X * 0.48, size.Y * 0.48) or 0
    
    local wave = s.PulseEnabled and ((math.sin(tick() * s.PulseSpeed) + 1) / 2) or 1
    local smoothPulse = s.MinTransparency + (s.MaxTransparency - s.MinTransparency) * wave
    local borderPulse = math.clamp(smoothPulse + 0.35, 0.5, 1)

    -- NAMES
    obj.Name.Visible = s.ShowName
    if s.ShowName then
        obj.Name.Text = playerName:upper()
        obj.Name.Color = topColor
        obj.Name.Size = math.clamp(size.Y * 0.12, 16, s.NameSize)
        obj.Name.Outline = s.NameOutline
        obj.Name.Position = Vector2.new(pos.X + size.X/2, pos.Y - (obj.Name.Size + s.NameHeightOffset))
    end

    -- CHAMS
    if obj.Highlight then
        obj.Highlight.Enabled = s.ChamsEnabled
        if s.ChamsEnabled then
            obj.Highlight.Parent = char
            obj.Highlight.FillColor = topColor
            obj.Highlight.FillTransparency = math.clamp(1 - (s.ChamsFillTransparency * wave), 0.1, 0.9)
            obj.Highlight.OutlineTransparency = s.ChamsOutline and (1 - borderPulse) or 1
        end
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
                    line.Color = topColor; line.Thickness = s.SkeletonThickness; line.Transparency = borderPulse; line.Visible = true
                else line.Visible = false end
            else line.Visible = false end
        end
    else
        for _, v in pairs(obj.SkeletonSegments) do v.Visible = false end
    end

    -- HEALTH BAR
    obj.HealthBack.Visible = s.ShowHealth
    if s.ShowHealth then
        local barH = size.Y * s.HealthBarHeightScale
        local barOffset = pos - Vector2.new(s.HealthBarOffset, 0)
        obj.HealthBack.From = barOffset; obj.HealthBack.To = barOffset + Vector2.new(0, barH)
        obj.HealthBack.Thickness = s.HealthBarWidth + 1.5; obj.HealthBack.Color = Color3.new(0,0,0); obj.HealthBack.Transparency = 0.5
        for i, seg in ipairs(obj.HealthSegments) do
            local tS = (i - 1) / #obj.HealthSegments
            if tS < healthPercent then
                seg.From = barOffset + Vector2.new(0, barH - (barH * tS))
                seg.To = barOffset + Vector2.new(0, barH - (barH * math.min(i / #obj.HealthSegments, healthPercent)))
                seg.Color = s.HealthLow:Lerp(s.HealthHigh, tS); seg.Visible = true; seg.Thickness = s.HealthBarWidth
            else seg.Visible = false end
        end
    else
        for _, v in pairs(obj.HealthSegments) do v.Visible = false end
    end

    -- TRACERS
    if s.ShowTracer then
        local origin = s.TracerOrigin == "Bottom" and Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y) or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local fullVec = (pos + size/2) - origin
        for i, seg in ipairs(obj.TracerSegments) do
            local tS = (i-1)/#obj.TracerSegments
            seg.From, seg.To = origin + (fullVec * tS), origin + (fullVec * (i/#obj.TracerSegments))
            seg.Color = botColor:Lerp(topColor, tS); seg.Transparency = smoothPulse; seg.Visible = true
        end
    else
        for _, v in pairs(obj.TracerSegments) do v.Visible = false end
    end

    -- FILL LINES
    if s.FillEnabled and not s.FPSMode then
        for i, line in ipairs(obj.FillLines) do
            local t = (i-1)/(#obj.FillLines-1)
            line.From = pos + Vector2.new(s.FillInset, size.Y * t)
            line.To = pos + Vector2.new(size.X - s.FillInset, size.Y * t)
            line.Color = topColor:Lerp(botColor, t); line.Transparency = smoothPulse * 0.4; line.Visible = true
        end
    else
        for _, v in pairs(obj.FillLines) do v.Visible = false end
    end

    --- GRADIENT BOX EDGES ---
    -- These are the straight parts between corners
    for i = 1, q do
        local t = (i - 1) / q
        local nextT = i / q
        local currentLerpColor = topColor:Lerp(botColor, t)
        
        -- Vertical Sides (Gradient from Top to Bottom)
        local leftSide = obj.BoxLeft[i]
        leftSide.From = pos + Vector2.new(0, r + (size.Y - r * 2) * t)
        leftSide.To = pos + Vector2.new(0, r + (size.Y - r * 2) * nextT)
        leftSide.Color = currentLerpColor
        leftSide.Thickness = s.BoxThickness
        leftSide.Transparency = borderPulse
        leftSide.Visible = true

        local rightSide = obj.BoxRight[i]
        rightSide.From = pos + Vector2.new(size.X, r + (size.Y - r * 2) * t)
        rightSide.To = pos + Vector2.new(size.X, r + (size.Y - r * 2) * nextT)
        rightSide.Color = currentLerpColor
        rightSide.Thickness = s.BoxThickness
        rightSide.Transparency = borderPulse
        rightSide.Visible = true

        -- Horizontal Sides (Solid Top and Solid Bottom color)
        local topSide = obj.BoxTop[i]
        topSide.From = pos + Vector2.new(r + (size.X - r * 2) * t, 0)
        topSide.To = pos + Vector2.new(r + (size.X - r * 2) * nextT, 0)
        topSide.Color = topColor
        topSide.Thickness = s.BoxThickness
        topSide.Transparency = borderPulse
        topSide.Visible = true

        local botSide = obj.BoxBottom[i]
        botSide.From = pos + Vector2.new(r + (size.X - r * 2) * t, size.Y)
        botSide.To = pos + Vector2.new(r + (size.X - r * 2) * nextT, size.Y)
        botSide.Color = botColor
        botSide.Thickness = s.BoxThickness
        botSide.Transparency = borderPulse
        botSide.Visible = true
    end

    -- ROUNDED CORNERS (Integrated with Gradient logic)
    if s.Rounded then
        for i = 1, 12 do
            local a1, a2 = (i-1)*(math.pi*0.5)/12, i*(math.pi*0.5)/12
            
            -- Top Left (Solid Top Color)
            obj.TL[i].From = (pos + Vector2.new(r, r)) + Vector2.new(math.cos(a1 + math.pi), math.sin(a1 + math.pi)) * r
            obj.TL[i].To = (pos + Vector2.new(r, r)) + Vector2.new(math.cos(a2 + math.pi), math.sin(a2 + math.pi)) * r
            obj.TL[i].Color = topColor
            
            -- Top Right (Solid Top Color)
            obj.TR[i].From = (pos + Vector2.new(size.X - r, r)) + Vector2.new(math.cos(a1 - math.pi/2), math.sin(a1 - math.pi/2)) * r
            obj.TR[i].To = (pos + Vector2.new(size.X - r, r)) + Vector2.new(math.cos(a2 - math.pi/2), math.sin(a2 - math.pi/2)) * r
            obj.TR[i].Color = topColor
            
            -- Bottom Left (Solid Bottom Color)
            obj.BL[i].From = (pos + Vector2.new(r, size.Y - r)) + Vector2.new(math.cos(a1 + math.pi/2), math.sin(a1 + math.pi/2)) * r
            obj.BL[i].To = (pos + Vector2.new(r, size.Y - r)) + Vector2.new(math.cos(a2 + math.pi/2), math.sin(a2 + math.pi/2)) * r
            obj.BL[i].Color = botColor
            
            -- Bottom Right (Solid Bottom Color)
            obj.BR[i].From = (pos + Vector2.new(size.X - r, size.Y - r)) + Vector2.new(math.cos(a1), math.sin(a1)) * r
            obj.BR[i].To = (pos + Vector2.new(size.X - r, size.Y - r)) + Vector2.new(math.cos(a2), math.sin(a2)) * r
            obj.BR[i].Color = botColor
            
            local corners = {obj.TL[i], obj.TR[i], obj.BL[i], obj.BR[i]}
            for _, c in ipairs(corners) do c.Visible = true; c.Thickness = s.BoxThickness; c.Transparency = borderPulse end
        end
    else
        -- Hide corners if rounding is disabled
        local corners = {"TL", "TR", "BL", "BR"}
        for _, p in ipairs(corners) do for _, d in ipairs(obj[p]) do d.Visible = false end end
    end
end

-- 6. RUNTIME EVENT HANDLERS
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

for _, p in ipairs(Players:GetPlayers()) do
    CreateESP(p)
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
            local hrp, hum = char.HumanoidRootPart, char.Humanoid
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                if dist < s.MaxDistance then
                    local scale = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 1000
                    local w, h = 3.5 * scale, 5.5 * scale
                    UpdateESP(obj, Vector2.new(pos.X - w/2, pos.Y - h/2), Vector2.new(w, h), player.TeamColor.Color, hum.Health/hum.MaxHealth, char, player.Name)
                else SetVisible(obj, false) end
            else SetVisible(obj, false) end
        else SetVisible(obj, false) end
    end
end)

_G.ESP_Cleanup = function()
    Connection:Disconnect()
    for player, _ in pairs(ESPTable) do
        RemoveESP(player)
    end
    table.clear(ESPTable)
end

return _G.ESPLibrary
