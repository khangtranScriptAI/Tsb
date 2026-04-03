--// TSB Auto Dash + Orbit + Body Aim

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

--// SETTINGS
local ORBIT_SPEED = 50
local ORBIT_RADIUS = 3
local ORBIT_HEIGHT = 1
local SMOOTHNESS = 0.35
local COOLDOWN_TIME = 5
local ORBIT_DURATION = 1.7
local MAX_DISTANCE = 30

--// STATE
local Enabled = false
local Active = false
local Target = nil
local Angle = 0
local OrbitEndTime = 0
local CooldownEndTime = 0

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OrbitAimGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 55, 0, 55)
ToggleButton.Position = UDim2.new(0, 20, 0, 100)
ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(1, 0)
Corner.Parent = ToggleButton

--// DASH COOLDOWN BAR
local DashBarBG = Instance.new("Frame")
DashBarBG.Size = UDim2.new(0, 60, 0, 4)
DashBarBG.Position = UDim2.new(0.5, -30, 1, 6)
DashBarBG.BackgroundTransparency = 1
DashBarBG.BorderSizePixel = 0
DashBarBG.Parent = ToggleButton

local DashBar = Instance.new("Frame")
DashBar.Size = UDim2.new(1, 0, 1, 0)
DashBar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
DashBar.BorderSizePixel = 0
DashBar.Visible = false
DashBar.Parent = DashBarBG

local DashBarCorner = Instance.new("UICorner")
DashBarCorner.CornerRadius = UDim.new(1, 0)
DashBarCorner.Parent = DashBar

--// DRAG GUI
local Dragging = false
local DragStart
local StartPos
local DragMoved = false

ToggleButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		Dragging = true
		DragMoved = false
		DragStart = input.Position
		StartPos = ToggleButton.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if Dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then
		local Delta = input.Position - DragStart

		if math.abs(Delta.X) > 4 or math.abs(Delta.Y) > 4 then
			DragMoved = true
		end

		ToggleButton.Position = UDim2.new(
			StartPos.X.Scale,
			StartPos.X.Offset + Delta.X,
			StartPos.Y.Scale,
			StartPos.Y.Offset + Delta.Y
		)
	end
end)

ToggleButton.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		Dragging = false
	end
end)

ToggleButton.MouseButton1Click:Connect(function()
	if DragMoved then
		return
	end

	Enabled = not Enabled

	if Enabled then
		ToggleButton.Text = "ON"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	else
		ToggleButton.Text = "OFF"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
		Active = false
		Target = nil
	end
end)

--// RESET
LocalPlayer.CharacterAdded:Connect(function()
	Active = false
	Target = nil
end)

--// AUTO DASH
local function AutoDash()
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
	task.wait(0.05)
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
end

--// CHECK REAL UPPERCUT
local function IsRealUppercut(enemyRoot, myRoot)
	local Velocity = enemyRoot.AssemblyLinearVelocity

	return
		Velocity.Y > 45
		and Velocity.Y < 120
		and enemyRoot.Position.Y > myRoot.Position.Y + 3
		and math.abs(Velocity.X) < 60
		and math.abs(Velocity.Z) < 60
end

--// FIND TARGET
local function FindUppercutVictim()
	local Character = LocalPlayer.Character
	if not Character then
		return nil
	end

	local MyRoot = Character:FindFirstChild("HumanoidRootPart")
	if not MyRoot then
		return nil
	end

	local ClosestTarget = nil
local ClosestTarget = nil
local ClosestDistance = math.huge

for _, Player in ipairs(Players:GetPlayers()) do
	if Player ~= LocalPlayer and Player.Character then
		local EnemyCharacter = Player.Character
		local Humanoid = EnemyCharacter:FindFirstChild("Humanoid")
		local Root = EnemyCharacter:FindFirstChild("HumanoidRootPart")

		if Humanoid and Root and Humanoid.Health > 0 then
			local Distance = (Root.Position - MyRoot.Position).Magnitude

			local IsAirborne =
				Humanoid:GetState() == Enum.HumanoidStateType.Freefall
				or Humanoid.FloorMaterial == Enum.Material.Air

			if Distance <= MAX_DISTANCE and IsAirborne and IsRealUppercut(Root, MyRoot) then
				if Distance < ClosestDistance then
					ClosestDistance = Distance
					ClosestTarget = EnemyCharacter
				end
			end
		end
	end
end

return ClosestTarget

end

--// START ORBIT
local function BeginOrbit(Victim)
	Target = Victim
	Active = true
	Angle = 0
	OrbitEndTime = tick() + ORBIT_DURATION
	CooldownEndTime = tick() + COOLDOWN_TIME

	DashBar.Visible = true
	DashBar.Size = UDim2.new(1, 0, 1, 0)

	AutoDash()
end

--// TARGET DETECTION
RunService.Heartbeat:Connect(function()
	if not Enabled then return end
	if Active then return end
	if tick() < CooldownEndTime then return end

	local Victim = FindUppercutVictim()

	if Victim then
		BeginOrbit(Victim)
	end
end)

--// MAIN LOOP
RunService.RenderStepped:Connect(function(delta)
	local Character = LocalPlayer.Character
	if not Character then return end

	local Humanoid = Character:FindFirstChild("Humanoid")
	local RootPart = Character:FindFirstChild("HumanoidRootPart")

	if not Humanoid or not RootPart then
		return
	end

	local Now = tick()

	--// Dash cooldown bar
	if CooldownEndTime > Now then
		local Remaining = CooldownEndTime - Now
		local Percent = math.clamp(Remaining / COOLDOWN_TIME, 0, 1)

		DashBar.Visible = true
		DashBar.Size = UDim2.new(Percent, 0, 1, 0)
	else
		DashBar.Visible = false
	end

	--// Button status
	if Active then
		ToggleButton.Text = "ACTIVE"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
	elseif Now < CooldownEndTime then
		ToggleButton.Text = tostring(math.ceil(CooldownEndTime - Now))
		ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	else
		if Enabled then
			ToggleButton.Text = "ON"
			ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		else
			ToggleButton.Text = "OFF"
			ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
		end
	end

	if not Active then
		Humanoid.AutoRotate = true
		return
	end

	if not Target then
		Active = false
		Humanoid.AutoRotate = true
		return
	end

	local TargetHumanoid = Target:FindFirstChild("Humanoid")
	local TargetRoot = Target:FindFirstChild("HumanoidRootPart")

	if not TargetHumanoid or not TargetRoot then
		Active = false
		Target = nil
		Humanoid.AutoRotate = true
		return
	end

	if TargetHumanoid.Health <= 0 or Now > OrbitEndTime then
		Active = false
		Target = nil
		Humanoid.AutoRotate = true
		return
	end

	Humanoid.AutoRotate = false
	Angle = Angle + (ORBIT_SPEED * delta)

	local TargetPosition = TargetRoot.Position + Vector3.new(0, ORBIT_HEIGHT, 0)

	local OrbitOffset = Vector3.new(
		math.cos(Angle) * ORBIT_RADIUS,
		0,
		math.sin(Angle) * ORBIT_RADIUS
	)

	local OrbitPosition = TargetPosition + OrbitOffset
	local SmoothedPosition = RootPart.Position:Lerp(OrbitPosition, SMOOTHNESS)

	local LookCFrame = CFrame.new(SmoothedPosition, TargetPosition)
	Character:PivotTo(LookCFrame)

	local Velocity = RootPart.AssemblyLinearVelocity
	RootPart.AssemblyLinearVelocity = Vector3.new(
		Velocity.X * 0.2,
		Velocity.Y,
		Velocity.Z * 0.2
	)
end)
