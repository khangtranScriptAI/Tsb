--// TSB Auto Dash + Orbit + Body Aim
--// Only targets enemies that are uppercut / launched

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

--// SETTINGS
local ORBIT_SPEED = 7
local ORBIT_RADIUS = 8
local ORBIT_HEIGHT = 3
local SMOOTHNESS = 0.35
local COOLDOWN_TIME = 5
local ORBIT_DURATION = 1.7
local MAX_DISTANCE = 160

--// STATE
local enabled = false
local active = false
local target = nil
local angle = 0
local cooldownEndTime = 0
local orbitEndTime = 0

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OrbitAimGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0, 100)
ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(1, 0)
Corner.Parent = ToggleButton

--// Drag GUI
local dragging = false
local dragStart = nil
local startPos = nil
local movedTooFar = false

ToggleButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		movedTooFar = false
		dragStart = input.Position
		startPos = ToggleButton.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then
		local delta = input.Position - dragStart

		if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
			movedTooFar = true
		end

		ToggleButton.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

ToggleButton.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

ToggleButton.MouseButton1Click:Connect(function()
	if movedTooFar then
		return
	end

	enabled = not enabled

	if enabled then
		ToggleButton.Text = "ON"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	else
		ToggleButton.Text = "OFF"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
		active = false
		target = nil
	end
end)

player.CharacterAdded:Connect(function()
	active = false
	target = nil
end)

--// Auto Dash
local function autoDash()
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
	task.wait(0.05)
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
end

--// Find best uppercut target
local function findUppercutVictim()
	local character = player.Character
	if not character then
		return nil
	end

	local myRoot = character:FindFirstChild("HumanoidRootPart")
	if not myRoot then
		return nil
	end

	local bestTarget = nil
	local bestScore = math.huge

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local enemyChar = p.Character
			local hum = enemyChar:FindFirstChild("Humanoid")
			local root = enemyChar:FindFirstChild("HumanoidRootPart")

			if hum and root and hum.Health > 0 then
				local distance = (root.Position - myRoot.Position).Magnitude
				local upwardVelocity = root.AssemblyLinearVelocity.Y

				local isAirborne =
					hum:GetState() == Enum.HumanoidStateType.Freefall
					or hum.FloorMaterial == Enum.Material.Air

				local isUppercuted =
					isAirborne
					and upwardVelocity > 15
					and upwardVelocity < 80
					and distance < MAX_DISTANCE

				if isUppercuted then
					local healthPercent = hum.Health / hum.MaxHealth

					local direction = (root.Position - myRoot.Position).Unit
					local lookVector = myRoot.CFrame.LookVector
					local dot = math.clamp(direction:Dot(lookVector), -1, 1)
					local angleScore = 1 - math.max(dot, 0)

					local score =
						(distance * 1)
						+ (healthPercent * 35)
						+ (angleScore * 20)

					if score < bestScore then
						bestScore = score
						bestTarget = enemyChar
					end
				end
			end
		end
	end

	return bestTarget
end

--// Start orbit
local function beginOrbit(victim)
	target = victim
	active = true
	angle = 0
	orbitEndTime = tick() + ORBIT_DURATION
	cooldownEndTime = tick() + COOLDOWN_TIME

	autoDash()

	print("Orbiting:", victim.Name)
end

--// Detect target
RunService.Heartbeat:Connect(function()
	if not enabled then return end
	if active then return end
	if tick() < cooldownEndTime then return end

	local victim = findUppercutVictim()

	if victim then
		beginOrbit(victim)
	end
end)

--// Orbit loop
RunService.RenderStepped:Connect(function(delta)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not rootPart then
		return
	end

	local now = tick()

	if active then
		ToggleButton.Text = "ACTIVE"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
	elseif now < cooldownEndTime then
		ToggleButton.Text = "CD:" .. math.ceil(cooldownEndTime - now)
		ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	else
		if enabled then
			ToggleButton.Text = "ON"
			ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		else
			ToggleButton.Text = "OFF"
			ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
		end
	end

	if not active then
		humanoid.AutoRotate = true
		return
	end

	if not target then
		active = false
		humanoid.AutoRotate = true
		return
	end

	local targetHumanoid = target:FindFirstChild("Humanoid")
	local targetRoot = target:FindFirstChild("HumanoidRootPart")

	if not targetHumanoid or not targetRoot then
		active = false
		target = nil
		humanoid.AutoRotate = true
		return
	end

	if targetHumanoid.Health <= 0 or now > orbitEndTime then
		active = false
		target = nil
		humanoid.AutoRotate = true
		return
	end

	humanoid.AutoRotate = false
	angle = angle + (ORBIT_SPEED * delta)

	local targetPos = targetRoot.Position + Vector3.new(0, ORBIT_HEIGHT, 0)

	local orbitOffset = Vector3.new(
		math.cos(angle) * ORBIT_RADIUS,
		0,
		math.sin(angle) * ORBIT_RADIUS
	)

	local orbitPos = targetPos + orbitOffset
	local currentPos = rootPart.Position:Lerp(orbitPos, SMOOTHNESS)

	local lookCFrame = CFrame.new(currentPos, targetPos)
	character:PivotTo(lookCFrame)

	local velocity = rootPart.AssemblyLinearVelocity
	rootPart.AssemblyLinearVelocity = Vector3.new(
		velocity.X * 0.2,
		velocity.Y,
		velocity.Z * 0.2
	)
end)

print("Loaded Auto Dash + Orbit + Body Aim")
