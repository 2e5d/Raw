local ESP = {
Enabled = true,
Boxes = true,
Boxes3D = true,
Skeletons = true,
Names = true,
Tools = true,
Tracers = true,
HealthBar = true,
Glow = true,
Wings = true,
Hats = true,
TeamCheck = false,
Theme = {
Main = Color3.fromRGB(160, 32, 240),
Glow = Color3.fromRGB(190, 70, 255),
Outline = Color3.new(0, 0, 0),
Text = Color3.new(1, 1, 1)
}
}

local players = game:GetService("Players")
local runService = game:GetService("RunService")
local coreGui = game:GetService("CoreGui")
local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera

local boneStructure = {
R15 = {
{"UpperTorso", "Head"}, {"UpperTorso", "LowerTorso"},
{"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
{"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
{"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
{"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
},
R6 = {
{start = "Torso", ["end"] = "Head"},
{start = "Torso", mid = "Left Arm", ["end"] = "Left Arm"},
{start = "Torso", mid = "Right Arm", ["end"] = "Right Arm"},
{start = "Torso", mid = "Left Leg", ["end"] = "Left Leg"},
{start = "Torso", mid = "Right Leg", ["end"] = "Right Leg"}
}
}

local function randName()
local len = math.random(10, 20)
local arr = {}
for i = 1, len do arr[i] = string.char(math.random(65, 90)) end
return table.concat(arr)
end

local guiName = randName()
local uiParent = coreGui:FindFirstChild("RobloxGui") or coreGui
local existing = uiParent:FindFirstChild(guiName)
if existing then existing:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = guiName
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = uiParent

local function createCont(z)
local f = Instance.new("Frame")
f.BackgroundTransparency = 1
f.Size = UDim2.fromScale(1, 1)
f.ZIndex = z
f.Parent = screenGui
return f
end

local glowCont = createCont(1)
local outCont = createCont(2)
local inCont = createCont(3)

local glowFrames, blackLines, purpleLines, nameLbls, toolLbls = {}, {}, {}, {}, {}

local function createL(color, parent, list)
local l = Instance.new("Frame")
l.BackgroundColor3 = color
l.BorderSizePixel = 0
l.AnchorPoint = Vector2.new(0.5, 0.5)
l.Visible = false
l.Parent = parent
table.insert(list, l)
return l
end

local function createGlow(parent, list)
local container = Instance.new("Frame")
container.BackgroundTransparency = 1
container.Visible = false
container.Parent = parent
local segs = {}
for i = 1, 8 do
local seg = Instance.new("Frame")
seg.BackgroundColor3 = ESP.Theme.Glow
seg.BorderSizePixel = 0
seg.Parent = container
local grad = Instance.new("UIGradient")
grad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.45), NumberSequenceKeypoint.new(1, 1)})
if i == 1 then seg.AnchorPoint, grad.Rotation = Vector2.new(0.5, 1), -90
elseif i == 2 then seg.AnchorPoint, grad.Rotation = Vector2.new(0.5, 0), 90
elseif i == 3 then seg.AnchorPoint, grad.Rotation = Vector2.new(1, 0.5), 180
elseif i == 4 then seg.AnchorPoint, grad.Rotation = Vector2.new(0, 0.5), 0
elseif i == 5 then seg.AnchorPoint, grad.Rotation = Vector2.new(1, 1), -135
elseif i == 6 then seg.AnchorPoint, grad.Rotation = Vector2.new(0, 1), -45
elseif i == 7 then seg.AnchorPoint, grad.Rotation = Vector2.new(1, 0), 135
elseif i == 8 then seg.AnchorPoint, grad.Rotation = Vector2.new(0, 0), 45 end
grad.Parent = seg
segs[i] = seg
end
local entry = {Main = container, Segs = segs}
table.insert(list, entry)
return entry
end

local function createLab(parent, list)
local lbl = Instance.new("TextLabel")
lbl.BackgroundTransparency = 1
lbl.Size = UDim2.fromOffset(200, 20)
lbl.AnchorPoint = Vector2.new(0.5, 0)
lbl.Font = Enum.Font.GothamBold
lbl.TextSize = 12
lbl.TextColor3 = ESP.Theme.Text
lbl.TextStrokeTransparency = 0
lbl.TextStrokeColor3 = ESP.Theme.Outline
lbl.Visible = false
lbl.Parent = parent
table.insert(list, lbl)
return lbl
end

-- Pool generation
for i = 1, 5000 do
createL(ESP.Theme.Outline, outCont, blackLines)
createL(ESP.Theme.Main, inCont, purpleLines)
end
for i = 1, 100 do
createGlow(glowCont, glowFrames)
createLab(inCont, nameLbls)
createLab(inCont, toolLbls)
end

local function drawSeg(p1, p2, obj, baseThickness, colorOverride)
local dist = (p1 - p2).Magnitude
local center = (p1 + p2) / 2
obj.Size = UDim2.fromOffset(dist, baseThickness)
obj.Position = UDim2.fromOffset(center.X, center.Y)
obj.Rotation = math.deg(math.atan2(p2.Y - p1.Y, p2.X - p1.X))
if colorOverride then obj.BackgroundColor3 = colorOverride end
obj.Visible = true
end

local function getBox(char)
local min, max
for _, part in ipairs(char:GetChildren()) do
if part:IsA("BasePart") then
local cf, sz = part.CFrame, part.Size
local p1 = (cf - sz * 0.5).Position
local p2 = (cf + sz * 0.5).Position
if not min then
min, max = p1, p2
else
min = Vector3.new(math.min(min.X, p1.X, p2.X), math.min(min.Y, p1.Y, p2.Y), math.min(min.Z, p1.Z, p2.Z))
max = Vector3.new(math.max(max.X, p1.X, p2.X), math.max(max.Y, p1.Y, p2.Y), math.max(max.Z, p1.Z, p2.Z))
end
end
end
if not min then return nil end
return CFrame.new((min + max) * 0.5), max - min
end

local function draw3DBox(cf, size, lineIdx, scale)
local vertices = {
Vector3.new(-1,-1,-1), Vector3.new(1,-1,-1), Vector3.new(1,1,-1), Vector3.new(-1,1,-1),
Vector3.new(-1,-1,1), Vector3.new(1,-1,1), Vector3.new(1,1,1), Vector3.new(-1,1,1)
}
local screenPoints = {}
for i = 1, 8 do
local worldPos = (cf * CFrame.new(size * 0.5 * vertices[i])).Position
local s, on = camera:WorldToViewportPoint(worldPos)
screenPoints[i] = {p = Vector2.new(s.X, s.Y), on = on}
end
local connections = {
{1,2}, {2,3}, {3,4}, {4,1}, {5,6}, {6,7}, {7,8}, {8,5}, {1,5}, {2,6}, {3,7}, {4,8}
}
for _, edge in ipairs(connections) do
local p1, p2 = screenPoints[edge[1]], screenPoints[edge[2]]
if (p1.on or p2.on) and blackLines[lineIdx] then
drawSeg(p1.p, p2.p, blackLines[lineIdx], 3 * scale, ESP.Theme.Outline)
drawSeg(p1.p, p2.p, purpleLines[lineIdx], 1 * scale, ESP.Theme.Main)
lineIdx = lineIdx + 1
end
end
return lineIdx
end

ESP.Connection = runService.RenderStepped:Connect(function()
local lineIdx, nameIdx, glowIdx = 1, 1, 1
if not ESP.Enabled then
for _, l in ipairs(blackLines) do l.Visible = false end
for _, l in ipairs(purpleLines) do l.Visible = false end
return
end

local vSize = camera.ViewportSize
local screenCenter = Vector2.new(vSize.X / 2, vSize.Y)

for _, plr in ipairs(players:GetPlayers()) do
    local char = plr.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local torso = char:FindFirstChild("HumanoidRootPart")
        local tPos, visible = camera:WorldToViewportPoint(torso.Position)
        local dist = (camera.CFrame.Position - torso.Position).Magnitude
        local scale = math.clamp(50 / dist, 0.15, 1)

        if visible then
            if ESP.TeamCheck and plr.Team == localPlayer.Team then continue end
            
            -- Skeleton Logic
            if ESP.Skeletons then
                local isR15 = hum.RigType == Enum.HumanoidRigType.R15
                local struct = isR15 and boneStructure.R15 or boneStructure.R6
                for _, joint in ipairs(struct) do
                    local p1 = char:FindFirstChild(joint[1] or joint.start)
                    local p2 = char:FindFirstChild(joint[2] or joint["end"])
                    if p1 and p2 then
                        local s1, on1 = camera:WorldToViewportPoint(p1.Position)
                        local s2, on2 = camera:WorldToViewportPoint(p2.Position)
                        if (on1 or on2) and blackLines[lineIdx] then
                            drawSeg(Vector2.new(s1.X, s1.Y), Vector2.new(s2.X, s2.Y), blackLines[lineIdx], 3 * scale, ESP.Theme.Outline)
                            drawSeg(Vector2.new(s1.X, s1.Y), Vector2.new(s2.X, s2.Y), purpleLines[lineIdx], 1 * scale, ESP.Theme.Main)
                            lineIdx = lineIdx + 1
                        end
                    end
                end
            end

            -- Box Logic
            if plr ~= localPlayer then
                local cf, size = getBox(char)
                if cf and size then
                    if ESP.Boxes3D then
                        lineIdx = draw3DBox(cf, size, lineIdx, scale)
                    end

                    -- Screen corners for 2D UI
                    local vertices = {Vector3.new(-1,-1,-1), Vector3.new(1,1,1)}
                    local c1, _ = camera:WorldToViewportPoint((cf * CFrame.new(size * 0.5 * vertices[1])).Position)
                    local c2, _ = camera:WorldToViewportPoint((cf * CFrame.new(size * 0.5 * vertices[2])).Position)
                    local minX, minY = math.min(c1.X, c2.X), math.min(c1.Y, c2.Y)
                    local maxX, maxY = math.max(c1.X, c2.X), math.max(c1.Y, c2.Y)

                    if ESP.Glow and glowFrames[glowIdx] then
                        local e = glowFrames[glowIdx]
                        e.Main.Position, e.Main.Size = UDim2.fromOffset(minX, minY), UDim2.fromOffset(maxX - minX, maxY - minY)
                        e.Main.Visible, glowIdx = true, glowIdx + 1
                    end

                    if ESP.Boxes then
                        local pts = {Vector2.new(minX,minY), Vector2.new(maxX,minY), Vector2.new(maxX,maxY), Vector2.new(minX,maxY)}
                        for i = 1, 4 do
                            drawSeg(pts[i], pts[i % 4 + 1], blackLines[lineIdx], 4 * scale, ESP.Theme.Outline)
                            drawSeg(pts[i], pts[i % 4 + 1], purpleLines[lineIdx], 2 * scale, ESP.Theme.Main)
                            lineIdx = lineIdx + 1
                        end
                    end

                    if ESP.Tracers then
                        drawSeg(screenCenter, Vector2.new((minX + maxX)/2, maxY), blackLines[lineIdx], 3 * scale, ESP.Theme.Outline)
                        drawSeg(screenCenter, Vector2.new((minX + maxX)/2, maxY), purpleLines[lineIdx], 1 * scale, ESP.Theme.Main)
                        lineIdx = lineIdx + 1
                    end

                    if ESP.HealthBar then
                        local hp = hum.Health / hum.MaxHealth
                        local b1, b2 = Vector2.new(minX - 5, minY), Vector2.new(minX - 5, maxY)
                        drawSeg(b1, b2, blackLines[lineIdx], 4 * scale, ESP.Theme.Outline)
                        drawSeg(b2, b2:Lerp(b1, hp), purpleLines[lineIdx], 2 * scale, Color3.new(1,0,0):Lerp(Color3.new(0,1,0), hp))
                        lineIdx = lineIdx + 1
                    end

                    if ESP.Names and nameLbls[nameIdx] then
                        nameLbls[nameIdx].Text = plr.Name
                        nameLbls[nameIdx].Position = UDim2.fromOffset((minX + maxX)/2, minY - 15)
                        nameLbls[nameIdx].Visible, nameIdx = true, nameIdx + 1
                    end
                end
            end
        end
    end
end

-- Cleanup pool
for i = lineIdx, #blackLines do blackLines[i].Visible = false purpleLines[i].Visible = false end
for i = nameIdx, #nameLbls do nameLbls[i].Visible = false toolLbls[i].Visible = false end
for i = glowIdx, #glowFrames do glowFrames[i].Main.Visible = false end


end)

return ESP
