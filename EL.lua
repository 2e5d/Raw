-- Gemini ESP Library Loadstring Version
local ESPLibrary = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

if _G.ESP_Cleanup then _G.ESP_Cleanup() end

ESPLibrary.Settings = {
    Enabled = true,
    FPSMode = false,        
    MaxDistance = 2500,
    ShowName = true,
    NameSize = 22,          
    NameBold = true,        
    NameOutline = true,
    NameHeightOffset = 15,  
    ChamsEnabled = true,    
    ChamsOutline = true,    
    ChamsFillTransparency = 0.5,
    ShowSkeleton = true,    
    SkeletonThickness = 1.2,
    ShowHealth = true,      
    HealthBarWidth = 2.5,   
    HealthBarOffset = 5,    
    HealthBarHeightScale = 1, 
    BoxThickness = 1.8,
    CornerRadius = 12,      
    Quality = 8,            
    Rounded = true,         
    FillEnabled = true,
    FillHeightScale = 0.95, 
    FillInset = 1,        
    FillDensity = 35,       
    ShowTracer = true,
    TracerOrigin = "Bottom", 
    PulseEnabled = true,
    PulseSpeed = 2.5,       
    MinTransparency = 0.05,  
    MaxTransparency = 0.45,  
    BottomColor = Color3.fromRGB(0, 0, 0), 
    HealthHigh = Color3.fromRGB(0, 255, 180), 
    HealthLow = Color3.fromRGB(255, 30, 30),   
}

local ESPTable = {}
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

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
    hl.Name = "2ddwd"
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

local function SetVisible(obj, state)
    for i = 1, #obj.AllDrawings do obj.AllDrawings[i].Visible = state end
    if obj.Highlight then obj.Highlight.Enabled = state end
end

local function UpdateESP(obj, pos, size, topColor, healthPercent, char, playerName)
    local s = ESPLibrary.Settings
    local botColor = s.BottomColor
    local q = s.FPSMode and 3 or s.Quality
    local r = math.min(s.CornerRadius, size.X * 0.48, size.Y * 0.48)
    local wave = s.PulseEnabled and ((math.sin(tick() * s.PulseSpeed) + 1) / 2) or 1
    local smoothPulse = s.MinTransparency + (s.MaxTransparency - s.MinTransparency) * wave
    local borderPulse = math.clamp(smoothPulse + 0.35, 0.5, 1)

    if s.ShowName then
        obj.Name.Text = playerName:upper()
        obj.Name.Color = topColor
        obj.Name.Size = math.clamp(size.Y * 0.12, 18, s.NameSize)
        obj.Name.Position = Vector2.new(pos.X + size.X/2, pos.Y - (obj.Name.Size + s.NameHeightOffset))
        obj.Name.Visible = true
    end

    if s.ChamsEnabled and char then
        obj.Highlight.Parent = char
        obj.Highlight.FillColor = topColor
        obj.Highlight.FillTransparency = math.clamp(1 - (s.ChamsFillTransparency * wave), 0.1, 0.9)
        obj.Highlight.OutlineColor = topColor:Lerp(Color3.new(1,1,1), wave * 0.5)
        obj.Highlight.OutlineTransparency = s.ChamsOutline and (1 - borderPulse) or 1
        obj.Highlight.Enabled = true
    end

    if s.ShowHealth then
        local barH = size.Y * s.HealthBarHeightScale
        local barOffset = pos - Vector2.new(s.HealthBarOffset, 0)
        obj.HealthBack.From = barOffset
        obj.HealthBack.To = barOffset + Vector2.new(0, barH)
        obj.HealthBack.Color = Color3.new(0, 0, 0)
        obj.HealthBack.Transparency = 0.5
        obj.HealthBack.Thickness = s.HealthBarWidth + 1.5
        obj.HealthBack.Visible = true
        for i, seg in ipairs(obj.HealthSegments) do
            local tS = (i - 1) / #obj.HealthSegments
            if tS < healthPercent then
                seg.From = barOffset + Vector2.new(0, barH - (barH * tS))
                seg.To = barOffset + Vector2.new(0, barH - (barH * math.min(i / #obj.HealthSegments, healthPercent)))
                seg.Color = s.HealthLow:Lerp(s.HealthHigh, tS)
                seg.Transparency = 1; seg.Thickness = s.HealthBarWidth; seg.Visible = true
            else seg.Visible = false end
        end
    end

    if s.ShowSkeleton then
        local joints = {}
        local isR15 = char:FindFirstChild("UpperTorso") ~= nil
        if isR15 then
            joints = {
                {char:FindFirstChild("Head"), char:FindFirstChild("UpperTorso")}, {char:FindFirstChild("UpperTorso"), char:FindFirstChild("LowerTorso")},
                {char:FindFirstChild("UpperTorso"), char:FindFirstChild("LeftUpperArm")}, {char:FindFirstChild("LeftUpperArm"), char:FindFirstChild("LeftLowerArm")},
                {char:FindFirstChild("UpperTorso"), char:FindFirstChild("RightUpperArm")}, {char:FindFirstChild("RightUpperArm"), char:FindFirstChild("RightLowerArm")},
                {char:FindFirstChild("LowerTorso"), char:FindFirstChild("LeftUpperLeg")}, {char:FindFirstChild("LeftUpperLeg"), char:FindFirstChild("LeftLowerLeg")},
                {char:FindFirstChild("LowerTorso"), char:FindFirstChild("RightUpperLeg")}, {char:FindFirstChild("RightUpperLeg"), char:FindFirstChild("RightLowerLeg")}
            }
        else
            joints = {
                {char:FindFirstChild("Head"), char:FindFirstChild("Torso")}, {char:FindFirstChild("Torso"), char:FindFirstChild("Left Arm")}, {char:FindFirstChild("Torso"), char:FindFirstChild("Right Arm")},
                {char:FindFirstChild("Torso"), char:FindFirstChild("Left Leg")}, {char:FindFirstChild("Torso"), char:FindFirstChild("Right Leg")}
            }
        end
        for i, pair in ipairs(joints) do
            if pair[1] and pair[2] then
                local p1, v1 = Camera:WorldToViewportPoint(pair[1].Position)
                local p2, v2 = Camera:WorldToViewportPoint(pair[2].Position)
                if v1 and v2 then
                    local startPos, endPos = Vector2.new(p1.X, p1.Y), Vector2.new(p2.X, p2.Y)
                    local boneVec = endPos - startPos
                    for j = 1, 5 do
                        local segIdx = ((i-1) * 5) + j
                        local seg = obj.SkeletonSegments[segIdx]
                        if seg then
                            local tS = (j-1)/5
                            seg.From, seg.To = startPos + (boneVec * tS), startPos + (boneVec * (j/5))
                            seg.Color, seg.Transparency, seg.Thickness, seg.Visible = topColor:Lerp(botColor, tS * 0.5), borderPulse, s.SkeletonThickness, true
                        end
                    end
                end
            end
        end
    end

    if s.ShowTracer then
        local chest = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        if chest then
            local chestPos, onScreen = Camera:WorldToViewportPoint(chest.Position)
            local origin = s.TracerOrigin == "Bottom" and Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            if onScreen then
                local fullVec = Vector2.new(chestPos.X, chestPos.Y) - origin
                for i, seg in ipairs(obj.TracerSegments) do
                    local tS = (i-1)/#obj.TracerSegments
                    seg.From, seg.To = origin + (fullVec * tS), origin + (fullVec * (i/#obj.TracerSegments))
                    seg.Color, seg.Transparency, seg.Thickness, seg.Visible = botColor:Lerp(topColor, tS), smoothPulse, 1.2, true
                end
            end
        end
    end

    if s.FillEnabled and not s.FPSMode then
        local fH, vPad = size.Y * s.FillHeightScale, (size.Y - (size.Y * s.FillHeightScale)) / 2
        for i, line in ipairs(obj.FillLines) do
            local t = (i-1)/(#obj.FillLines-1)
            local relY = vPad + (fH * t)
            local xOff = s.Rounded and (relY < r and r - math.sqrt(math.max(0, r^2 - (r - relY)^2)) or (relY > size.Y - r and r - math.sqrt(math.max(0, r^2 - (relY - (size.Y - r))^2)) or 0)) or 0
            line.From, line.To = pos + Vector2.new(math.max(xOff, s.FillInset), relY), pos + Vector2.new(size.X - math.max(xOff, s.FillInset), relY)
            line.Color, line.Transparency, line.Thickness, line.Visible = topColor:Lerp(botColor, t), smoothPulse, (fH / #obj.FillLines) + 0.8, true
        end
    end

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
        for _, p in ipairs(pG) do p.Transparency, p.Visible, p.Color = borderPulse, true, (p==obj.L[i] or p==obj.R[i]) and topColor:Lerp(botColor, t) or ((p==obj.TL[i] or p==obj.TR[i]) and topColor or botColor) end
    end
    obj.T.From, obj.T.To = pos + Vector2.new(r, 0), pos + Vector2.new(size.X - r, 0)
    obj.B.From, obj.B.To = pos + Vector2.new(r, size.Y), pos + Vector2.new(size.X - r, size.Y)
    obj.T.Color, obj.B.Color, obj.T.Transparency, obj.B.Transparency, obj.T.Visible, obj.B.Visible = topColor, botColor, borderPulse, borderPulse, true, true
end

local Connection = RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not ESPTable[player] then ESPTable[player] = CreateESP(player) end
        local obj, char = ESPTable[player], player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            local hrp, hum = char.HumanoidRootPart, char.Humanoid
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                if dist < ESPLibrary.Settings.MaxDistance then
                    local w, h = 2300/dist, 3800/dist
                    local bPos = Vector2.new(pos.X - w/2, pos.Y - h/2)
                    UpdateESP(obj, bPos, Vector2.new(w, h), player.TeamColor.Color, hum.Health / hum.MaxHealth, char, player.Name)
                else SetVisible(obj, false) end
            else SetVisible(obj, false) end
        else SetVisible(obj, false) end
    end
end)

local function CleanupPlayer(p)
    if ESPTable[p] then
        local data = ESPTable[p]
        if data.Highlight then data.Highlight:Destroy() end
        for _, drawing in ipairs(data.AllDrawings) do
            drawing:Remove()
        end
        ESPTable[p] = nil
    end
end

Players.PlayerRemoving:Connect(CleanupPlayer)

_G.ESP_Cleanup = function()
    Connection:Disconnect()
    for p, _ in pairs(ESPTable) do 
        CleanupPlayer(p)
    end
    table.clear(ESPTable)
end
