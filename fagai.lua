--[[
    Fluid UI Library - Full Modular Port
    Based on Fluid.txt (Original by @uniquadev)
    
    Usage:
    local Fluid = loadstring(game:HttpGet("..."))()
    local Window = Fluid.CreateWindow("Project Name")
]]

local Fluid = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Theme State
Fluid.Theme = {
    MainColor = Color3.fromRGB(25, 25, 25),
    AccentColor = Color3.fromRGB(0, 170, 255),
    SecondaryColor = Color3.fromRGB(35, 35, 35),
    Font = Enum.Font.GothamMedium,
    PlaceholderColor = Color3.fromRGB(150, 150, 150)
}

-- Notification System (Exact port from Fluid.txt logic)
function Fluid.Notify(title, desc, duration)
    local screen = PlayerGui:FindFirstChild("FluidNotify") or Instance.new("ScreenGui", PlayerGui)
    screen.Name = "FluidNotify"
    
    local cl = Instance.new("Frame")
    cl.Name = "Notification"
    cl.Parent = screen
    cl.BackgroundColor3 = Fluid.Theme.MainColor
    cl.BorderSizePixel = 0
    cl.Position = UDim2.new(1, 10, 1, -100)
    cl.Size = UDim2.new(0, 250, 0, 80)
    
    local corner = Instance.new("UICorner", cl)
    corner.CornerRadius = UDim.new(0, 8)
    
    local t = Instance.new("TextLabel", cl)
    t.Text = title
    t.Size = UDim2.new(1, -20, 0, 30)
    t.Position = UDim2.new(0, 10, 0, 5)
    t.BackgroundTransparency = 1
    t.TextColor3 = Fluid.Theme.AccentColor
    t.Font = Fluid.Theme.Font
    t.TextSize = 16
    t.TextXAlignment = "Left"
    
    local d = Instance.new("TextLabel", cl)
    d.Text = desc
    d.Size = UDim2.new(1, -20, 0, 40)
    d.Position = UDim2.new(0, 10, 0, 30)
    d.BackgroundTransparency = 1
    d.TextColor3 = Color3.fromRGB(255, 255, 255)
    d.Font = Fluid.Theme.Font
    d.TextSize = 12
    d.TextWrapped = true
    d.TextXAlignment = "Left"
    d.TextYAlignment = "Top"

    TweenService:Create(cl, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -260, 1, -100)}):Play()
    
    task.delay(duration or 3, function()
        local ou = TweenService:Create(cl, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 10, 1, -100)})
        ou:Play()
        ou.Completed:Connect(function() cl:Destroy() end)
    end)
end

function Fluid.CreateWindow(windowTitle)
    -- Main ScreenGui
    local FluidUI = Instance.new("ScreenGui")
    FluidUI.Name = "FluidUI"
    FluidUI.Parent = PlayerGui
    FluidUI.IgnoreGuiInset = true
    FluidUI.ResetOnSpawn = false

    -- Loading Screen (From Fluid.txt sequence)
    local Loading = Instance.new("Frame")
    Loading.Name = "Loading"
    Loading.Parent = FluidUI
    Loading.Size = UDim2.new(1, 0, 1, 0)
    Loading.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Loading.ZIndex = 100

    local LoadingText = Instance.new("TextLabel", Loading)
    LoadingText.Text = "Initializing Fluid..."
    LoadingText.Size = UDim2.new(1, 0, 1, 0)
    LoadingText.BackgroundTransparency = 1
    LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadingText.Font = Enum.Font.GothamBold
    LoadingText.TextSize = 24

    -- Actual Menu
    local Main = Instance.new("Frame")
    Main.Name = "Menu"
    Main.Parent = FluidUI
    Main.Size = UDim2.new(0, 550, 0, 350)
    Main.Position = UDim2.new(0.5, -275, 0.5, -175)
    Main.BackgroundColor3 = Fluid.Theme.MainColor
    Main.BorderSizePixel = 0
    Main.Visible = false
    Main.ClipsDescendants = true
    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

    -- Glow (Shadow) Effect
    local Glow = Instance.new("ImageLabel", Main)
    Glow.Name = "Glow"
    Glow.BackgroundTransparency = 1
    Glow.Position = UDim2.new(0, -15, 0, -15)
    Glow.Size = UDim2.new(1, 30, 1, 30)
    Glow.Image = "rbxassetid://5028857084"
    Glow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Glow.ScaleType = Enum.ScaleType.Slice
    Glow.SliceCenter = Rect.new(24, 24, 120, 120)

    -- Sidebar
    local SideBar = Instance.new("Frame", Main)
    SideBar.Name = "SideBar"
    SideBar.Size = UDim2.new(0, 160, 1, 0)
    SideBar.BackgroundColor3 = Fluid.Theme.SecondaryColor
    SideBar.BorderSizePixel = 0
    Instance.new("UICorner", SideBar).CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel", SideBar)
    Title.Text = windowTitle or "FLUID"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Fluid.Theme.AccentColor
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18

    local TabHolder = Instance.new("ScrollingFrame", SideBar)
    TabHolder.Position = UDim2.new(0, 0, 0, 60)
    TabHolder.Size = UDim2.new(1, 0, 1, -70)
    TabHolder.BackgroundTransparency = 1
    TabHolder.ScrollBarThickness = 0
    local TabList = Instance.new("UIListLayout", TabHolder)
    TabList.Padding = UDim.new(0, 5)
    TabList.HorizontalAlignment = "Center"

    local Container = Instance.new("Frame", Main)
    Container.Name = "Container"
    Container.Position = UDim2.new(0, 170, 0, 10)
    Container.Size = UDim2.new(1, -180, 1, -20)
    Container.BackgroundTransparency = 1

    -- Dragging Logic
    local function setupDrag()
        local dragging, dragInput, dragStart, startPos
        Main.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = Main.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
    end
    setupDrag()

    -- Start Sequence (Loading Simulation from Fluid.txt)
    task.spawn(function()
        task.wait(1)
        LoadingText.Text = "Loading Themes..."
        task.wait(0.5)
        LoadingText.Text = "Welcome, " .. Player.Name
        task.wait(0.5)
        TweenService:Create(Loading, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(LoadingText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        task.wait(0.5)
        Loading:Destroy()
        Main.Visible = true
        local targetSize = UDim2.new(0, 550, 0, 350)
        Main.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Size = targetSize}):Play()
    end)

    local Window = {}

    function Window.AddTab(name)
        local TabButton = Instance.new("TextButton", TabHolder)
        TabButton.Size = UDim2.new(0.9, 0, 0, 35)
        TabButton.BackgroundColor3 = Fluid.Theme.MainColor
        TabButton.Text = name
        TabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        TabButton.Font = Fluid.Theme.Font
        TabButton.TextSize = 14
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)

        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 8)

        TabButton.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabHolder:GetChildren()) do
                if v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.3), {BackgroundColor3 = Fluid.Theme.MainColor, TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
                end
            end
            Page.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.3), {BackgroundColor3 = Fluid.Theme.AccentColor, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end)

        local Tab = {}

        -- Add Button Component
        function Tab.AddButton(text, callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.Size = UDim2.new(1, -10, 0, 40)
            Btn.BackgroundColor3 = Fluid.Theme.SecondaryColor
            Btn.Text = "  " .. text
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.Font = Fluid.Theme.Font
            Btn.TextSize = 14
            Btn.TextXAlignment = "Left"
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
            
            Btn.MouseButton1Click:Connect(callback)
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end

        -- Add Toggle Component
        function Tab.AddToggle(text, default, callback)
            local state = default or false
            local Tgl = Instance.new("TextButton", Page)
            Tgl.Size = UDim2.new(1, -10, 0, 40)
            Tgl.BackgroundColor3 = Fluid.Theme.SecondaryColor
            Tgl.Text = "  " .. text
            Tgl.TextColor3 = Color3.fromRGB(255, 255, 255)
            Tgl.Font = Fluid.Theme.Font
            Tgl.TextSize = 14
            Tgl.TextXAlignment = "Left"
            Instance.new("UICorner", Tgl).CornerRadius = UDim.new(0, 6)

            local Box = Instance.new("Frame", Tgl)
            Box.Size = UDim2.new(0, 36, 0, 18)
            Box.Position = UDim2.new(1, -45, 0.5, -9)
            Box.BackgroundColor3 = state and Fluid.Theme.AccentColor or Color3.fromRGB(50, 50, 50)
            Instance.new("UICorner", Box).CornerRadius = UDim.new(1, 0)

            local Dot = Instance.new("Frame", Box)
            Dot.Size = UDim2.new(0, 14, 0, 14)
            Dot.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

            Tgl.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(Box, TweenInfo.new(0.2), {BackgroundColor3 = state and Fluid.Theme.AccentColor or Color3.fromRGB(50, 50, 50)}):Play()
                TweenService:Create(Dot, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
                callback(state)
            end)
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end

        -- Add Slider Component
        function Tab.AddSlider(text, min, max, default, callback)
            local SliderFrame = Instance.new("Frame", Page)
            SliderFrame.Size = UDim2.new(1, -10, 0, 50)
            SliderFrame.BackgroundColor3 = Fluid.Theme.SecondaryColor
            Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextLabel", SliderFrame)
            Label.Text = "  " .. text
            Label.Size = UDim2.new(1, 0, 0, 30)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.Font = Fluid.Theme.Font
            Label.TextSize = 14
            Label.TextXAlignment = "Left"

            local ValueLabel = Instance.new("TextLabel", SliderFrame)
            ValueLabel.Text = tostring(default or min)
            ValueLabel.Size = UDim2.new(0, 40, 0, 30)
            ValueLabel.Position = UDim2.new(1, -50, 0, 0)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.TextColor3 = Fluid.Theme.AccentColor
            ValueLabel.Font = Fluid.Theme.Font
            ValueLabel.TextSize = 14
            ValueLabel.TextXAlignment = "Right"

            local SliderBar = Instance.new("Frame", SliderFrame)
            SliderBar.Size = UDim2.new(1, -20, 0, 4)
            SliderBar.Position = UDim2.new(0, 10, 0.8, -2)
            SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame", SliderBar)
            Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Fluid.Theme.AccentColor
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

            local function update(input)
                local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                local val = math.floor(min + (max - min) * pos)
                ValueLabel.Text = tostring(val)
                callback(val)
            end

            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local move; move = UserInputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
                    end)
                    local endCon; endCon = UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            move:Disconnect()
                            endCon:Disconnect()
                        end
                    end)
                    update(input)
                end
            end)
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end

        -- Add Dropdown Component
        function Tab.AddDropdown(text, list, callback)
            local DropdownFrame = Instance.new("Frame", Page)
            DropdownFrame.Size = UDim2.new(1, -10, 0, 40)
            DropdownFrame.BackgroundColor3 = Fluid.Theme.SecondaryColor
            DropdownFrame.ClipsDescendants = true
            Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 6)

            local Btn = Instance.new("TextButton", DropdownFrame)
            Btn.Size = UDim2.new(1, 0, 0, 40)
            Btn.BackgroundTransparency = 1
            Btn.Text = "  " .. text
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.Font = Fluid.Theme.Font
            Btn.TextSize = 14
            Btn.TextXAlignment = "Left"

            local Arrow = Instance.new("TextLabel", DropdownFrame)
            Arrow.Text = "v"
            Arrow.Size = UDim2.new(0, 40, 0, 40)
            Arrow.Position = UDim2.new(1, -40, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
            Arrow.Font = Enum.Font.GothamBold
            Arrow.TextSize = 14

            local ListHolder = Instance.new("Frame", DropdownFrame)
            ListHolder.Position = UDim2.new(0, 0, 0, 40)
            ListHolder.Size = UDim2.new(1, 0, 0, #list * 30)
            ListHolder.BackgroundTransparency = 1
            local LL = Instance.new("UIListLayout", ListHolder)

            local open = false
            Btn.MouseButton1Click:Connect(function()
                open = not open
                TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = open and UDim2.new(1, -10, 0, 40 + (#list * 30)) or UDim2.new(1, -10, 0, 40)}):Play()
                Arrow.Rotation = open and 180 or 0
                task.wait(0.3)
                Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
            end)

            for _, val in pairs(list) do
                local opt = Instance.new("TextButton", ListHolder)
                opt.Size = UDim2.new(1, 0, 0, 30)
                opt.BackgroundTransparency = 1
                opt.Text = val
                opt.TextColor3 = Color3.fromRGB(180, 180, 180)
                opt.Font = Fluid.Theme.Font
                opt.TextSize = 13
                
                opt.MouseButton1Click:Connect(function()
                    Btn.Text = "  " .. text .. ": " .. val
                    callback(val)
                    open = false
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -10, 0, 40)}):Play()
                    Arrow.Rotation = 0
                end)
            end
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end

        -- Add Textbox Component
        function Tab.AddTextbox(text, placeholder, callback)
            local BoxFrame = Instance.new("Frame", Page)
            BoxFrame.Size = UDim2.new(1, -10, 0, 45)
            BoxFrame.BackgroundColor3 = Fluid.Theme.SecondaryColor
            Instance.new("UICorner", BoxFrame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextLabel", BoxFrame)
            Label.Text = "  " .. text
            Label.Size = UDim2.new(0.4, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.Font = Fluid.Theme.Font
            Label.TextSize = 14
            Label.TextXAlignment = "Left"

            local Input = Instance.new("TextBox", BoxFrame)
            Input.Size = UDim2.new(0.5, 0, 0, 30)
            Input.Position = UDim2.new(1, -10, 0.5, -15)
            Input.AnchorPoint = Vector2.new(1, 0)
            Input.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Input.Text = ""
            Input.PlaceholderText = placeholder or "Type here..."
            Input.TextColor3 = Color3.fromRGB(255, 255, 255)
            Input.PlaceholderColor3 = Fluid.Theme.PlaceholderColor
            Input.Font = Fluid.Theme.Font
            Input.TextSize = 13
            Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 4)

            Input.FocusLost:Connect(function(enter)
                if enter then callback(Input.Text) end
            end)
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end

        if #TabHolder:GetChildren() == 2 then
            Page.Visible = true
            TabButton.BackgroundColor3 = Fluid.Theme.AccentColor
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        return Tab
    end

    return Window
end

return Fluid
