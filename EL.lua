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
    BoxGradientEnabled = true,
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
    BoxEnabled = true,
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

if not game:GetService("CoreGui"):FindFirstChild("EspGui") then
    local gui = Instance.new("ScreenGui")
    gui.Name = "EspGui"
    gui.IgnoreGuiInset = true
    gui.Parent = game:GetService("CoreGui")
    espModule.EspGui = gui
else
    espModule.EspGui = game:GetService("CoreGui").EspGui
end

local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("ESP Error: " .. tostring(result))
    end
    return success, result
end

function espModule:CreateBox(player)
    local boxDrawings = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthText = Instance.new("TextLabel"),
        HealthBarBackground = Instance.new("Frame"),
        HealthBar = Instance.new("Frame"),
        HealthBarGradient = Instance.new("UIGradient"),
        FillFrame = Instance.new("Frame"),
        Gradient = Instance.new("UIGradient"),
        Stroke = Instance.new("UIStroke")
    }
    
    boxDrawings.FillFrame.Parent = self.EspGui
    boxDrawings.FillFrame.BorderSizePixel = 0
    boxDrawings.FillFrame.BackgroundTransparency = 1
    boxDrawings.FillFrame.Visible = false
    
    boxDrawings.Gradient.Parent = boxDrawings.FillFrame
    boxDrawings.Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.Config.BoxGradientColor1),
        ColorSequenceKeypoint.new(1, self.Config.BoxGradientColor2)
    })
    
    boxDrawings.Stroke.Parent = boxDrawings.FillFrame
    boxDrawings.Stroke.Thickness = 1
    boxDrawings.Stroke.Color = self.Config.BoxOutlineColor
    
    boxDrawings.Name.Size = 14
    boxDrawings.Name.Center = true
    boxDrawings.Name.Outline = true
    boxDrawings.Name.Visible = false
    
    boxDrawings.Distance.Size = 14
    boxDrawings.Distance.Center = true
    boxDrawings.Distance.Outline = true
    boxDrawings.Distance.Visible = false

    boxDrawings.HealthBarBackground.Parent = self.EspGui
    boxDrawings.HealthBarBackground.BackgroundColor3 = Color3.new(0, 0, 0)
    boxDrawings.HealthBarBackground.BackgroundTransparency = 0.5
    boxDrawings.HealthBarBackground.BorderSizePixel = 0
    boxDrawings.HealthBarBackground.Visible = false

    boxDrawings.HealthBar.Parent = boxDrawings.HealthBarBackground
    boxDrawings.HealthBar.BorderSizePixel = 0
    boxDrawings.HealthBar.Visible = true

    boxDrawings.HealthBarGradient.Parent = boxDrawings.HealthBar
    boxDrawings.HealthBarGradient.Rotation = 90
    boxDrawings.HealthBarGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.Config.HealthBarColor1),
        ColorSequenceKeypoint.new(1, self.Config.HealthBarColor3)
    })

    return boxDrawings
end

function espModule:UpdateBox()
    for _, player in ipairs(playersService:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local char = player.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")

            if root and hum then
                local pos, onScreen = currentCamera:WorldToViewportPoint(root.Position)
                local distance = (currentCamera.CFrame.Position - root.Position).Magnitude

                if onScreen and distance <= self.Config.ESPDistance then
                    if not self.Caches.BoxCache[player] then
                        self.Caches.BoxCache[player] = self:CreateBox(player)
                    end
                    
                    local box = self.Caches.BoxCache[player]
                    local head = char:FindFirstChild("Head")
                    local headPos = head and head.Position + Vector3.new(0, 0.5, 0) or root.Position + Vector3.new(0, 1.5, 0)
                    local legPos = root.Position - Vector3.new(0, 3, 0)
                    
                    local headScreen = currentCamera:WorldToViewportPoint(headPos)
                    local legScreen = currentCamera:WorldToViewportPoint(legPos)
                    
                    local height = math.abs(headScreen.Y - legScreen.Y)
                    local width = height * 0.6
                    local topLeft = Vector2.new(pos.X - width/2, pos.Y - height/2)

                    if self.State.BoxEnabled then
                        if self.Config.BoxGradientEnabled then
                            box.FillFrame.Position = UDim2.fromOffset(topLeft.X, topLeft.Y)
                            box.FillFrame.Size = UDim2.fromOffset(width, height)
                            box.FillFrame.BackgroundTransparency = self.Config.BoxFillTransparency
                            box.FillFrame.Visible = true
                            box.Box.Visible = false
                        else
                            box.Box.Position = topLeft
                            box.Box.Size = Vector2.new(width, height)
                            box.Box.Color = self.Config.BoxColor
                            box.Box.Visible = true
                            box.FillFrame.Visible = false
                        end
                    end

                    if self.State.NameEnabled then
                        box.Name.Position = Vector2.new(pos.X, topLeft.Y - 15)
                        box.Name.Text = player.Name
                        box.Name.Visible = true
                    end

                    if self.State.DistanceEnabled then
                        box.Distance.Position = Vector2.new(pos.X, topLeft.Y + height + 5)
                        box.Distance.Text = "[" .. math.floor(distance) .. "m]"
                        box.Distance.Visible = true
                    end

                    if self.State.HealthBarEnabled then
                        local healthPercent = hum.Health / hum.MaxHealth
                        box.HealthBarBackground.Position = UDim2.fromOffset(topLeft.X - 6, topLeft.Y)
                        box.HealthBarBackground.Size = UDim2.fromOffset(4, height)
                        box.HealthBarBackground.Visible = true
                        
                        box.HealthBar.Position = UDim2.fromScale(0, 1 - healthPercent)
                        box.HealthBar.Size = UDim2.fromScale(1, healthPercent)
                    end
                else
                    self:ClearBox(player)
                end
            end
        end
    end
end

function espModule:ClearBox(player)
    local box = self.Caches.BoxCache[player]
    if box then
        box.FillFrame.Visible = false
        box.Box.Visible = false
        box.Name.Visible = false
        box.Distance.Visible = false
        box.HealthBarBackground.Visible = false
    end
end

function espModule:Init()
    renderConnection = runService.RenderStepped:Connect(function()
        self:UpdateBox()
    end)
end

return espModule
