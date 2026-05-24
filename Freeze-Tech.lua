-- // FreezeTech | Animation 10503381238 → Dash Q → Freeze (ngửa lên + tương tác)
-- // HOÀN THIỆN

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

-- // SETTINGS
local ENABLED = true
local COOLDOWN = false

local DASH_DELAY = 0.225        -- Delay trước khi bấm Q dash
local FREEZE_DELAY = 0.1        -- Sau khi bấm Q bao lâu thì freeze
local FREEZE_DURATION = 0.4     -- Thời gian freeze
local COOLDOWN_TIME = 5         -- Cooldown 5 giây
local TILT_ANGLE = 30           -- Góc ngửa lên (âm = ngửa lên trời)

local TARGET_ANIMATION = "10503381238"

-- // GUI SETUP
local gui = Instance.new("ScreenGui")
gui.Name = "FreezeTechGUI"
gui.ResetOnSpawn = false

pcall(function()
    gui.Parent = gethui()
end)
if not gui.Parent then
    gui.Parent = game:GetService("CoreGui")
end

local button = Instance.new("TextButton")
button.Name = "Toggle"
button.Parent = gui
button.Size = UDim2.new(0, 60, 0, 20)
button.Position = UDim2.new(0.5, -30, 0.5, -10)
button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
button.BorderSizePixel = 0
button.Font = Enum.Font.SourceSansBold
button.TextScaled = true
button.Text = "ON"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.AutoButtonColor = false
button.ZIndex = 10

local corner = Instance.new("UICorner", button)
corner.CornerRadius = UDim.new(0, 6)

local stroke = Instance.new("UIStroke", button)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1.5
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Rainbow text
task.spawn(function()
    local hue = 0
    while task.wait() do
        hue = (hue + 0.005) % 1
        button.TextColor3 = Color3.fromHSV(hue, 1, 1)
    end
end)

-- Toggle ON/OFF
button.MouseButton1Click:Connect(function()
    ENABLED = not ENABLED
    button.Text = ENABLED and "ON" or "OFF"
end)

-- // DRAG
local dragging = false
local dragStart = nil
local startPos = nil

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = button.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        button.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- // FREEZE FUNCTION
local function doFreeze(char, duration)
    local humanoid = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    local oldPlatformStand = humanoid.PlatformStand
    local freezePos = root.Position
    local startTime = tick()

    humanoid.PlatformStand = true

    local conn
    conn = RunService.Stepped:Connect(function()
        if tick() - startTime >= duration then
            conn:Disconnect()
            if humanoid and humanoid.Parent then
                humanoid.PlatformStand = oldPlatformStand
            end
            return
        end

        if root and root.Parent then
            root.CFrame = CFrame.new(freezePos) * CFrame.Angles(0, math.rad(TILT_ANGLE), 0)
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
        if humanoid and humanoid.Parent then
            humanoid.PlatformStand = true
        end
    end)
end

-- // MAIN LOGIC
local function onCharacterAdded(char)
    local humanoid = char:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")

    animator.AnimationPlayed:Connect(function(track)
        -- Kiểm tra đúng animation
        if track.Animation.AnimationId ~= "rbxassetid://" .. TARGET_ANIMATION then return end
        if not ENABLED or COOLDOWN then return end

        COOLDOWN = true

        -- Delay trước khi dash
        task.wait(DASH_DELAY)
        if not char.Parent then
            COOLDOWN = false
            return
        end

        -- Bấm Q để dash game
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, nil)
        task.wait(0.03)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, nil)

        -- Đợi rồi freeze
        task.wait(FREEZE_DELAY)
        if char.Parent and humanoid.Parent then
            doFreeze(char, FREEZE_DURATION)
        end

        -- Cooldown
        task.wait(COOLDOWN_TIME)
        COOLDOWN = false
    end)
end

-- Áp dụng cho character hiện tại
if player.Character then
    onCharacterAdded(player.Character)
end

-- Áp dụng cho character sau khi respawn
player.CharacterAdded:Connect(onCharacterAdded)

-- Reset cooldown khi chết
player.CharacterAdded:Connect(function()
    COOLDOWN = false
end)
