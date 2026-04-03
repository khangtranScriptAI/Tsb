local VirtualInputManager = game:GetService("VirtualInputManager")
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.CoreGui

local dragLocked = false

local techButton = Instance.new("TextButton")
techButton.Parent = screenGui
techButton.Size = UDim2.new(0, 70, 0, 70)
techButton.Position = UDim2.new(0.5, -35, 0.8, 0)
techButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
techButton.Text = "Tech"
techButton.TextColor3 = Color3.fromRGB(255, 255, 255)
techButton.TextScaled = true
techButton.Font = Enum.Font.GothamBold
techButton.BorderSizePixel = 0
techButton.Active = true
techButton.Draggable = true

local techCorner = Instance.new("UICorner")
techCorner.CornerRadius = UDim.new(1, 0)
techCorner.Parent = techButton

local techStroke = Instance.new("UIStroke")
techStroke.Thickness = 2
techStroke.Color = Color3.fromRGB(255, 255, 255)
techStroke.Parent = techButton

local lockButton = Instance.new("TextButton")
lockButton.Parent = screenGui
lockButton.Size = UDim2.new(0, 35, 0, 35)
lockButton.Position = UDim2.new(0.5, 40, 0.8, 35)
lockButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
lockButton.Text = "🔓"
lockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
lockButton.TextScaled = true
lockButton.Font = Enum.Font.GothamBold
lockButton.BorderSizePixel = 0
lockButton.Active = true
lockButton.Draggable = true

local lockCorner = Instance.new("UICorner")
lockCorner.CornerRadius = UDim.new(1, 0)
lockCorner.Parent = lockButton

local lockStroke = Instance.new("UIStroke")
lockStroke.Thickness = 2
lockStroke.Color = Color3.fromRGB(255, 255, 255)
lockStroke.Parent = lockButton

local function doTech()
    local originalCFrame = camera.CFrame

    camera.CFrame = camera.CFrame * CFrame.Angles(0, math.rad(180), 0)

    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    task.wait()
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)

    task.wait(0.25)

    camera.CFrame = originalCFrame
end

techButton.MouseButton1Click:Connect(function()
    doTech()
end)

lockButton.MouseButton1Click:Connect(function()
    dragLocked = not dragLocked

    if dragLocked then
        techButton.Active = false
        techButton.Draggable = false

        lockButton.Draggable = false
        lockButton.Text = "🔒"
    else
        techButton.Active = true
        techButton.Draggable = true

        lockButton.Active = true
        lockButton.Draggable = true
        lockButton.Text = "🔓"
    end
end)