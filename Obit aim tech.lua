-- ✅ TSB Auto Dash + Orbit + Aim Body khi địch bị hất tung
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

local ORBIT_SPEED = 7
local ORBIT_RADIUS = 8
local SMOOTHNESS = 0.35
local COOLDOWN_TIME = 5
local ORBIT_DURATION = 1.7

local enabled = false
local active = false
local target = nil
local angle = 0
local cooldownEndTime = 0
local orbitEndTime = 0

-- GUI 50x50 draggable
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0, 100)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
ToggleButton.Text = "ON"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = ScreenGui

Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)

-- Drag nút
local dragging = false
local dragStart, startPos

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

ToggleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    enabled = not enabled
    ToggleButton.Text = enabled and "ON" or "OFF"
    ToggleButton.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

-- Tìm địch bị hất tung
local function findUppercutVictim()
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local closest, shortest = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p \~= player and p.Character then
            local hum = p.Character:FindFirstChild("Humanoid")
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                local isAir = hum:GetState() == Enum.HumanoidStateType.Freefall or hum.FloorMaterial == Enum.Material.Air
                if isAir and root.AssemblyLinearVelocity.Y > 20 then
                    local dist = (root.Position - myRoot.Position).Magnitude
                    if dist < shortest and dist < 160 then
                        shortest = dist
                        closest = p.Character
                    end
                end
            end
        end
    end
    return closest
end

-- Tự động Dash (simulate Q)
local function autoDash()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    task.wait(0.06)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
end

-- Tự động detect uppercut và trigger
RunService.Heartbeat:Connect(function()
    if not enabled or active or tick() < cooldownEndTime then return end

    local victim = findUppercutVictim()
    if victim then
        target = victim
        active = true
        angle = 0
        orbitEndTime = tick() + ORBIT_DURATION
        cooldownEndTime = tick() + COOLDOWN_TIME

        autoDash()  -- Tự động dash
        print("🚀 Tự động Dash + Orbit + Aim body trên: " .. victim.Name)
    end
end)

-- Orbit + Aim body loop
RunService.RenderStepped:Connect(function(delta)
    if not enabled then return end

    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    local now = tick()

    if active and (now > orbitEndTime or not target or not target:FindFirstChild("HumanoidRootPart") or target.Humanoid.Health <= 0) then
        active = false
        target = nil
        humanoid.AutoRotate = true
    end

    -- Status GUI
    if active then
        ToggleButton.Text = "ACTIVE"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    elseif now < cooldownEndTime then
        ToggleButton.Text = "CD:" .. math.ceil(cooldownEndTime - now)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    else
        ToggleButton.Text = enabled and "ON" or "OFF"
        ToggleButton.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    end

    if active and target then
        local targetRoot = target:FindFirstChild("HumanoidRootPart")
        if not targetRoot then active = false; return end

        humanoid.AutoRotate = false

        angle += ORBIT_SPEED * delta

        local targetPos = targetRoot.Position + Vector3.new(0, 3, 0)
        local offset = Vector3.new(math.cos(angle) * ORBIT_RADIUS, 0, math.sin(angle) * ORBIT_RADIUS)
        local orbitPos = targetPos + offset

        local targetCFrame = CFrame.new(orbitPos, targetPos)
        rootPart.CFrame = rootPart.CFrame:Lerp(targetCFrame, SMOOTHNESS)

        local vel = rootPart.AssemblyLinearVelocity
        rootPart.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
    else
        humanoid.AutoRotate = true
    end
end)

print("✅ TSB Auto Dash + Orbit Aim đã load!")
print("   • Bật ON")
print("   • Khi địch bị hất tung → script tự động Dash + Orbit + Aim body")
print("   • Cooldown 5 giây")
