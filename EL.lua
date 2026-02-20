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
        MaxDistance = 1000, -- Matches ESPDistance [cite: 260]
        
        -- BOX GRADIENT (From Matchav2)
        BoxGradientEnabled = true, -- Set to true for the new style [cite: 281]
        BoxGradientColor1 = Color3.new(0.403922, 0.34902, 0.701961), -- [cite: 195]
        BoxGradientColor2 = Color3.new(0.8, 0.4, 1), -- [cite: 195]
        BoxFillTransparency = 0.5, -- [cite: 282]
        
        -- BORDERS
        BoxOutlineEnabled = true, -- [cite: 284]
        BoxOutlineColor = Color3.new(0, 0, 0), -- [cite: 195]
        BoxThickness = 1.2, -- Matches Stroke Thickness 
        
        -- NAMES & HEALTH
        ShowName = true,
        ShowHealth = true,
        HealthBarLerpSpeed = 0.2, -- [cite: 277]
        HealthBarColor1 = Color3.fromRGB(0, 255, 0),
        HealthBarColor2 = Color3.fromRGB(255, 255, 0),
        HealthBarColor3 = Color3.fromRGB(255, 0, 0),
    }
}

local ESPTable = {}
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- UI Parent for Gradient Frames
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Matcha_ESP_Layer"
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

-- 3. DRAWING CONSTRUCTOR
local function CreateESP(player)
    if player == LocalPlayer then return end
    if ESPTable[player] then return end

    -- GUI based elements for the Fill
    local fillFrame = Instance.new("Frame")
    fillFrame.BorderSizePixel = 0
    fillFrame.BackgroundTransparency = 1
    fillFrame.Visible = false
    fillFrame.Parent = ScreenGui

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, _G.ESPLibrary.Settings.BoxGradientColor1),
        ColorSequenceKeypoint.new(0.5, _G.ESPLibrary.Settings.BoxGradientColor2),
        ColorSequenceKeypoint.new(1, _G.ESPLibrary.Settings.BoxGradientColor1)
    })
    gradient.Parent = fillFrame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = _G.ESPLibrary.Settings.BoxThickness
    stroke.Color = _G.ESPLibrary.Settings.BoxOutlineColor
    stroke.Enabled = _G.ESPLibrary.Settings.BoxOutlineEnabled
    stroke.Parent = fillFrame

    local obj = {
        Player = player,
        FillFrame = fillFrame,
        Gradient = gradient,
        Stroke = stroke,
        Name = Drawing.new("Text"),
        HealthBar = Drawing.new("Line"),
        HealthBack = Drawing.new("Line"),
        CurrentHealth = 100,
        TargetHealth = 100
    }

    obj.Name.Center = true
    obj.Name.Outline = true
    obj.Name.Size = 13 -- [cite: 237]
    obj.Name.Font = 2 -- [cite: 238]

    ESPTable[player] = obj
end

local function RemoveESP(player)
    local obj = ESPTable[player]
    if obj then
        obj.FillFrame:Destroy()
        obj.Name:Remove()
        obj.HealthBar:Remove()
        obj.HealthBack:Remove()
        ESPTable[player] = nil
    end
end

-- 4. UPDATE ENGINE
local function UpdateESP(obj, player, char)
    local s = _G.ESPLibrary.Settings
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    local head = char:FindFirstChild("Head")
    
    if not (hrp and hum and head) then 
        obj.FillFrame.Visible = false
        obj.Name.Visible = false
        return 
    end

    local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    
    if onScreen then
        -- Calculations from Matchav2 [cite: 270, 271, 273, 274]
        local headTopPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
        local feetPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
        
        local height = math.abs(headTopPos.Y - feetPos.Y)
        local width = height * 0.60 -- The 0.60 ratio from source 
        local topLeft = Vector2.new(rootPos.X - width/2, (headTopPos.Y + feetPos.Y)/2 - height/2)

        -- 1. BOX FILL & GRADIENT [cite: 281, 282]
        obj.FillFrame.Position = UDim2.fromOffset(topLeft.X, topLeft.Y)
        obj.FillFrame.Size = UDim2.fromOffset(width, height)
        obj.FillFrame.BackgroundTransparency = s.BoxFillTransparency
        obj.FillFrame.Visible = s.BoxGradientEnabled
        
        obj.Stroke.Enabled = s.BoxOutlineEnabled
        obj.Stroke.Color = s.BoxOutlineColor

        -- 2. NAME [cite: 295, 296]
        if s.ShowName then
            obj.Name.Position = Vector2.new(rootPos.X, headTopPos.Y - 20)
            obj.Name.Text = player.Name
            obj.Name.Visible = true
        else
            obj.Name.Visible = false
        end

        -- 3. HEALTH BAR [cite: 304, 305, 306]
        if s.ShowHealth then
            local health_per = hum.Health / hum.MaxHealth
            local barHeight = height * health_per
            local barX = topLeft.X - 5
            
            obj.HealthBack.Visible = true
            obj.HealthBack.From = Vector2.new(barX, topLeft.Y)
            obj.HealthBack.To = Vector2.new(barX, topLeft.Y + height)
            obj.HealthBack.Color = Color3.new(0,0,0)
            obj.HealthBack.Thickness = 3

            obj.HealthBar.Visible = true
            obj.HealthBar.From = Vector2.new(barX, topLeft.Y + height)
            obj.HealthBar.To = Vector2.new(barX, (topLeft.Y + height) - barHeight)
            
            -- Color Logic [cite: 306]
            local hp = health_per * 100
            obj.HealthBar.Color = hp >= 75 and s.HealthBarColor1 or hp >= 50 and s.HealthBarColor2 or s.HealthBarColor3
            obj.HealthBar.Thickness = 1
        else
            obj.HealthBack.Visible = false
            obj.HealthBar.Visible = false
        end
    else
        obj.FillFrame.Visible = false
        obj.Name.Visible = false
        obj.HealthBar.Visible = false
        obj.HealthBack.Visible = false
    end
end

-- 5. RUNTIME
RunService.RenderStepped:Connect(function()
    if not _G.ESPLibrary.Settings.Enabled then
        for _, obj in pairs(ESPTable) do obj.FillFrame.Visible = false end
        return
    end

    for player, obj in pairs(ESPTable) do
        if player.Character then
            UpdateESP(obj, player, player.Character)
        end
    end
end)

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end

_G.ESP_Cleanup = function()
    ScreenGui:Destroy()
    for _, obj in pairs(ESPTable) do RemoveESP(obj.Player) end
end
