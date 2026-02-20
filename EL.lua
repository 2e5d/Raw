local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- 1. CLEANUP PREVIOUS SESSIONS
if _G.ESP_Cleanup then 
    _G.ESP_Cleanup() 
end

-- 2. GLOBAL SETTINGS (Headless Config)
_G.ESPLibrary = {
    Settings = {
        Enabled = true,
        TeamCheck = true, -- [cite: 1, 34]
        MaxDistance = 1000, -- [cite: 1]
        
        -- BOX FILL (Matchav2 Style)
        BoxGradientEnabled = true, -- [cite: 8]
        BoxGradientColor1 = Color3.new(0.403922, 0.34902, 0.701961), -- [cite: 1]
        BoxGradientColor2 = Color3.new(0.8, 0.4, 1), -- [cite: 1]
        BoxFillTransparency = 0.5, -- [cite: 1]
        
        -- BORDERS
        BoxOutlineEnabled = true, -- [cite: 1]
        BoxOutlineColor = Color3.new(0, 0, 0), -- [cite: 1]
        BoxThickness = 1.2, -- [cite: 9]
        
        -- NAMES & HEALTH
        ShowName = true, -- [cite: 3]
        ShowHealth = true, -- [cite: 3]
        HealthBarLerpSpeed = 0.2, -- [cite: 2]
        HealthBarColor1 = Color3.fromRGB(0, 255, 0), -- [cite: 2]
        HealthBarColor2 = Color3.fromRGB(255, 255, 0), -- [cite: 2]
        HealthBarColor3 = Color3.fromRGB(255, 0, 0), -- [cite: 2]
    }
}

local ESPTable = {}
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- UI Parent for Gradient Frames (Created via script, no manual UI needed)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Matcha_Headless_ESP"
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = -1 -- Ensures it stays behind other game UI
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

-- 3. DRAWING CONSTRUCTOR
local function CreateESP(player)
    if player == LocalPlayer then return end
    if ESPTable[player] then return end

    -- Frame-based fill to support UIGradient [cite: 8]
    local fillFrame = Instance.new("Frame")
    fillFrame.BorderSizePixel = 0
    fillFrame.BackgroundTransparency = 1
    fillFrame.Visible = false
    fillFrame.ZIndex = -1 -- Fixes the overlaying issue by pushing it to the back
    fillFrame.Parent = ScreenGui

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, _G.ESPLibrary.Settings.BoxGradientColor1),
        ColorSequenceKeypoint.new(0.5, _G.ESPLibrary.Settings.BoxGradientColor2),
        ColorSequenceKeypoint.new(1, _G.ESPLibrary.Settings.BoxGradientColor1)
    }) -- [cite: 8, 9]
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

    obj.Name.Center = true -- [cite: 11]
    obj.Name.Outline = true -- [cite: 10]
    obj.Name.Size = 13 -- [cite: 10]
    obj.Name.Font = 2 -- [cite: 10]

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

    -- Team Check [cite: 34, 35]
    if s.TeamCheck and player.Team == LocalPlayer.Team then
        obj.FillFrame.Visible = false
        obj.Name.Visible = false
        obj.HealthBar.Visible = false
        obj.HealthBack.Visible = false
        return
    end

    local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    local distance = (Camera.CFrame.Position - hrp.Position).Magnitude -- [cite: 32]
    
    if onScreen and distance <= s.MaxDistance then
        -- Calculations from Matchav2 [cite: 46, 47]
        local headTopPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
        local feetPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
        
        local height = math.abs(headTopPos.Y - feetPos.Y)
        local width = height * 0.60 -- [cite: 46]
        local topLeft = Vector2.new(rootPos.X - width/2, (headTopPos.Y + feetPos.Y)/2 - height/2)

        -- 1. BOX FILL & GRADIENT (Z-Fixed) [cite: 54, 55, 56]
        obj.FillFrame.Position = UDim2.fromOffset(topLeft.X, topLeft.Y)
        obj.FillFrame.Size = UDim2.fromOffset(width, height)
        obj.FillFrame.BackgroundTransparency = s.BoxFillTransparency
        obj.FillFrame.Visible = s.BoxGradientEnabled
        
        obj.Stroke.Enabled = s.BoxOutlineEnabled
        obj.Stroke.Color = s.BoxOutlineColor

        -- 2. NAME [cite: 68, 69]
        if s.ShowName then
            obj.Name.Position = Vector2.new(rootPos.X, headTopPos.Y - 20)
            obj.Name.Text = player.Name
            obj.Name.Visible = true
        else
            obj.Name.Visible = false
        end

        -- 3. HEALTH BAR [cite: 86, 87]
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
            
            -- Color Logic [cite: 78, 79]
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

-- 5. RUNTIME LOOP 
local Connection = RunService.RenderStepped:Connect(function()
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

-- Cleanup function for re-injection
_G.ESP_Cleanup = function()
    Connection:Disconnect()
    ScreenGui:Destroy()
    for _, obj in pairs(ESPTable) do 
        obj.FillFrame:Destroy()
        obj.Name:Remove()
        obj.HealthBar:Remove()
        obj.HealthBack:Remove()
    end
    table.clear(ESPTable)
end
