-- // FreezeTech | Animation 10503381238 → Dash Q → Freeze
-- // PREMIUM GLASS UI VERSION 🔥

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

--// SETTINGS
local ENABLED = true
local COOLDOWN = false
local DISABLED_TIMER = false

local DASH_DELAY = 0.236
local FREEZE_DELAY = 0.15
local FREEZE_DURATION = 0.67
local COOLDOWN_TIME = 5
local DISABLE_DURATION = 5

local TILT_ANGLE = 0

local TARGET_ANIMATION = "10503381238"
local DISABLE_ANIMATION = "10479335397"

--// GLASS GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FreezeTechPremium"
gui.ResetOnSpawn = false

pcall(function()
    gui.Parent = gethui()
end)
if not gui.Parent then
    gui.Parent = game:GetService("CoreGui")
end

-- Main container
local container = Instance.new("Frame")
container.Name = "Container"
container.Parent = gui
container.Size = UDim2.new(0, 180, 0, 40)
container.Position = UDim2.new(0.5, -90, 0.5, -20)
container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
container.BackgroundTransparency = 0.85  -- Glass effect
container.BorderSizePixel = 0

-- Glass blur background
local blur = Instance.new("Frame")
blur.Name = "Blur"
blur.Parent = container
blur.Size = UDim2.new(1, 0, 1, 0)
blur.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
blur.BackgroundTransparency = 0.92
blur.BorderSizePixel = 0
blur.ZIndex = 0

-- Gradient overlay
local gradient = Instance.new("UIGradient")
gradient.Parent = container
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 220, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
})
gradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.8),
    NumberSequenceKeypoint.new(0.5, 0.9),
    NumberSequenceKeypoint.new(1, 0.8)
})
gradient.Rotation = 45

local corner = Instance.new("UICorner", container)
corner.CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", container)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Transparency = 0.5
stroke.Thickness = 1.5

-- Shadow
local shadow = Instance.new("Frame")
shadow.Name = "Shadow"
shadow.Parent = gui
shadow.Size = UDim2.new(0, 180, 0, 40)
shadow.Position = UDim2.new(0.5, -88, 0.5, -18)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.7
shadow.BorderSizePixel = 0
shadow.ZIndex = -1

local shadowCorner = Instance.new("UICorner", shadow)
shadowCorner.CornerRadius = UDim.new(0, 12)

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Parent = container
title.Size = UDim2.new(1, 0, 0, 14)
title.Position = UDim2.new(0, 0, 0, 2)
title.BackgroundTransparency = 1
title.Font = Enum.Font.FredokaOne  -- Chữ 3D style
title.TextScaled = true
title.Text = "❄️ FREEZE TECH"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextStrokeTransparency = 0.3
title.TextStrokeColor3 = Color3.fromRGB(100, 150, 255)

-- Button
local button = Instance.new("TextButton")
button.Name = "MainButton"
button.Parent = container
button.Size = UDim2.new(1, -20, 0, 20)
button.Position = UDim2.new(0, 10, 0, 16)
button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
button.BackgroundTransparency = 0.92
button.BorderSizePixel = 0
button.Font = Enum.Font.FredokaOne
button.TextScaled = true
button.Text = "ON"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.AutoButtonColor = false
button.ZIndex = 5

local buttonCorner = Instance.new("UICorner", button)
buttonCorner.CornerRadius = UDim.new(0, 8)

-- Button glow
local buttonGlow = Instance.new("UIStroke", button)
buttonGlow.Color = Color3.fromRGB(150, 200, 255)
buttonGlow.Transparency = 0.3
buttonGlow.Thickness = 1

-- Rainbow text
local rainbowHue = 0
local countdownActive = false

task.spawn(function()
    while task.wait() do
        if not countdownActive then
            rainbowHue = (rainbowHue + 0.003) % 1
            local color = Color3.fromHSV(rainbowHue, 0.7, 1)
            title.TextColor3 = color
            buttonGlow.Color = color
        end
    end
end)

-- Toggle
button.MouseButton1Click:Connect(function()
    if countdownActive then return end
    ENABLED = not ENABLED
    button.Text = ENABLED and "ON" or "OFF"
    
    -- Tween animation khi bấm
    local targetSize = ENABLED and UDim2.new(1, -16, 0, 20) or UDim2.new(1, -20, 0, 20)
    local tween = TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = targetSize})
    tween:Play()
    task.wait(0.15)
    local resetTween = TweenService:Create(button, TweenInfo.new(0.15), {Size = UDim2.new(1, -20, 0, 20)})
    resetTween:Play()
end)

--// Drag
local dragging = false
local dragStart
local startPos

container.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = container.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        container.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        shadow.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X + 2,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y + 2
        )
    end
end)

--// HÀM ĐẾM NGƯỢC
local function startCountdown(duration, isDisable)
    countdownActive = true
    local countColor = isDisable and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(255, 180, 60)
    title.TextColor3 = countColor
    buttonGlow.Color = countColor

    for i = duration, 1, -1 do
        button.Text = "⏳ " .. tostring(i)
        task.wait(1)
    end

    countdownActive = false

    if isDisable then
        DISABLED_TIMER = false
    end

    button.Text = ENABLED and "ON" or "OFF"
end

--// FREEZE
local function doFreeze(char, duration)
    local humanoid = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    local freezePos = root.Position
    local freezeLook = root.CFrame.LookVector
    local start = tick()

    humanoid.AutoRotate = false
    humanoid.PlatformStand = true

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Parent = root
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 50000
    bodyGyro.D = 1000

    local bodyPos = Instance.new("BodyPosition")
    bodyPos.Parent = root
    bodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyPos.P = 50000
    bodyPos.D = 1000
    bodyPos.Position = freezePos

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not char.Parent then
            conn:Disconnect()
            bodyGyro:Destroy()
            bodyPos:Destroy()
            return
        end

        if tick() - start >= duration then
            conn:Disconnect()
            bodyGyro:Destroy()
            bodyPos:Destroy()
            humanoid.PlatformStand = false
            humanoid.AutoRotate = true
            return
        end

        bodyPos.Position = freezePos

        local targetCFrame =
            CFrame.lookAt(freezePos, freezePos + freezeLook)
            * CFrame.Angles(math.rad(50), 0, math.rad(TILT_ANGLE))

        bodyGyro.CFrame = targetCFrame

        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero

        humanoid.PlatformStand = true
    end)
end

--// MAIN
local function setupCharacter(char)
    local humanoid = char:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")

    animator.AnimationPlayed:Connect(function(track)
        local anim = track.Animation
        if not anim then return end

        local animId = anim.AnimationId

        if animId == "rbxassetid://"..DISABLE_ANIMATION then
            if not DISABLED_TIMER and not countdownActive then
                DISABLED_TIMER = true
                task.spawn(function()
                    startCountdown(DISABLE_DURATION, true)
                end)
            end
            return
        end

        if animId ~= "rbxassetid://"..TARGET_ANIMATION then return end
        if not ENABLED or COOLDOWN then return end
        if DISABLED_TIMER or countdownActive then return end

        COOLDOWN = true

        task.wait(DASH_DELAY)
        if not char.Parent then
            COOLDOWN = false
            return
        end

        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
        task.wait(0.03)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)

        task.wait(FREEZE_DELAY)
        if char.Parent then
            doFreeze(char, FREEZE_DURATION)
        end

        task.spawn(function()
            startCountdown(COOLDOWN_TIME, false)
        end)

        task.wait(COOLDOWN_TIME)
        COOLDOWN = false
    end)
end

if player.Character then
    setupCharacter(player.Character)
end

player.CharacterAdded:Connect(function(char)
    COOLDOWN = false
    DISABLED_TIMER = false
    countdownActive = false
    button.Text = ENABLED and "ON" or "OFF"
    setupCharacter(char)
end)
