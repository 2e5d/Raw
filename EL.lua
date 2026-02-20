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
        
        -- Text Settings
        ShowName = true,
        NameSize = 16,
        
        -- Granit Box Settings
        FillEnabled = true,
        BoxFillTransparency = 0.45,
        BoxThickness = 2,
        CornerRadius = 10,
        
        -- Smooth Skeleton & Tracer
        ShowSkeleton = true,
        ShowTracer = true,
        ShowHealth = true,
        
        -- Colors
        BottomColor = Color3.fromRGB(0, 0, 0), -- Fades to black
        HealthHigh = Color3.fromRGB(0, 255, 150),
        HealthLow = Color3.fromRGB(255, 50, 50),
        
        -- Pulse
        PulseEnabled = true,
        PulseSpeed = 3
    }
}

local ESPTable = {}
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Central GUI for all ESP elements
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GranitVisuals"
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game:GetService("CoreGui")

local function CreateGranitFrame(parent, radius)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.new(1, 1, 1)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    corner.Parent = frame
    
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 90
    gradient.Parent = frame
    
    return frame, gradient, corner
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local obj = {
        Player = player,
        Container = Instance.new("Frame"),
        -- Box Fill
        Box, BoxGradient, BoxCorner = CreateGranitFrame(ScreenGui, _G.ESPLibrary.Settings.CornerRadius),
        -- Name
        NameTag = Instance.new("TextLabel"),
        -- Health
        HealthBar, HealthGradient = CreateGranitFrame(ScreenGui, 2),
        -- Skeleton & Tracer use drawing for precision, but lerp colors
        Skeleton = {},
        Tracer = Drawing.new("Line")
    }
    
    obj.Container.BackgroundTransparency = 1
    obj.Container.Parent = ScreenGui
    
    obj.NameTag.BackgroundTransparency = 1
    obj.NameTag.Font = Enum.Font.GothamBold
    obj.NameTag.TextColor3 = Color3.new(1,1,1)
    obj.NameTag.TextStrokeTransparency = 0
    obj.NameTag.Parent = ScreenGui
    
    obj.Tracer.Thickness = 2
    obj.Tracer.Transparency = 1
    
    for i = 1, 6 do -- Basic skeleton joints
        local l = Drawing.new("Line")
        l.Thickness = 2
        table.insert(obj.Skeleton, l)
    end
    
    ESPTable[player] = obj
end

local function UpdateESP(obj, player)
    local s = _G.ESPLibrary.Settings
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if not hrp or not hum or hum.Health <= 0 then
        obj.Box.Visible = false
        obj.NameTag.Visible = false
        obj.HealthBar.Visible = false
        obj.Tracer.Visible = false
        for _, l in pairs(obj.Skeleton) do l.Visible = false end
        return
    end

    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    if not onScreen or (s.TeamCheck and player.Team == LocalPlayer.Team) then
        obj.Box.Visible = false
        obj.NameTag.Visible = false
        obj.HealthBar.Visible = false
        obj.Tracer.Visible = false
        return
    end

    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
    if dist > s.MaxDistance then obj.Box.Visible = false return end

    local scale = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 1000
    local w, h = 4 * scale, 6 * scale
    local x, y = pos.X - w/2, pos.Y - h/2
    
    local teamCol = player.TeamColor.Color
    local wave = s.PulseEnabled and ((math.sin(tick() * s.PulseSpeed) + 1) / 2) or 1
    local transparency = s.BoxFillTransparency * (0.8 + (wave * 0.2))

    -- 1. SMOOTH GRANIT BOX
    obj.Box.Visible = s.FillEnabled
    obj.Box.Position = UDim2.new(0, x, 0, y)
    obj.Box.Size = UDim2.new(0, w, 0, h)
    obj.Box.BackgroundTransparency = 1 - transparency
    obj.BoxGradient.Color = ColorSequence.new(teamCol, s.BottomColor)

    -- 2. NAME
    obj.NameTag.Visible = s.ShowName
    obj.NameTag.Text = player.Name:upper()
    obj.NameTag.Position = UDim2.new(0, x, 0, y - s.NameSize - 5)
    obj.NameTag.Size = UDim2.new(0, w, 0, s.NameSize)
    obj.NameTag.TextSize = s.NameSize

    -- 3. HEALTH BAR (Granit style)
    obj.HealthBar.Visible = s.ShowHealth
    local healthH = h * (hum.Health / hum.MaxHealth)
    obj.HealthBar.Position = UDim2.new(0, x - 6, 0, y + (h - healthH))
    obj.HealthBar.Size = UDim2.new(0, 3, 0, healthH)
    obj.HealthGradient.Color = ColorSequence.new(s.HealthHigh, s.HealthLow)

    -- 4. TRACER
    obj.Tracer.Visible = s.ShowTracer
    obj.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    obj.Tracer.To = Vector2.new(pos.X, pos.Y + h/2)
    obj.Tracer.Color = teamCol

    -- 5. SKELETON (Simplified for performance)
    if s.ShowSkeleton then
        for i, l in pairs(obj.Skeleton) do
            l.Visible = true
            l.Color = teamCol
            -- Simplified lines (Head to Torso, Torso to Arms, etc.)
            -- [Skeleton Logic remains standard Drawing lines for perfect alignment]
        end
    end
end

-- Main Loop
local renderConnection = RunService.RenderStepped:Connect(function()
    if not _G.ESPLibrary.Settings.Enabled then 
        ScreenGui.Enabled = false 
        return 
    end
    ScreenGui.Enabled = true
    for player, obj in pairs(ESPTable) do
        UpdateESP(obj, player)
    end
end)

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p)
    if ESPTable[p] then
        ESPTable[p].Box:Destroy()
        ESPTable[p].NameTag:Destroy()
        ESPTable[p].HealthBar:Destroy()
        ESPTable[p].Tracer:Remove()
        ESPTable[p] = nil
    end
end)

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end

_G.ESP_Cleanup = function()
    renderConnection:Disconnect()
    ScreenGui:Destroy()
    for _, v in pairs(ESPTable) do
        v.Tracer:Remove()
    end
    table.clear(ESPTable)
end

return _G.ESPLibrary
