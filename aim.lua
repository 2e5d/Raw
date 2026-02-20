local UIS, RS, PLRS = game:GetService("UserInputService"), game:GetService("RunService"), game:GetService("Players")
local LP, CAM = PLRS.LocalPlayer, workspace.CurrentCamera
local SET = {AF = 35, RF = 60, MIN = 0.04, MAX = 0.22, PW = 0.012, BT = 15, MH = 0.1}
local tar, con = nil, nil

local function clear()
    if con then con:Disconnect() con = nil end
    tar = nil
end

local function isVis(p)
    local r = RaycastParams.new()
    r.FilterDescendantsInstances, r.FilterType = {LP.Character, CAM}, Enum.RaycastFilterType.Exclude
    local res = workspace:Raycast(CAM.CFrame.Position, p.Position - CAM.CFrame.Position, r)
    return not res or res.Instance:IsDescendantOf(p.Parent)
end

local function getDat(p)
    if not p or not p.Parent then return nil, math.huge end
    local v, on = CAM:WorldToViewportPoint(p.Position)
    if not on then return nil, math.huge end
    return v, (Vector2.new(v.X, v.Y) - UIS:GetMouseLocation()).Magnitude
end

PLRS.PlayerRemoving:Connect(function(p) if tar and tar:IsDescendantOf(p.Character or p) then clear() end end)

RS.RenderStepped:Connect(function(dt)
    if tar and (UIS:GetMouseDelta().Magnitude > SET.BT) then clear() end
    
    if tar then
        local h = tar.Parent:FindFirstChildOfClass("Humanoid")
        if not h or h.Health <= SET.MH or not isVis(tar) then 
            clear() 
        end
    end

    if not tar then
        local bD = SET.AF
        for _, p in ipairs(PLRS:GetPlayers()) do
            local h = (p ~= LP and p.Character) and p.Character:FindFirstChild("Head")
            if h then
                local _, d = getDat(h)
                if d < bD and isVis(h) then
                    bD, tar = d, h
                    con = h.AncestryChanged:Connect(function(_, par) if not par then clear() end end)
                end
            end
        end
    end

    if tar then
        local _, d = getDat(tar)
        if d > SET.RF then return clear() end
        local a = 1 - math.pow(1 - (SET.MIN + (SET.MAX - SET.MIN) * ((1 - math.clamp(d / SET.RF, 0, 1))^2)), dt * 60)
        CAM.CFrame = CAM.CFrame:Lerp(CFrame.new(CAM.CFrame.Position, tar.Position + (tar.AssemblyLinearVelocity * SET.PW)), a)
    end
end)
