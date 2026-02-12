--[[
    GEMINI ESP LIBRARY - CLASSIC EDITION
    Features: Classic Box, Vertical Health Bar, Skeleton, and Chams.
    Optimized for Fluid Menu Integration.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- 1. PRE-RUN CLEANUP (Prevents duplicate drawings if re-executed)
if _G.ESP_Cleanup then _G.ESP_Cleanup() end

-- 2. SETTINGS CONFIG
_G.ESPLibrary = {
    Settings = {
        Enabled = true,
        FPSMode = false,
        MaxDistance = 2500,
        
        -- NAMES
        ShowName = true,
        NameSize = 18,
        NameBold = true,
        NameOutline = true,
        NameHeightOffset = 15,
        
        -- CHAMS
        ChamsEnabled = true,
        ChamsFillTransparency = 0.5,
        
        -- SKELETON
        ShowSkeleton = true,
        SkeletonThickness = 1.2,
        
        -- HEALTH BAR
        ShowHealth = true,
        HealthBarWidth = 2,
        HealthBarOffset = 5,
        
        -- BOX STYLE
        BoxThickness = 1.5,
        
        -- TRACERS
        ShowTracer = true,
        TracerOrigin = "Bottom",
        
        -- COLORS
        HealthHigh = Color3.fromRGB(0, 255, 150),
        HealthLow = Color3.fromRGB(255, 50, 50),
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
        BoxLines = {}, 
        Skeleton = {},
        Tracers = {},
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
    
    -- Box (Top, Right, Bottom, Left)
    for i = 1, 4 do table.insert(obj.BoxLines, NewDraw("Line", {Thickness = 1.5, ZIndex = 5})) end

    -- Health Bar
    obj.HealthBg = NewDraw("Line", {Thickness = 3, Color = Color3.new(0,0,0), Transparency = 0.5, ZIndex = 1})
    obj.HealthMain = NewDraw("Line", {Thickness = 2, ZIndex = 2})

    -- Skeleton & Tracers
    for i = 1, 15 do table.insert(obj.Skeleton, NewDraw("Line", {Thickness = 1, ZIndex = 4})) end
    for i = 1, 10 do table.insert(obj.Tracers, NewDraw("Line", {Thickness = 1, ZIndex = 1})) end

    local hl = Instance.new("Highlight")
    hl.Name = "ESP_Highlight"
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    obj.Highlight = hl

    ESPTable[player] = obj
end

-- 4. CLEANUP (Fixes Join/Leave issues)
local function RemoveESP(player)
    local obj = ESPTable[player]
    if obj then
        if obj.Highlight then obj.Highlight:Destroy() end
        for _, d in ipairs(obj.Drawings) do d:Remove() end
        ESPTable[player] = nil
    end
end

-- 5. RIG RESOLVER (Supports R6 and R15)
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
                local tr = tl + Vector2.new(w, 0)
                local bl = tl + Vector2.new(0, h)
                local br = tl + Vector2.new(w, h)
                local color = player.TeamColor.Color

                -- Name
                obj.Name.Visible = s.ShowName
                if s.ShowName then
                    obj.Name.Text = player.Name:upper()
                    obj.Name.Position = Vector2.new(pos.X, tl.Y - s.NameHeightOffset)
                    obj.Name.Color = color
                    obj.Name.Size = s.NameSize
                end

                -- Box
                obj.BoxLines[1].From = tl; obj.BoxLines[1].To = tr
                obj.BoxLines[2].From = tr; obj.BoxLines[2].To = br
                obj.BoxLines[3].From = br; obj.BoxLines[3].To = bl
                obj.BoxLines[4].From = bl; obj.BoxLines[4].To = tl
                for _, l in ipairs(obj.BoxLines) do l.Visible = true; l.Color = color; l.Thickness = s.BoxThickness end

                -- Health Bar
                obj.HealthBg.Visible = s.ShowHealth
                obj.HealthMain.Visible = s.ShowHealth
                if s.ShowHealth then
                    local hpPercent = hum.Health / hum.MaxHealth
                    local barPos = tl - Vector2.new(s.HealthBarOffset, 0)
                    obj.HealthBg.From = barPos; obj.HealthBg.To = barPos + Vector2.new(0, h)
                    obj.HealthMain.From = barPos + Vector2.new(0, h)
                    obj.HealthMain.To = barPos + Vector2.new(0, h - (h * hpPercent))
                    obj.HealthMain.Color = s.HealthLow:Lerp(s.HealthHigh, hpPercent)
                end

                -- Skeleton
                if s.ShowSkeleton then
                    local joints = GetJoints(char)
                    for i, line in ipairs(obj.Skeleton) do
                        local pair = joints[i]
                        if pair and pair[1] and pair[2] then
                            local p1 = Camera:WorldToViewportPoint(pair[1].Position)
                            local p2 = Camera:WorldToViewportPoint(pair[2].Position)
                            line.From = Vector2.new(p1.X, p1.Y); line.To = Vector2.new(p2.X, p2.Y)
                            line.Color = color; line.Visible = true
                        else line.Visible = false end
                    end
                else
                    for _, l in ipairs(obj.Skeleton) do l.Visible = false end
                end

                -- Tracers
                if s.ShowTracer then
                    local origin = s.TracerOrigin == "Bottom" and Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y) or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    local fullVec = pos - origin
                    for i, seg in ipairs(obj.Tracers) do
                        local tS = (i-1)/#obj.Tracers
                        seg.From, seg.To = origin + (fullVec * tS), origin + (fullVec * (i/#obj.Tracers))
                        seg.Color = color; seg.Visible = true
                    end
                else
                    for _, l in ipairs(obj.Tracers) do l.Visible = false end
                end

                -- Chams
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

local RenderConnection = RunService.RenderStepped:Connect(Update)

_G.ESP_Cleanup = function()
    RenderConnection:Disconnect()
    for p, _ in pairs(ESPTable) do RemoveESP(p) end
    table.clear(ESPTable)
end

return _G.ESPLibrary
