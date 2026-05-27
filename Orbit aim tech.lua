--// ORBIT GUI FULL

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- SETTINGS
local SPEED = 20
local DISTANCE = 5
local MODE = "Orbit"
local TARGET = nil

local enabled = false
local angle = 0
local orbitConnection

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "OrbitGUI"
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false

-- MENU BUTTON
local openBtn = Instance.new("TextButton")
openBtn.Parent = gui
openBtn.Size = UDim2.new(0,75,0,75)
openBtn.Position = UDim2.new(0,100,0,100)
openBtn.BackgroundColor3 = Color3.fromRGB(35,35,55)
openBtn.Text = "MENU"
openBtn.TextScaled = true
openBtn.Font = Enum.Font.GothamBold
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.BorderSizePixel = 0
openBtn.Active = true
openBtn.Draggable = true

Instance.new("UICorner", openBtn)

local openStroke = Instance.new("UIStroke")
openStroke.Parent = openBtn
openStroke.Color = Color3.fromRGB(90,120,255)
openStroke.Thickness = 2

-- MAIN MENU
local menu = Instance.new("Frame")
menu.Parent = gui
menu.Size = UDim2.new(0,400,0,300)
menu.Position = UDim2.new(0,190,0,100)
menu.BackgroundColor3 = Color3.fromRGB(20,20,35)
menu.BorderSizePixel = 0
menu.Active = true
menu.Draggable = true
menu.Visible = true

Instance.new("UICorner", menu)

local menuStroke = Instance.new("UIStroke")
menuStroke.Parent = menu
menuStroke.Color = Color3.fromRGB(90,120,255)
menuStroke.Thickness = 2

-- TITLE
local title = Instance.new("TextLabel")
title.Parent = menu
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "Orbit Controller"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)

-- CLOSE
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = menu
closeBtn.Size = UDim2.new(0,35,0,35)
closeBtn.Position = UDim2.new(1,-45,0,5)
closeBtn.Text = "X"
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BackgroundColor3 = Color3.fromRGB(255,70,70)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.BorderSizePixel = 0

Instance.new("UICorner", closeBtn)

-- TOGGLE BUTTON
local toggleBtn = Instance.new("TextButton")
toggleBtn.Parent = menu
toggleBtn.Position = UDim2.new(0,15,0,50)
toggleBtn.Size = UDim2.new(0,175,0,45)
toggleBtn.Text = "OFF"
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BackgroundColor3 = Color3.fromRGB(45,45,70)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.BorderSizePixel = 0

Instance.new("UICorner", toggleBtn)

-- MODE BUTTON
local modeBtn = Instance.new("TextButton")
modeBtn.Parent = menu
modeBtn.Position = UDim2.new(0,210,0,50)
modeBtn.Size = UDim2.new(0,175,0,45)
modeBtn.Text = "Mode : Orbit"
modeBtn.TextScaled = true
modeBtn.Font = Enum.Font.GothamBold
modeBtn.BackgroundColor3 = Color3.fromRGB(70,90,180)
modeBtn.TextColor3 = Color3.new(1,1,1)
modeBtn.BorderSizePixel = 0

Instance.new("UICorner", modeBtn)

-- SPEED LABEL
local speedLabel = Instance.new("TextLabel")
speedLabel.Parent = menu
speedLabel.Position = UDim2.new(0,15,0,110)
speedLabel.Size = UDim2.new(0,170,0,20)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed"
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextColor3 = Color3.fromRGB(180,200,255)
speedLabel.TextSize = 18

-- SPEED BOX
local speedBox = Instance.new("TextBox")
speedBox.Parent = menu
speedBox.Position = UDim2.new(0,15,0,135)
speedBox.Size = UDim2.new(0,170,0,40)
speedBox.Text = tostring(SPEED).." speed"
speedBox.TextScaled = true
speedBox.Font = Enum.Font.Gotham
speedBox.BackgroundColor3 = Color3.fromRGB(35,35,55)
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.BorderSizePixel = 0

Instance.new("UICorner", speedBox)

-- DISTANCE LABEL
local distLabel = Instance.new("TextLabel")
distLabel.Parent = menu
distLabel.Position = UDim2.new(0,215,0,110)
distLabel.Size = UDim2.new(0,170,0,20)
distLabel.BackgroundTransparency = 1
distLabel.Text = "Distance"
distLabel.TextXAlignment = Enum.TextXAlignment.Left
distLabel.Font = Enum.Font.GothamBold
distLabel.TextColor3 = Color3.fromRGB(180,200,255)
distLabel.TextSize = 18

-- DISTANCE BOX
local distBox = Instance.new("TextBox")
distBox.Parent = menu
distBox.Position = UDim2.new(0,215,0,135)
distBox.Size = UDim2.new(0,170,0,40)
distBox.Text = tostring(DISTANCE).." stud"
distBox.TextScaled = true
distBox.Font = Enum.Font.Gotham
distBox.BackgroundColor3 = Color3.fromRGB(35,35,55)
distBox.TextColor3 = Color3.new(1,1,1)
distBox.BorderSizePixel = 0

Instance.new("UICorner", distBox)

-- TARGET BUTTON
local targetBtn = Instance.new("TextButton")
targetBtn.Parent = menu
targetBtn.Position = UDim2.new(0,15,0,195)
targetBtn.Size = UDim2.new(1,-30,0,45)
targetBtn.Text = "Select Target"
targetBtn.TextScaled = true
targetBtn.Font = Enum.Font.GothamBold
targetBtn.BackgroundColor3 = Color3.fromRGB(60,80,170)
targetBtn.TextColor3 = Color3.new(1,1,1)
targetBtn.BorderSizePixel = 0

Instance.new("UICorner", targetBtn)

-- PLAYER LIST
local playerFrame = Instance.new("ScrollingFrame")
playerFrame.Parent = menu
playerFrame.Position = UDim2.new(1,10,0,50)
playerFrame.Size = UDim2.new(0,200,0,150)
playerFrame.BackgroundColor3 = Color3.fromRGB(25,25,40)
playerFrame.Visible = false
playerFrame.ScrollBarThickness = 4
playerFrame.BorderSizePixel = 0
playerFrame.CanvasSize = UDim2.new(0,0,0,0)

Instance.new("UICorner", playerFrame)

local playerStroke = Instance.new("UIStroke")
playerStroke.Parent = playerFrame
playerStroke.Color = Color3.fromRGB(90,120,255)
playerStroke.Thickness = 2

local layout = Instance.new("UIListLayout")
layout.Parent = playerFrame
layout.Padding = UDim.new(0,5)

-- OPEN MENU
openBtn.MouseButton1Click:Connect(function()
	menu.Visible = not menu.Visible
	playerFrame.Visible = false
end)

-- CLOSE MENU
closeBtn.MouseButton1Click:Connect(function()
	menu.Visible = false
	playerFrame.Visible = false
end)

-- MODE SWITCH
modeBtn.MouseButton1Click:Connect(function()

	if MODE == "Orbit" then
		MODE = "Under"

	elseif MODE == "Under" then
		MODE = "Behind"

	else
		MODE = "Orbit"
	end

	modeBtn.Text = "Mode : "..MODE
end)

-- SPEED
speedBox.FocusLost:Connect(function()

	local num = tonumber(speedBox.Text:match("%d+"))

	if num then
		SPEED = num
		speedBox.Text = tostring(num).." stud"
	end
end)

-- DISTANCE
distBox.FocusLost:Connect(function()

	local num = tonumber(distBox.Text:match("%d+"))

	if num then
		DISTANCE = num
		distBox.Text = tostring(num).." stud"
	end
end)

-- PLAYER LIST
local function refreshPlayers()

	for _,v in pairs(playerFrame:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	for _,plr in pairs(Players:GetPlayers()) do

		if plr ~= LocalPlayer then

			local btn = Instance.new("TextButton")
			btn.Parent = playerFrame
			btn.Size = UDim2.new(1,-10,0,35)
			btn.Text = plr.DisplayName
			btn.TextScaled = true
			btn.Font = Enum.Font.GothamBold
			btn.BackgroundColor3 = Color3.fromRGB(40,40,60)
			btn.TextColor3 = Color3.new(1,1,1)
			btn.BorderSizePixel = 0

			Instance.new("UICorner", btn)

			btn.MouseButton1Click:Connect(function()

				if TARGET == plr then

					TARGET = nil
					targetBtn.Text = "Select Target"
					btn.BackgroundColor3 = Color3.fromRGB(40,40,60)

				else

					TARGET = plr
					targetBtn.Text = "Target : "..plr.DisplayName

					for _,b in pairs(playerFrame:GetChildren()) do
						if b:IsA("TextButton") then
							b.BackgroundColor3 =
								Color3.fromRGB(40,40,60)
						end
					end

					btn.BackgroundColor3 =
						Color3.fromRGB(70,120,255)
				end
			end)
		end
	end

	task.wait()

	playerFrame.CanvasSize = UDim2.new(
		0,
		0,
		0,
		layout.AbsoluteContentSize.Y + 10
	)
end

-- TARGET MENU
targetBtn.MouseButton1Click:Connect(function()

	playerFrame.Visible = not playerFrame.Visible

	if playerFrame.Visible then
		refreshPlayers()
	end
end)

-- TOGGLE
toggleBtn.MouseButton1Click:Connect(function()

	enabled = not enabled

	if enabled then

		toggleBtn.Text = "ON"
		toggleBtn.BackgroundColor3 =
			Color3.fromRGB(70,120,255)

		orbitConnection =
			RunService.RenderStepped:Connect(function(dt)

			if not TARGET then return end
			if not TARGET.Character then return end

			local targetHRP =
				TARGET.Character:FindFirstChild(
					"HumanoidRootPart"
				)

			local char = LocalPlayer.Character

			if not char then return end

			local hrp =
				char:FindFirstChild(
					"HumanoidRootPart"
				)

			local humanoid =
				char:FindFirstChildOfClass(
					"Humanoid"
				)

			if not targetHRP or not hrp then
				return
			end

			-- SHIFTLOCK FIX
			if humanoid then
				humanoid.AutoRotate = false
			end

			local pos

			if MODE == "Orbit" then

				angle += SPEED * dt

				pos = targetHRP.Position +
					Vector3.new(
						math.cos(angle) * DISTANCE,
						0,
						math.sin(angle) * DISTANCE
					)

			elseif MODE == "Under" then

				pos = (
					targetHRP.CFrame *
					CFrame.new(0,-DISTANCE,0)
				).Position

			else

				pos = (
					targetHRP.CFrame *
					CFrame.new(0,0,DISTANCE)
				).Position
			end

			-- LOOK AT TARGET
			hrp.CFrame = CFrame.lookAt(
				pos,
				targetHRP.Position
			)
		end)

	else

		toggleBtn.Text = "OFF"
		toggleBtn.BackgroundColor3 =
			Color3.fromRGB(45,45,70)

		if orbitConnection then
			orbitConnection:Disconnect()
			orbitConnection = nil
		end

		local char = LocalPlayer.Character

		if char then

			local humanoid =
				char:FindFirstChildOfClass(
					"Humanoid"
				)

			if humanoid then
				humanoid.AutoRotate = true
			end
		end
	end
end)
