local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

if _G.ESP_Cleanup then 
    _G.ESP_Cleanup() 
end

local iconBaseUrl = "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId="

_G.ESPLibrary = {
    Settings = {
        Enabled = true,
        MaxDistance = 5000,
        MaxNameDistance = 300,
        MaxTracerDistance = 300,
        MaxHealthDistance = 300,
        MaxGlowDistance = 5000,
        MaxWeaponDistance = 300,
        MaxRingDistance = 300,
        ShowBox = true,
        BoxThickness = 1.8,
        FixedCornerRadius = 2,
        FillEnabled = true,
        BoxFillTransparency = 0.4,
        ShowGlow = true,
        GlowThickness = 20,
        GlowTransparency = 0.8,
        GlowEnabled = true,
        GlowOutlineTransparency = 0,
        GlowFillTransparency = 0.5,
        ShowSkeleton = true,
        SkeletonThickness = 1.2,
        SkeletonTransparency = 0.8,
        ShowName = true,
        NameSize = 16,
        ShowTracer = true,
        TracerThickness = 1,
        ShowHealth = true,
        ShowWeapon = true,
        WeaponIconMin = 15,
        WeaponIconMax = 40,
        WeaponIconScale = 0.2,
        WeaponTextMin = 12,
        WeaponTextMax = 30,
        WeaponTextScale = 0.15,
        WeaponTextWidth = 150,
        BottomColor = Color3.fromRGB(0, 0, 0),
        HealthHigh = Color3.fromRGB(0, 255, 180),
        HealthLow = Color3.fromRGB(255, 30, 30),
        PulseEnabled = true,
        PulseSpeed = 2.5,
        Wings = {
            Enabled = true,
            Mode = "Normal",
        },
    }
}

local ESPTable = {}
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GranitVisuals_PlayerSized"
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

local weaponIcons = {
    fallback = "8099127059",
    ["m9"] = "16029073381",
    ["shotgun"] = "16057229826",
    ["sniper"] = "15571370793",
    ["m4a1"] = "16010744953",
    ["rpg"] = "14263891084",
    ["glock"] = "15571374080",
    ["keycard"] = "680016393",
    ["ak"] = "89927802027628",
    ["ak-57"] = "89927802027628",
}

local function CreateGranitElement(className, parent, isText)
    local obj = Instance.new(className)
    obj.BackgroundColor3 = Color3.new(1, 1, 1)
    obj.BorderSizePixel = 0
    obj.Parent = parent
    local grad = Instance.new("UIGradient")
    grad.Rotation = 90
    grad.Parent = obj
    if isText then
        obj.BackgroundTransparency = 1
        obj.Font = Enum.Font.GothamBold
        obj.TextColor3 = Color3.new(1, 1, 1)
        obj.TextStrokeTransparency = 0.4
        obj.TextSize = _G.ESPLibrary.Settings.NameSize
    end
    return obj, grad
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    local obj = {
        Player = player, 
        Bones = {},
        Highlight = Instance.new("Highlight")
    }

    obj.BoxFill = Instance.new("Frame")
    obj.BoxFill.BorderSizePixel = 0
    obj.BoxFill.ZIndex = 1
    obj.BoxFill.Parent = ScreenGui
    obj.BoxCorner = Instance.new("UICorner")
    obj.BoxCorner.Parent = obj.BoxFill
    obj.BoxFillGrad = Instance.new("UIGradient")
    obj.BoxFillGrad.Rotation = 90
    obj.BoxFillGrad.Parent = obj.BoxFill
    
    obj.BoxOutline = Instance.new("UIStroke")
    obj.BoxOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    obj.BoxOutline.Parent = obj.BoxFill
    obj.BoxOutlineGrad = Instance.new("UIGradient")
    obj.BoxOutlineGrad.Rotation = 90
    obj.BoxOutlineGrad.Parent = obj.BoxOutline

    obj.GlowImage = Instance.new("ImageLabel")
    obj.GlowImage.BackgroundTransparency = 1
    obj.GlowImage.BorderSizePixel = 0
    obj.GlowImage.ZIndex = 0
    obj.GlowImage.Image = "rbxassetid://1316045217"
    obj.GlowImage.ScaleType = Enum.ScaleType.Slice
    obj.GlowImage.SliceCenter = Rect.new(10, 10, 118, 118)
    obj.GlowImage.Parent = ScreenGui

    obj.Tracer, obj.TracerGrad = CreateGranitElement("Frame", ScreenGui)
    
    obj.NameLabel = Instance.new("TextLabel")
    obj.NameLabel.BackgroundTransparency = 1
    obj.NameLabel.BorderSizePixel = 0
    obj.NameLabel.Font = Enum.Font.Gotham
    obj.NameLabel.TextStrokeTransparency = 0.4
    obj.NameLabel.TextSize = _G.ESPLibrary.Settings.NameSize
    obj.NameLabel.Parent = ScreenGui

    obj.HealthBar, obj.HealthGrad = CreateGranitElement("Frame", ScreenGui)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.new(0, 0, 0)
    stroke.Transparency = 0.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = obj.HealthBar
    obj.HealthBarStroke = stroke

    obj.WeaponIcon = Instance.new("ImageLabel")
    obj.WeaponIcon.BackgroundTransparency = 1
    obj.WeaponIcon.BorderSizePixel = 0
    obj.WeaponIcon.ScaleType = Enum.ScaleType.Fit
    obj.WeaponIcon.ImageColor3 = Color3.new(1, 1, 1)
    obj.WeaponIcon.Parent = ScreenGui

    obj.WeaponText = Instance.new("TextLabel")
    obj.WeaponText.BackgroundTransparency = 1
    obj.WeaponText.BorderSizePixel = 0
    obj.WeaponText.Font = Enum.Font.Gotham
    obj.WeaponText.TextStrokeTransparency = 0.4
    obj.WeaponText.TextXAlignment = Enum.TextXAlignment.Left
    obj.WeaponText.Parent = ScreenGui

    obj.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    obj.Highlight.Enabled = false

    for i = 1, 10 do
        local b = Instance.new("Frame")
        b.BorderSizePixel = 0
        b.Parent = ScreenGui
        local grad = Instance.new("UIGradient")
        grad.Rotation = 90
        grad.Parent = b
        obj.Bones[i] = b
    end
    ESPTable[player] = obj
end

local function DrawSolidLine(frame, startPos, endPos, thickness, gradientColor, transparency)
    local dist = (startPos - endPos).Magnitude
    frame.Visible = true
    frame.Size = UDim2.new(0, thickness, 0, dist)
    frame.Position = UDim2.new(0, (startPos.X + endPos.X)/2, 0, (startPos.Y + endPos.Y)/2)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Rotation = math.deg(math.atan2(endPos.Y - startPos.Y, endPos.X - startPos.X)) - 90
    frame.BackgroundTransparency = 1 - transparency
    
    local grad = frame:FindFirstChildOfClass("UIGradient")
    if grad and gradientColor then
        frame.BackgroundColor3 = Color3.new(1, 1, 1)
        grad.Color = gradientColor
    else
        frame.BackgroundColor3 = gradientColor and gradientColor.Keypoints[1].Value or Color3.new(1,1,1)
    end
end

local function UpdateESP()
    local s = _G.ESPLibrary.Settings
    for player, obj in pairs(ESPTable) do
        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if char and hum and hrp and hum.Health > 0 then
            local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local charSize = Vector3.new(5, 5, 5)
            local success, size = pcall(function() return char:GetExtentsSize() end)
            if success then charSize = size end
            
            local topWorld = hrp.Position + Vector3.new(0, charSize.Y / 2.0, 0)
            local bottomWorld = hrp.Position - Vector3.new(0, charSize.Y / 2.0, 0)
            
            local topPos = Camera:WorldToViewportPoint(topWorld)
            local bottomPos = Camera:WorldToViewportPoint(bottomWorld)

            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude

            if onScreen and dist < s.MaxDistance then
                local h = math.abs(topPos.Y - bottomPos.Y)
                h = math.max(h, 1)
                local w = h * 0.5
                local x, y = hrpPos.X - w/2, hrpPos.Y - h/2
                
                local topCol = player.TeamColor.Color
                local botCol = s.BottomColor
                local wave = s.PulseEnabled and ((math.sin(tick() * s.PulseSpeed) + 1) / 2) or 1
                local safeRadius = math.min(s.FixedCornerRadius, w/2)

                obj.BoxFill.Visible = s.ShowBox
                obj.BoxFill.Position = UDim2.new(0, x, 0, y)
                obj.BoxFill.Size = UDim2.new(0, w, 0, h)
                obj.BoxFill.BackgroundTransparency = 1 - (s.BoxFillTransparency * (0.8 + wave * 0.2))
                obj.BoxCorner.CornerRadius = UDim.new(0, safeRadius)
                obj.BoxOutline.Thickness = s.BoxThickness
                obj.BoxFillGrad.Color = ColorSequence.new(topCol, botCol)
                obj.BoxOutlineGrad.Color = ColorSequence.new(topCol, botCol)

                if s.ShowGlow and dist < s.MaxGlowDistance then
                    local pulseFactor = 0.8 + wave * 0.2
                    local finalTrans = s.GlowTransparency * pulseFactor

                    obj.GlowImage.Visible = true
                    obj.GlowImage.Position = UDim2.new(0, x - s.GlowThickness/2, 0, y - s.GlowThickness/2)
                    obj.GlowImage.Size = UDim2.new(0, w + s.GlowThickness, 0, h + s.GlowThickness)
                    obj.GlowImage.ImageColor3 = topCol
                    obj.GlowImage.ImageTransparency = finalTrans
                else
                    obj.GlowImage.Visible = false
                end

                if s.GlowEnabled then
                    obj.Highlight.Enabled = true
                    obj.Highlight.Parent = char
                    obj.Highlight.FillColor = topCol
                    obj.Highlight.OutlineColor = Color3.new(0, 0, 0)
                    obj.Highlight.OutlineTransparency = 0
                    obj.Highlight.FillTransparency = 1
                else
                    obj.Highlight.Enabled = false
                end

                if s.ShowName and dist < s.MaxNameDistance and h >= 10 then
                    local nameHeight = math.max(14, h * 0.12)
                    obj.NameLabel.Visible = true
                    obj.NameLabel.Size = UDim2.new(0, w, 0, nameHeight)
                    obj.NameLabel.Position = UDim2.new(0, x, 0, y - nameHeight - 4)
                    obj.NameLabel.Text = player.Name
                    obj.NameLabel.TextColor3 = topCol
                    obj.NameLabel.TextScaled = true
                else
                    obj.NameLabel.Visible = false
                end

                if s.ShowHealth and dist < s.MaxHealthDistance then
                    local hp = hum.Health / hum.MaxHealth
                    obj.HealthBar.Visible = true
                    obj.HealthBar.Position = UDim2.new(0, x - 8, 0, y + (h - (h * hp)))
                    obj.HealthBar.Size = UDim2.new(0, 2, 0, h * hp)
                    obj.HealthGrad.Color = ColorSequence.new(s.HealthHigh, s.HealthLow)
                else
                    obj.HealthBar.Visible = false
                end

                if s.ShowWeapon and dist < s.MaxWeaponDistance and h >= 10 then
                    local tool = nil
                    for _, child in ipairs(char:GetChildren()) do
                        if child:IsA("Tool") then
                            tool = child
                            break
                        end
                    end
                    
                    if tool then
                        local toolName = tool.Name
                        local toolNameLower = toolName:lower()
                        local iconId = weaponIcons.fallback
                        for keyword, asset in pairs(weaponIcons) do
                            if keyword ~= "fallback" and toolNameLower:find(keyword) then
                                iconId = asset
                                break
                            end
                        end
                        
                        local iconSize = math.max(s.WeaponIconMin, math.min(s.WeaponIconMax, h * s.WeaponIconScale))
                        local textHeight = math.max(s.WeaponTextMin, math.min(s.WeaponTextMax, h * s.WeaponTextScale))
                        local textWidth = s.WeaponTextWidth
                        
                        obj.WeaponIcon.Visible = true
                        obj.WeaponIcon.Size = UDim2.new(0, iconSize, 0, iconSize)
                        obj.WeaponIcon.Position = UDim2.new(0, x, 0, y + h + 2)
                        obj.WeaponIcon.Image = iconBaseUrl .. iconId
                        
                        local textYOffset = (iconSize - textHeight) / 2
                        obj.WeaponText.Visible = true
                        obj.WeaponText.Size = UDim2.new(0, textWidth, 0, textHeight)
                        obj.WeaponText.Position = UDim2.new(0, x + iconSize + 5, 0, y + h + 2 + textYOffset)
                        obj.WeaponText.Text = toolName
                        obj.WeaponText.TextColor3 = topCol
                        obj.WeaponText.TextScaled = true
                    else
                        obj.WeaponIcon.Visible = false
                        obj.WeaponText.Visible = false
                    end
                else
                    obj.WeaponIcon.Visible = false
                    obj.WeaponText.Visible = false
                end

                if s.ShowTracer and dist < s.MaxTracerDistance then
                    DrawSolidLine(obj.Tracer, Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y), Vector2.new(hrpPos.X, hrpPos.Y + h/2), s.TracerThickness, ColorSequence.new(topCol, botCol), 0.6)
                else
                    obj.Tracer.Visible = false
                end

                local isR15 = char:FindFirstChild("UpperTorso") ~= nil
                local joints = isR15 and {
                    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}
                } or {
                    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
                }

                for i, pair in ipairs(joints) do
                    local bone = obj.Bones[i]
                    if s.ShowSkeleton and pair and char:FindFirstChild(pair[1]) and char:FindFirstChild(pair[2]) then
                        local partA = char[pair[1]]
                        local partB = char[pair[2]]
                        
                        local posA = partA.Position
                        local posB = partB.Position
                        local dir = (posB - posA).Unit
                        
                        local offsetA = dir * (partA.Size.Magnitude * 0.5)
                        local offsetB = -dir * (partB.Size.Magnitude * 0.5)
                        
                        local startWorld = posA + offsetA
                        local endWorld = posB + offsetB
                        
                        local p1, v1 = Camera:WorldToViewportPoint(startWorld)
                        local p2, v2 = Camera:WorldToViewportPoint(endWorld)
                        
                        if v1 and v2 then
                            DrawSolidLine(bone, Vector2.new(p1.X, p1.Y), Vector2.new(p2.X, p2.Y), s.SkeletonThickness, ColorSequence.new(topCol, botCol), s.SkeletonTransparency)
                        else
                            bone.Visible = false
                        end
                    else
                        bone.Visible = false
                    end
                end
            else
                obj.BoxFill.Visible = false
                obj.GlowImage.Visible = false
                obj.Tracer.Visible = false
                obj.Highlight.Enabled = false
                obj.NameLabel.Visible = false
                obj.HealthBar.Visible = false
                obj.WeaponIcon.Visible = false
                obj.WeaponText.Visible = false
                for _, b in pairs(obj.Bones) do b.Visible = false end
            end
        else
            obj.BoxFill.Visible = false
            obj.GlowImage.Visible = false
            obj.Tracer.Visible = false
            obj.Highlight.Enabled = false
            obj.NameLabel.Visible = false
            obj.HealthBar.Visible = false
            obj.WeaponIcon.Visible = false
            obj.WeaponText.Visible = false
            for _, b in pairs(obj.Bones) do b.Visible = false end
        end
    end
end

local RingTable = {}

local function CreateRingForPlayer(player)
    if player == LocalPlayer then return end
    if RingTable[player] then
        RingTable[player]:Destroy()
        RingTable[player] = nil
    end

    local success, ring = pcall(function()
        local part = Instance.new("Part")
        part.Size = Vector3.new(6, 0.8, 6)
        part.Anchored = true
        part.CanCollide = false
        part.Material = Enum.Material.Neon
        part.BrickColor = player.TeamColor
        part.Parent = Workspace

        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.Torus
        mesh.Scale = Vector3.new(1, 0.3, 1)
        mesh.Parent = part

        return part
    end)

    if success then
        RingTable[player] = ring
        return
    end

    local model = Instance.new("Model")
    model.Name = "Ring_" .. player.Name
    model.Parent = Workspace

    local center = Instance.new("Part")
    center.Size = Vector3.new(0.1, 0.1, 0.1)
    center.Transparency = 1
    center.Anchored = true
    center.CanCollide = false
    center.Parent = model

    local numSegments = 36
    local radius = 3.0
    local sphereSize = 0.5

    for i = 1, numSegments do
        local sphere = Instance.new("Part")
        sphere.Size = Vector3.new(sphereSize, sphereSize, sphereSize)
        sphere.Shape = Enum.PartType.Ball
        sphere.Anchored = true
        sphere.CanCollide = false
        sphere.Material = Enum.Material.Neon
        sphere.BrickColor = player.TeamColor
        sphere.Parent = model

        local angle = (i / numSegments) * math.pi * 2
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        sphere.Position = Vector3.new(x, 0, z)
    end

    model.PrimaryPart = center
    RingTable[player] = model
end

local function UpdateRings()
    local s = _G.ESPLibrary.Settings
    for player, ring in pairs(RingTable) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
            if dist <= s.MaxRingDistance then
                local amplitude = 3
                local speed = 2
                local offset = math.sin(tick() * speed) * amplitude

                if ring:IsA("Model") then
                    ring:SetPrimaryPartCFrame(CFrame.new(hrp.Position + Vector3.new(0, offset, 0)))
                else
                    ring.Position = hrp.Position + Vector3.new(0, offset, 0)
                end

                if ring:IsA("BasePart") then
                    ring.BrickColor = player.TeamColor
                elseif ring:IsA("Model") then
                    for _, part in ipairs(ring:GetChildren()) do
                        if part:IsA("BasePart") and part.Transparency < 1 then
                            part.BrickColor = player.TeamColor
                        end
                    end
                end

                ring.Parent = Workspace
            else
                ring.Parent = nil
            end
        else
            ring.Parent = nil
        end
    end
end

Players.PlayerAdded:Connect(CreateRingForPlayer)
Players.PlayerRemoving:Connect(function(player)
    if RingTable[player] then
        RingTable[player]:Destroy()
        RingTable[player] = nil
    end
end)
for _, player in pairs(Players:GetPlayers()) do
    CreateRingForPlayer(player)
end

local LocalVisuals = {
    LeftWing = nil,
    RightWing = nil,
    HeadRing = nil,
}

local function CreateWingModel(isLeft)
    local model = Instance.new("Model")
    model.Name = isLeft and "LeftWing" or "RightWing"
    model.Parent = Workspace

    local root = Instance.new("Part")
    root.Size = Vector3.new(0.1, 0.1, 0.1)
    root.Transparency = 1
    root.Anchored = true
    root.CanCollide = false
    root.Parent = model
    model.PrimaryPart = root

    local spine = Instance.new("Part")
    spine.Size = Vector3.new(1, 0.8, 4)
    spine.Shape = Enum.PartType.Cylinder
    spine.Anchored = true
    spine.CanCollide = false
    spine.Material = Enum.Material.Neon
    spine.BrickColor = LocalPlayer.TeamColor
    spine.Parent = model
    spine.CFrame = root.CFrame * CFrame.new(0, 0, -2) * CFrame.Angles(math.rad(90), 0, 0)

    local numFeathers = 5
    for i = 1, numFeathers do
        local feather = Instance.new("Part")
        local sizeZ = 2.5 - i * 0.3
        feather.Size = Vector3.new(1.2, 0.2, sizeZ)
        feather.Anchored = true
        feather.CanCollide = false
        feather.Material = Enum.Material.Neon
        feather.BrickColor = LocalPlayer.TeamColor
        feather.Parent = model
        local wedge = Instance.new("SpecialMesh")
        wedge.MeshType = Enum.MeshType.Wedge
        wedge.Parent = feather

        local offsetX = (isLeft and 1 or -1) * (0.5 + i * 0.2)
        local offsetY = 0.2 * i
        local offsetZ = -1.5 - i * 0.4
        local yaw = isLeft and -20 or 20
        local pitch = 10 + i * 5
        feather.CFrame = root.CFrame * CFrame.new(offsetX, offsetY, offsetZ) * CFrame.Angles(math.rad(pitch), math.rad(yaw), 0)
    end

    return model
end

local function CreateWings()
    if LocalVisuals.LeftWing then LocalVisuals.LeftWing:Destroy() end
    if LocalVisuals.RightWing then LocalVisuals.RightWing:Destroy() end
    LocalVisuals.LeftWing = CreateWingModel(true)
    LocalVisuals.RightWing = CreateWingModel(false)
end

local function CreateHeadRing()
    if LocalVisuals.HeadRing then
        LocalVisuals.HeadRing:Destroy()
        LocalVisuals.HeadRing = nil
    end

    local success, ring = pcall(function()
        local part = Instance.new("Part")
        part.Size = Vector3.new(2.5, 0.4, 2.5)
        part.Anchored = true
        part.CanCollide = false
        part.Material = Enum.Material.Neon
        part.BrickColor = LocalPlayer.TeamColor
        part.Parent = Workspace

        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.Torus
        mesh.Scale = Vector3.new(1, 0.3, 1)
        mesh.Parent = part

        return part
    end)

    if success then
        LocalVisuals.HeadRing = ring
        return
    end

    local model = Instance.new("Model")
    model.Name = "HeadRing"
    model.Parent = Workspace

    local pivot = Instance.new("Part")
    pivot.Size = Vector3.new(0.1, 0.1, 0.1)
    pivot.Transparency = 1
    pivot.Anchored = true
    pivot.CanCollide = false
    pivot.Parent = model

    local numSpheres = 16
    local radius = 1.2
    local sphereSize = 0.3

    for i = 1, numSpheres do
        local sphere = Instance.new("Part")
        sphere.Size = Vector3.new(sphereSize, sphereSize, sphereSize)
        sphere.Shape = Enum.PartType.Ball
        sphere.Anchored = true
        sphere.CanCollide = false
        sphere.Material = Enum.Material.Neon
        sphere.BrickColor = LocalPlayer.TeamColor
        sphere.Parent = model

        local angle = (i / numSpheres) * math.pi * 2
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        sphere.Position = Vector3.new(x, 0, z)
    end

    model.PrimaryPart = pivot
    LocalVisuals.HeadRing = model
end

local function UpdateLocalVisuals()
    local s = _G.ESPLibrary.Settings
    if not s.Wings.Enabled then
        if LocalVisuals.LeftWing then LocalVisuals.LeftWing.Parent = nil end
        if LocalVisuals.RightWing then LocalVisuals.RightWing.Parent = nil end
        if LocalVisuals.HeadRing then LocalVisuals.HeadRing.Parent = nil end
        return
    end

    local char = LocalPlayer.Character
    if not char then
        if LocalVisuals.LeftWing then LocalVisuals.LeftWing.Parent = nil end
        if LocalVisuals.RightWing then LocalVisuals.RightWing.Parent = nil end
        if LocalVisuals.HeadRing then LocalVisuals.HeadRing.Parent = nil end
        return
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not hrp or not head then
        if LocalVisuals.LeftWing then LocalVisuals.LeftWing.Parent = nil end
        if LocalVisuals.RightWing then LocalVisuals.RightWing.Parent = nil end
        if LocalVisuals.HeadRing then LocalVisuals.HeadRing.Parent = nil end
        return
    end

    if not LocalVisuals.LeftWing or not LocalVisuals.RightWing then CreateWings() end
    if not LocalVisuals.HeadRing then CreateHeadRing() end

    LocalVisuals.LeftWing.Parent = Workspace
    LocalVisuals.RightWing.Parent = Workspace
    LocalVisuals.HeadRing.Parent = Workspace

    local teamColor = LocalPlayer.TeamColor

    local leftOffset, rightOffset
    if s.Wings.Mode == "Air" then
        leftOffset = CFrame.new(1.8, 2.0, 2) * CFrame.Angles(2, math.rad(-20), math.rad(55))
        rightOffset = CFrame.new(-1.8, 2.0, 2) * CFrame.Angles(2, math.rad(20), math.rad(-55))
    else
        leftOffset = CFrame.new(0.2, -1.4, 1.5) * CFrame.Angles(math.rad(60), math.rad(-15), math.rad(25))
        rightOffset = CFrame.new(-0.3, -1.4, 1.5) * CFrame.Angles(math.rad(60), math.rad(15), math.rad(-20))
    end

    if LocalVisuals.LeftWing and LocalVisuals.LeftWing.PrimaryPart then
        LocalVisuals.LeftWing:SetPrimaryPartCFrame(hrp.CFrame * leftOffset)
        for _, part in ipairs(LocalVisuals.LeftWing:GetChildren()) do
            if part:IsA("BasePart") and part.Transparency < 1 then
                part.BrickColor = teamColor
            end
        end
    end

    if LocalVisuals.RightWing and LocalVisuals.RightWing.PrimaryPart then
        LocalVisuals.RightWing:SetPrimaryPartCFrame(hrp.CFrame * rightOffset)
        for _, part in ipairs(LocalVisuals.RightWing:GetChildren()) do
            if part:IsA("BasePart") and part.Transparency < 1 then
                part.BrickColor = teamColor
            end
        end
    end

    local headOffset = 0.5
    local amplitude = 0.3
    local speed = 3
    local osc = math.sin(tick() * speed) * amplitude
    local headPos = head.Position + Vector3.new(0, head.Size.Y/2 + headOffset + osc, 0)

    if LocalVisuals.HeadRing:IsA("Model") then
        LocalVisuals.HeadRing:SetPrimaryPartCFrame(CFrame.new(headPos))
        for _, part in ipairs(LocalVisuals.HeadRing:GetChildren()) do
            if part:IsA("BasePart") and part.Transparency < 1 then
                part.BrickColor = teamColor
            end
        end
    elseif LocalVisuals.HeadRing:IsA("BasePart") then
        LocalVisuals.HeadRing.Position = headPos
        LocalVisuals.HeadRing.BrickColor = teamColor
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    if LocalVisuals.LeftWing then LocalVisuals.LeftWing:Destroy() end
    if LocalVisuals.RightWing then LocalVisuals.RightWing:Destroy() end
    if LocalVisuals.HeadRing then LocalVisuals.HeadRing:Destroy() end
    LocalVisuals.LeftWing = nil
    LocalVisuals.RightWing = nil
    LocalVisuals.HeadRing = nil
end)

RunService.RenderStepped:Connect(UpdateLocalVisuals)

RunService.RenderStepped:Connect(UpdateESP)
Players.PlayerAdded:Connect(CreateESP)
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end

RunService.RenderStepped:Connect(UpdateRings)

_G.ESP_Cleanup = function()
    ScreenGui:Destroy()
    for _, obj in pairs(ESPTable) do
        if obj.Highlight then obj.Highlight:Destroy() end
    end
    table.clear(ESPTable)

    for _, ring in pairs(RingTable) do
        ring:Destroy()
    end
    table.clear(RingTable)

    if LocalVisuals.LeftWing then LocalVisuals.LeftWing:Destroy() end
    if LocalVisuals.RightWing then LocalVisuals.RightWing:Destroy() end
    if LocalVisuals.HeadRing then LocalVisuals.HeadRing:Destroy() end
end

return _G.ESPLibrary
