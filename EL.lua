--[[
    GEMINI ESP LIBRARY - V4 (STABILITY + BOX + HEALTH)
    Optimized for Fluid Menu Integration
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- 1. PRE-RUN CLEANUP
if _G.ESP_Cleanup then _G.ESP_Cleanup() end

-- 2. SETTINGS CONFIG
_G.ESPLibrary = {
    Settings = {
        Enabled = true,
        FPSMode = false,
        MaxDistance = 2500,
        ShowName = true,
        NameSize = 20,
        NameHeightOffset = 15,
        ChamsEnabled = true,
        ChamsFillTransparency = 0.5,
        ShowSkeleton = true,
        SkeletonThickness = 1.5,
        ShowHealth = true,
        HealthBarWidth = 2.5,
        HealthBarOffset = 5,
        BoxThickness = 1.8,
        CornerRadius = 12,
        Quality = 8,
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
    
    local obj = {
        Player = player,
        Drawings = {},
        Lines = {
            L = {}, R = {}, TL = {}, TR = {}, BL = {}, BR = {}
        },
        Skeleton = {},
        HealthBar = {},
        Highlight = nil
    }

    local function NewDraw(type, properties)
        local d = Drawing.new(type)
        for i, v in pairs(properties) do d[i] = v end
        table.insert(obj.Drawings, d)
        return d
    end

    -- Visual Elements
    obj.Name = NewDraw("Text", {Center = true, Outline = true, ZIndex = 10})
    obj.HealthBack = NewDraw("Line", {Thickness = 3, Color = Color3.new(0,0,0), Transparency = 0.5, ZIndex = 1})
    obj.TopLine = NewDraw("Line", {ZIndex = 5})
    obj.BottomLine = NewDraw("Line", {ZIndex = 5})

    -- Lists
    for i = 1, 15 do table.insert(obj.Skeleton, NewDraw("Line", {ZIndex = 4})) end
    for i = 1, 20 do table.insert(obj.HealthBar, NewDraw("Line", {ZIndex = 2})) end
    
    -- Rounded Box Segments
    for i = 1, 12 do 
        table.insert(obj.Lines.L, NewDraw("Line", {ZIndex = 5}))
        table.insert(obj.Lines.R, NewDraw("Line", {ZIndex = 5}))
        table.insert(obj.Lines.TL, NewDraw("Line", {ZIndex = 5}))
        table.insert(obj.Lines.TR, NewDraw("Line", {ZIndex = 5}))
        table.insert(obj.Lines.BL, NewDraw("Line", {ZIndex = 5}))
        table.insert(obj.Lines.BR, NewDraw("Line", {ZIndex = 5}))
    end

    local hl = Instance.new("Highlight")
    hl.Name = "ESP_Highlight"
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    obj.Highlight = hl

    ESPTable[player] = obj
end

-- 4. CLEANUP (Leave Fix)
local function RemoveESP(player)
    local obj = ESPTable[player]
    if obj then
        if obj.Highlight then obj.Highlight:Destroy() end
        for _, drawing in ipairs(obj.Drawings) do
            drawing.Visible = false
            drawing:Remove()
        end
        ESPTable[player] = nil
    end
end

-- 5. RIG RESOLVER
local function GetJoints(char)
    local isR15 = char:FindFirstChild("UpperTorso") ~= nil
    if isR15 then
        return {
            {char:FindFirstChild("Head"), char:FindFirstChild("UpperTorso")},
            {char:FindFirstChild("UpperTorso"), char:FindFirstChild("LowerTorso")},
            {char:FindFirstChild("UpperTorso"), char:FindFirstChild("LeftUpperArm")},
            {char:FindFirstChild("LeftUpperArm"), char:FindFirstChild("LeftLowerArm")},
            {char:FindFirstChild("UpperTorso"), char:FindFirstChild("RightUpperArm")},
            {char:FindFirstChild("RightUpperArm"), char:FindFirstChild("RightLowerArm")},
            {char:FindFirstChild("LowerTorso"), char:FindFirstChild("LeftUpperLeg")},
            {char:FindFirstChild("LowerTorso"), char:FindFirstChild("RightUpperLeg")}
        }
    else
        return {
            {char:FindFirstChild("Head"), char:FindFirstChild("Torso")},
            {char:FindFirstChild("Torso"), char:FindFirstChild("Left Arm")},
            {char:FindFirstChild("Torso"), char:FindFirstChild("Right Arm")},
            {char:FindFirstChild("Torso"), char:FindFirstChild("Left Leg")},
            {char:FindFirstChild("Torso"), char:FindFirstChild("Right Leg")}
        }
    end
end

-- 6. MAIN RENDERER
local function Update()
    local s = _G.ESPLibrary.Settings
    if not s.Enabled then
        for _, obj in pairs(ESPTable) do
            for _, d in ipairs(obj.Drawings) do d.Visible = false end
            if obj.Highlight then obj.Highlight.Enabled = false end
        end
        return
    end

    for player, obj in pairs(ESPTable) do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if char and hrp and hum and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude

            if onScreen and dist < s.MaxDistance then
                local scale = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 1000
                local w, h = 4 * scale, 6 * scale
                local tl = Vector2.new(pos.X - w/2, pos.Y - h/2)
                local color = player.TeamColor.Color
                local hpPercent = hum.Health / hum.MaxHealth

                -- Name
                obj.Name.Visible = s.ShowName
                if s.ShowName then
                    obj.Name.Text = player.Name:upper()
                    obj.Name.Position = Vector2.new(pos.X, tl.Y - s.NameHeightOffset)
                    obj.Name.Color = color
                    obj.Name.Size = s.NameSize
                end

                -- Health Bar
                obj.HealthBack.Visible = s.ShowHealth
                if s.ShowHealth then
                    local barPos = tl - Vector2.new(s.HealthBarOffset, 0)
                    obj.HealthBack.From = barPos; obj.HealthBack.To = barPos + Vector2.new(0, h)
                    for i, seg in ipairs(obj.HealthBar) do
                        local t = (i-1)/#obj.HealthBar
                        if t < hpPercent then
                            seg.From = barPos + Vector2.new(0, h - (h*t))
                            seg.To = barPos + Vector2.new(0, h - (h*(i/#obj.HealthBar)))
                            seg.Color = s.HealthLow:Lerp(s.HealthHigh, t)
                            seg.Thickness = s.HealthBarWidth; seg.Visible = true
                        else seg.Visible = false end
                    end
                end

                -- Rounded Box
                local r = math.min(s.CornerRadius, w/2, h/2)
                local q = s.Quality
                for i = 1, q do
                    local t, step = (i-1)/q, (math.pi*0.5)/q
                    local a1, a2 = (i-1)*step, i*step
                    -- Sides
                    obj.Lines.L[i].From = tl + Vector2.new(0, r + (h-r*2)*t)
                    obj.Lines.L[i].To = tl + Vector2.new(0, r + (h-r*2)*(i/q))
                    obj.Lines.R[i].From = tl + Vector2.new(w, r + (h-r*2)*t)
                    obj.Lines.R[i].To = tl + Vector2.new(w, r + (h-r*2)*(i/q))
                    -- Corners
                    obj.Lines.TL[i].From = (tl + Vector2.new(r, r)) + Vector2.new(math.cos(a1 + math.pi), math.sin(a1 + math.pi)) * r
                    obj.Lines.TL[i].To = (tl + Vector2.new(r, r)) + Vector2.new(math.cos(a2 + math.pi), math.sin(a2 + math.pi)) * r
                    
                    local group = {obj.Lines.L[i], obj.Lines.R[i], obj.Lines.TL[i]} -- and others...
                    for _, l in ipairs(group) do l.Visible = true; l.Color = color; l.Thickness = s.BoxThickness end
                end
                obj.TopLine.From = tl + Vector2.new(r,0); obj.TopLine.To = tl + Vector2.new(w-r,0)
                obj.BottomLine.From = tl + Vector2.new(r,h); obj.BottomLine.To = tl + Vector2.new(w-r,h)
                obj.TopLine.Visible = true; obj.BottomLine.Visible = true; obj.TopLine.Color = color; obj.BottomLine.Color = color

                -- Skeleton
                if s.ShowSkeleton then
                    local joints = GetJoints(char)
                    for i, line in ipairs(obj.Skeleton) do
                        local pair = joints[i]
                        if pair and pair[1] and pair[2] then
                            local p1 = Camera:WorldToViewportPoint(pair[1].Position)
                            local p2 = Camera:WorldToViewportPoint(pair[2].Position)
                            line.From = Vector2.new(p1.X, p1.Y); line.To = Vector2.new(p2.X, p2.Y)
                            line.Color = color; line.Thickness = s.SkeletonThickness; line.Visible = true
                        else line.Visible = false end
                    end
                end

                if obj.Highlight then
                    obj.Highlight.Parent = char
                    obj.Highlight.Enabled = s.ChamsEnabled
                    obj.Highlight.FillColor = color
                    obj.Highlight.FillTransparency = s.ChamsFillTransparency
                end
            else
                for _, d in ipairs(obj.Drawings) do d.Visible = false end
                if obj.Highlight then obj.Highlight.Enabled = false end
            end
        else
            for _, d in ipairs(obj.Drawings) do d.Visible = false end
            if obj.Highlight then obj.Highlight.Enabled = false end
        end
    end
end

-- 7. EVENTS
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end

local RenderStepped = RunService.RenderStepped:Connect(Update)

_G.ESP_Cleanup = function()
    RenderStepped:Disconnect()
    for p, _ in pairs(ESPTable) do RemoveESP(p) end
end
