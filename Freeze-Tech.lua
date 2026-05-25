-- // FreezeTech | Animation 10503381238 → Dash Q → Freeze
-- // FULL FIXED NGỬA LÊN

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

--// SETTINGS
local ENABLED = true
local COOLDOWN = false

local DASH_DELAY = 0.23
local FREEZE_DELAY = 0.15
local FREEZE_DURATION = 0.4
local COOLDOWN_TIME = 5

local TILT_ANGLE = -45 -- ngửa lên mạnh

local TARGET_ANIMATION = "10503381238"

--// GUI
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
button.Parent = gui
button.Size = UDim2.new(0, 65, 0, 24)
button.Position = UDim2.new(0.5, -32, 0.5, -12)
button.BackgroundColor3 = Color3.fromRGB(20,20,20)
button.BorderSizePixel = 0
button.Text = "ON"
button.Font = Enum.Font.SourceSansBold
button.TextScaled = true
button.TextColor3 = Color3.new(1,1,1)
button.AutoButtonColor = false

Instance.new("UICorner", button).CornerRadius = UDim.new(0,7)

local stroke = Instance.new("UIStroke", button)
stroke.Thickness = 1.5
stroke.Color = Color3.new(1,1,1)

--// Rainbow text
task.spawn(function()
    local h = 0
    while task.wait() do
        h = (h + 0.005) % 1
        button.TextColor3 = Color3.fromHSV(h,1,1)
    end
end)

--// Toggle
button.MouseButton1Click:Connect(function()
    ENABLED = not ENABLED
    button.Text = ENABLED and "ON" or "OFF"
end)

--// Drag
local dragging = false
local dragStart
local startPos

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = button.Position
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

        button.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

--// FREEZE
local function doFreeze(char, duration)
    local humanoid = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root then
        return
    end

    local freezePos = root.Position
    local start = tick()

    humanoid.PlatformStand = true

    local conn
    conn = RunService.Stepped:Connect(function()
        if not char.Parent then
            conn:Disconnect()
            return
        end

        if tick() - start >= duration then
            conn:Disconnect()

            if humanoid and humanoid.Parent then
                humanoid.PlatformStand = false
            end

            return
        end

        -- giữ hướng hiện tại
        local current = root.CFrame
        local rotation = (current - current.Position).Rotation

        -- ngửa lên theo X thật
        root.CFrame =
            CFrame.new(freezePos)
            * rotation
            * CFrame.Angles(math.rad(TILT_ANGLE),0,0)

        -- freeze velocity
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

        if anim.AnimationId ~= "rbxassetid://"..TARGET_ANIMATION then
            return
        end

        if not ENABLED or COOLDOWN then
            return
        end

        COOLDOWN = true

        -- delay trước dash
        task.wait(DASH_DELAY)

        if not char.Parent then
            COOLDOWN = false
            return
        end

        -- press Q
        VirtualInputManager:SendKeyEvent(
            true,
            Enum.KeyCode.Q,
            false,
            game
        )

        task.wait(0.03)

        VirtualInputManager:SendKeyEvent(
            false,
            Enum.KeyCode.Q,
            false,
            game
        )

        -- delay freeze
        task.wait(FREEZE_DELAY)

        if char.Parent then
            doFreeze(char, FREEZE_DURATION)
        end

        task.wait(COOLDOWN_TIME)
        COOLDOWN = false
    end)
end

if player.Character then
    setupCharacter(player.Character)
end

player.CharacterAdded:Connect(function(char)
    COOLDOWN = false
    setupCharacter(char)
end)
