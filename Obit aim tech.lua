-- ✅ TSB ORBIT AIM - BẢN ĐẦY ĐỦ & CHI TIẾT NHẤT (Tier 1)
-- Chỉ hoạt động khi ĐỐI PHƯƠNG bị uppercut
-- Bấm Q (dash) → Orbit + Body Aim chỉ trong lúc dash → tự ngắt khi dash xong
-- GUI 50x50 draggable, cooldown 5s, status realtime trên nút

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- ==================== CẤU HÌNH DỄ CHỈNH (Tier 1) ====================
local CONFIG = {
    ORBIT_SPEED = 7,           -- Tốc độ xoay (7 như mày yêu cầu)
    ORBIT_RADIUS = 8,          -- Khoảng cách xoay quanh target
    UPPER_VEL_THRESHOLD = 55,  -- Ngưỡng velocity Y (đã tối ưu, chỉ detect uppercut địch)
    SMOOTHNESS = 0.35,         -- Độ mượt (0.3 = nhanh, 0.4 = mượt hơn)
    COOLDOWN_TIME = 5,         -- Delay giữa các lần dùng (5 giây)
    DASH_DURATION = 1.65,      -- Thời gian dash tối đa (tự ngắt chính xác)
    MAX_DISTANCE = 150,        -- Khoảng cách tối đa để detect target
}

local enabled = false
local active = false
local target = nil
local angle = 0
local cooldownEndTime = 0
local dashEndTime = 0

-- ==================== GUI 50x50 DRAGGABLE + STATUS REALTIME ====================
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

-- Drag
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

-- ==================== HÀM CHECK UPPERCUT (CHỈ ĐỐI PHƯƠNG) ====================
local function isUppercutVictim(char)
    if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then return false end
    local hum = char.Humanoid
    local root = char.HumanoidRootPart
    if hum.Health <= 0 then return false end
    
    local velY = root.AssemblyLinearVelocity.Y
    local isAir = hum:GetState() == Enum.HumanoidStateType.Freefall or hum.FloorMaterial == Enum.Material.Air
    
    return velY > CONFIG.UPPER_VEL_THRESHOLD and isAir
end

local function findClosestUppercutVictim()
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local closest, shortest = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            if isUppercutVictim(p.Character) then
                local dist = (p.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
                if dist < shortest and dist < CONFIG.MAX_DISTANCE then
                    shortest = dist
                    closest = p.Character
                end
            end
        end
    end
    return closest
end

-- ==================== DASH (Q) TRIGGER ====================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not enabled or input.KeyCode ~= Enum.KeyCode.Q then return end
    if tick() < cooldownEndTime then return end

    local victim = findClosestUppercutVictim()
    if victim then
        target = victim
        active = true
        angle = 0
        dashEndTime = tick() + CONFIG.DASH_DURATION
        cooldownEndTime = tick() + CONFIG.COOLDOWN_TIME
    end
end)

-- ==================== MAIN LOOP + UPDATE STATUS GUI ====================
RunService.RenderStepped:Connect(function(delta)
    if not enabled then return end

    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    local now = tick()

    -- Tự ngắt khi dash xong hoặc target mất
    if active and (now > dashEndTime or not target or not target:FindFirstChild("HumanoidRootPart") or target.Humanoid.Health <= 0 or not isUppercutVictim(target)) then
        active = false
        target = nil
        humanoid.AutoRotate = true
    end

    -- Update status trên nút 50x50 (chi tiết realtime)
    if active then
        ToggleButton.Text = "ACTIVE"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    elseif now < cooldownEndTime then
        local cdLeft = math.ceil(cooldownEndTime - now)
        ToggleButton.Text = "CD:" .. cdLeft
        ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    else
        ToggleButton.Text = enabled and "ON" or "OFF"
        ToggleButton.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    end

    if active and target then
        local targetRoot = target:FindFirstChild("HumanoidRootPart")
        if not targetRoot then active = false; return end

        humanoid.AutoRotate = false

        angle += CONFIG.ORBIT_SPEED * delta

        local targetPos = targetRoot.Position + Vector3.new(0, 3, 0)
        local offset = Vector3.new(math.cos(angle) * CONFIG.ORBIT_RADIUS, 0, math.sin(angle) * CONFIG.ORBIT_RADIUS)
        local orbitPos = targetPos + offset

        local targetCFrame = CFrame.new(orbitPos, targetPos)
        rootPart.CFrame = rootPart.CFrame:Lerp(targetCFrame, CONFIG.SMOOTHNESS)

        local vel = rootPart.AssemblyLinearVelocity
        rootPart.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
    else
        if humanoid then
            humanoid.AutoRotate = true
        end
    end
end)

print("✅ TSB Orbit Aim - Bản đầy đủ & chi tiết nhất đã load!")
print("   • Chỉ hoạt động khi ĐỐI PHƯƠNG bị uppercut")
print("   • Bấm Q khi địch bay lên → Orbit speed 7 + Aim thân trong lúc dash")
print("   • Tự ngắt khi dash xong + cooldown 5s")
print("   • Nút 50x50 kéo thả được, có hiển thị ACTIVE / CD:5 realtime")
