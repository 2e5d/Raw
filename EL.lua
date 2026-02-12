--[[
    GEMINI ESP LIBRARY - V3 (JOIN/LEAVE STABILITY FIX)
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
    if player == LocalPlayer then return end
    
    local obj = {
        Player = player,
        Drawings = {},
        Lines = {},
        Skeleton = {},
        Tracers = {},
        Fill = {},
        Highlight = nil
    }

    local function NewDraw(type, properties)
        local d = Drawing.new(type)
        for i, v in pairs(properties) do d[i] = v end
        table.insert(obj.Drawings, d)
        return d
    end

    -- Create Visual Elements
    obj.Name = NewDraw("Text", {Center = true, Outline = true, ZIndex = 10})
    obj.HealthBack = NewDraw("Line", {Thickness = 3, Color = Color3.new(0,0,0), Transparency = 0.5, ZIndex = 1})
    obj.Top = NewDraw("Line", {Thickness = 2, ZIndex = 5})
    obj.Bottom = NewDraw("Line", {Thickness = 2, ZIndex = 5})

    for i = 1, 15 do table.insert(obj.Skeleton, NewDraw("Line", {Thickness = 1.5, ZIndex = 4})) end
    for i = 1, 10 do table.insert(obj.Tracers, NewDraw("Line", {Thickness = 1, ZIndex = 1})) end
    for i = 1, 25 do table.insert(obj.Lines, NewDraw("Line", {Thickness = 2, ZIndex = 5})) end -- Box Corners
    for i = 1, 20 do table.insert(obj.Fill, NewDraw("Line", {Thickness = 1, ZIndex = 0})) end

    local hl = Instance.new("Highlight")
    hl.Name = "ESP_Highlight"
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    obj.Highlight = hl

    ESPTable[player] = obj
end

-- 4. THE FIX: STABLE REMOVAL
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

-- 5. RIG HELPERS
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
    local settings = _G.ESPLibrary.Settings
    if not settings.Enabled then
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

            if onScreen and dist < settings.MaxDistance then
                local scale = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 1000
                local w, h = 4 * scale, 6 * scale
                local tl = Vector2.new(pos.X - w/2, pos.Y - h/2)
                local color = player.TeamColor.Color

                -- Update Name
                obj.Name.Visible = settings.ShowName
                if settings.ShowName then
                    obj.Name.Text = player.Name:upper()
                    obj.Name.Position = Vector2.new(pos.X, tl.Y - settings.NameHeightOffset)
                    obj.Name.Color = color
                    obj.Name.Size = settings.NameSize
                end

                -- Update Skeleton
                if settings.ShowSkeleton then
                    local joints = GetJoints(char)
                    for i, line in ipairs(obj.Skeleton) do
                        local pair = joints[i]
                        if pair and pair[1] and pair[2] then
                            local p1 = Camera:WorldToViewportPoint(pair[1].Position)
                            local p2 = Camera:WorldToViewportPoint(pair[2].Position)
                            line.From = Vector2.new(p1.X, p1.Y)
                            line.To = Vector2.new(p2.X, p2.Y)
                            line.Color = color
                            line.Visible = true
                        else line.Visible = false end
                    end
                else
                    for _, l in ipairs(obj.Skeleton) do l.Visible = false end
                end

                -- Simple Box (Most stable for join/leave)
                obj.Top.From = tl; obj.Top.To = tl + Vector2.new(w, 0)
                obj.Bottom.From = tl + Vector2.new(0, h); obj.Bottom.To = tl + Vector2.new(w, h)
                obj.Top.Visible = true; obj.Bottom.Visible = true; obj.Top.Color = color; obj.Bottom.Color = color

                if obj.Highlight then
                    obj.Highlight.Parent = char
                    obj.Highlight.Enabled = settings.ChamsEnabled
                    obj.Highlight.FillColor = color
                    obj.Highlight.FillTransparency = settings.ChamsFillTransparency
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
    table.clear(ESPTable)
end
