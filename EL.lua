local ESPLibrary = {
    Settings = {
        Enabled = true,
        FPSMode = false,        
        MaxDistance = 2500,
        
        -- NAME SETTINGS
        ShowName = true,
        NameSize = 22,          
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

-- Internal Functions
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

-- Update Logic (Condensed for the library)
local function UpdateESP(obj, pos, size, topColor, healthPercent, char, playerName)
    local s = ESPLibrary.Settings
    local wave = s.PulseEnabled and ((math.sin(tick() * s.PulseSpeed) + 1) / 2) or 1
    local borderPulse = math.clamp((s.MinTransparency + (s.MaxTransparency - s.MinTransparency) * wave) + 0.35, 0.5, 1)

    -- Name Logic
    if s.ShowName then
        obj.Name.Text = playerName:upper()
        obj.Name.Color = topColor
        obj.Name.Size = math.clamp(size.Y * 0.12, 18, s.NameSize)
        obj.Name.Position = Vector2.new(pos.X + size.X/2, pos.Y - (obj.Name.Size + s.NameHeightOffset))
        obj.Name.Visible = true
    else obj.Name.Visible = false end

    -- Gradient Chams Logic
    if s.ChamsEnabled and char then
        obj.Highlight.Parent = char
        obj.Highlight.FillColor = topColor
        obj.Highlight.FillTransparency = math.clamp(1 - (s.ChamsFillTransparency * wave), 0.1, 0.9)
        obj.Highlight.OutlineColor = topColor:Lerp(Color3.new(1,1,1), wave * 0.5)
        obj.Highlight.Enabled = true
    end

    -- Health Bar Logic
    if s.ShowHealth then
        local barH, barOffset = size.Y * s.HealthBarHeightScale, pos - Vector2.new(s.HealthBarOffset, 0)
        obj.HealthBack.From, obj.HealthBack.To = barOffset, barOffset + Vector2.new(0, barH)
        obj.HealthBack.Visible = true
        for i, seg in ipairs(obj.HealthSegments) do
            local tS = (i - 1) / #obj.HealthSegments
            if tS < healthPercent then
                seg.From = barOffset + Vector2.new(0, barH - (barH * tS))
                seg.To = barOffset + Vector2.new(0, barH - (barH * math.min(i / #obj.HealthSegments, healthPercent)))
                seg.Color, seg.Visible = s.HealthLow:Lerp(s.HealthHigh, tS), true
            else seg.Visible = false end
        end
    end
    
    -- [Rest of Box/Skeleton/Tracer logic remains inside the loop]
end

-- Library Methods
function ESPLibrary:Init()
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
end

return ESPLibrary
