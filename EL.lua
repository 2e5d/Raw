local playersService = game:GetService("Players")
local workspaceService = game:GetService("Workspace")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

local espModule = {}
espModule.__index = espModule

espModule.Config = {
    TeamCheck = true,
    ESPDistance = 1000,
    BoxColor = Color3.new(0.403922, 0.34902, 0.701961),
    BoxGradientEnabled = true, -- Set to true for Gradient Boxes [cite: 1, 16]
    BoxGradientColor1 = Color3.new(0.403922, 0.34902, 0.701961),
    BoxGradientColor2 = Color3.new(0.8, 0.4, 1),
    BoxFillTransparency = 0.5,
    RotateSpeed = 120,
    BoxOutlineEnabled = true,
    BoxOutlineColor = Color3.new(0, 0, 0),
    SkeletonColor = Color3.new(0.403922, 0.34902, 0.701961),
    ChamsColor = Color3.new(0.403922, 0.34902, 0.701961),
    TracerOrigin = "Bottom Screen",
    TracerColor = Color3.new(0.403922, 0.34902, 0.701961),
    ChamsFillTransparency = 0.5,
    ChamsOutlineColor = Color3.new(1, 1, 1),
    HealthBarLerpSpeed = 0.2,
    HealthBarColor1 = Color3.fromRGB(0, 255, 0),
    HealthBarColor2 = Color3.fromRGB(255, 255, 0),
    HealthBarColor3 = Color3.fromRGB(255, 0, 0),
    ArmorBarColor1 = Color3.fromRGB(0, 0, 255),
    ArmorBarColor2 = Color3.fromRGB(135, 206, 235),
    ArmorBarColor3 = Color3.fromRGB(1, 0, 0),
    RingColor = Color3.fromRGB(255, 255, 255),
    ScanSpeed = 2.5,
    ScanHeight = 3.5,
    RingRadius = 2.5
}

espModule.State = {
    BoxEnabled = true, -- Enabled by default
    NameEnabled = true,
    DistanceEnabled = true,
    SkeletonEnabled = false,
    HealthTextEnabled = true,
    HealthBarEnabled = true,
    ArmorBarEnabled = false,
    TracerEnabled = false,
    ChamsEnabled = false,
    RingEnabled = false
}

espModule.Caches = {
    BoxCache = {},
    SkeletonCache = {},
    TracerCache = {},
    ChamsCache = {},
    RingCache = {}
}

local localPlayer = playersService.LocalPlayer
local currentCamera = workspaceService.CurrentCamera
local updateInterval = 30
local heartbeatConnection = nil
local renderConnection = nil
local currentRotation = 0

-- UI Initialization [cite: 4]
if not game:GetService("CoreGui"):FindFirstChild("EspGui") then
    local gui = Instance.new("ScreenGui")
    gui.Name = "EspGui"
    gui.IgnoreGuiInset = true
    gui.Parent = game:GetService("CoreGui")
    espModule.EspGui = gui
else
    espModule.EspGui = game:GetService("CoreGui").EspGui
end

local function SafeLerp(a, b, t)
    return a + (b - a) * t
end

function espModule:CreateBox(_)
    local boxDrawings = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        BoxTop = Drawing.new("Line"),
        BoxBottom = Drawing.new("Line"),
        BoxLeft = Drawing.new("Line"),
        BoxRight = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthText = Instance.new("TextLabel"),
        HealthBarBackground = Instance.new("Frame"),
        HealthBarOutline = Instance.new("UIStroke"),
        HealthBar = Instance.new("Frame"),
        HealthBarGradient = Instance.new("UIGradient"),
        ArmorText = Instance.new("TextLabel"),
        ArmorBarBackground = Instance.new("Frame"),
        ArmorBarOutline = Instance.new("UIStroke"),
        ArmorBar = Instance.new("Frame"),
        ArmorBarGradient = Instance.new("UIGradient"),
        CurrentHealth = 100,
        TargetHealth = 100,
        FillFrame = Instance.new("Frame"),
        Gradient = Instance.new("UIGradient"),
        Stroke = Instance.new("UIStroke")
    }
    
    -- Setup Gradient Fill [cite: 4, 5]
    boxDrawings.FillFrame.Parent = self.EspGui
    boxDrawings.FillFrame.BorderSizePixel = 0
    boxDrawings.FillFrame.BackgroundTransparency = 1
    boxDrawings.FillFrame.Visible = false
    
    boxDrawings.Gradient.Parent = boxDrawings.FillFrame
    boxDrawings.Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.Config.BoxGradientColor1),
        ColorSequenceKeypoint.new(0.5, self.Config.BoxGradientColor2),
        ColorSequenceKeypoint.new(1, self.Config.BoxGradientColor1)
    })
    
    boxDrawings.Stroke.Parent = boxDrawings.FillFrame
    boxDrawings.Stroke.Thickness = 1.2
    boxDrawings.Stroke.Color = self.Config.BoxOutlineColor
    boxDrawings.Stroke.Enabled = self.Config.BoxOutlineEnabled

    -- Setup Texts [cite: 5, 6]
    boxDrawings.Name.Size = 13
    boxDrawings.Name.Center = true
    boxDrawings.Name.Outline = true
    boxDrawings.Distance.Size = 13
    boxDrawings.Distance.Center = true
    boxDrawings.Distance.Outline = true

    -- Setup Health Bar [cite: 7]
    boxDrawings.HealthBarBackground.Parent = self.EspGui
    boxDrawings.HealthBar.Parent = self.EspGui
    boxDrawings.HealthBarGradient.Parent = boxDrawings.HealthBar
    boxDrawings.HealthBarGradient.Rotation = 90
    boxDrawings.HealthBarGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.Config.HealthBarColor1),
        ColorSequenceKeypoint.new(0.5, self.Config.HealthBarColor2),
        ColorSequenceKeypoint.new(1, self.Config.HealthBarColor3)
    })

    return boxDrawings
end

function espModule:UpdateBox()
    if not self or not self.State or not self.Config then return end
    if not self.State.BoxEnabled then return end

    for _, otherPlayer in ipairs(playersService:GetPlayers()) do
        if otherPlayer ~= localPlayer and otherPlayer.Character then
            local char = otherPlayer.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")

            if root and hum and hum.Health > 0 then
                local rootPos, onScreen = currentCamera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    if not self.Caches.BoxCache[otherPlayer] then
                        self.Caches.BoxCache[otherPlayer] = self:CreateBox(otherPlayer)
                    end
                    
                    local box = self.Caches.BoxCache[otherPlayer]
                    local head = char:FindFirstChild("Head")
                    local headPos = head and head.Position + Vector3.new(0, 1, 0) or root.Position + Vector3.new(0, 3, 0)
                    local feetPos = root.Position - Vector3.new(0, 3, 0)
                    
                    local headScreen = currentCamera:WorldToViewportPoint(headPos)
                    local feetScreen = currentCamera:WorldToViewportPoint(feetPos)
                    
                    local height = math.abs(headScreen.Y - feetScreen.Y)
                    local width = height * 0.6
                    local topLeft = Vector2.new(rootPos.X - width/2, (headScreen.Y + feetScreen.Y)/2 - height/2)

                    -- Apply Gradient Box [cite: 16]
                    if self.Config.BoxGradientEnabled then
                        box.FillFrame.Position = UDim2.fromOffset(topLeft.X, topLeft.Y)
                        box.FillFrame.Size = UDim2.fromOffset(width, height)
                        box.FillFrame.BackgroundTransparency = self.Config.BoxFillTransparency
                        box.FillFrame.Visible = true
                        box.Box.Visible = false
                    else
                        box.Box.Position = topLeft
                        box.Box.Size = Vector2.new(width, height)
                        box.Box.Visible = true
                        box.FillFrame.Visible = false
                    end

                    -- Name and Distance [cite: 17]
                    box.Name.Position = Vector2.new(rootPos.X, topLeft.Y - 15)
                    box.Name.Text = otherPlayer.Name
                    box.Name.Visible = self.State.NameEnabled

                    local dist = (currentCamera.CFrame.Position - root.Position).Magnitude
                    box.Distance.Position = Vector2.new(rootPos.X, feetScreen.Y + 5)
                    box.Distance.Text = math.floor(dist) .. "m"
                    box.Distance.Visible = self.State.DistanceEnabled

                    -- Health Bar Logic [cite: 18, 19]
                    local healthPercent = hum.Health / hum.MaxHealth
                    local barX = topLeft.X - 5
                    box.HealthBarBackground.Position = UDim2.fromOffset(barX, topLeft.Y)
                    box.HealthBarBackground.Size = UDim2.fromOffset(2, height)
                    box.HealthBarBackground.Visible = self.State.HealthBarEnabled
                    
                    box.HealthBar.Position = UDim2.fromOffset(barX, topLeft.Y + (height * (1 - healthPercent)))
                    box.HealthBar.Size = UDim2.fromOffset(2, height * healthPercent)
                    box.HealthBar.Visible = self.State.HealthBarEnabled
                else
                    if self.Caches.BoxCache[otherPlayer] then
                        self.Caches.BoxCache[otherPlayer].FillFrame.Visible = false
                        self.Caches.BoxCache[otherPlayer].Name.Visible = false
                        self.Caches.BoxCache[otherPlayer].Distance.Visible = false
                    end
                end
            end
        end
    end
end

-- Run loop
runService.RenderStepped:Connect(function()
    espModule:UpdateBox()
end)

return espModule
