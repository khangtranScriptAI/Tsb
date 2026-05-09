local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local Character = lp.Character or lp.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")

-- ==================== DATA ====================
local AnimationIds = {}

-- ==================== UI ====================
local screen = Instance.new("ScreenGui")
screen.Name = "DashMenu"
screen.ResetOnSpawn = false
screen.Parent = lp:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 230)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Parent = screen

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "Animation Dash Menu"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = frame

-- ==================== INPUT ====================
local input = Instance.new("TextBox")
input.Size = UDim2.new(0,220,0,35)
input.Position = UDim2.new(0,20,0,50)
input.PlaceholderText = "Nhập Animation ID"
input.Text = ""
input.TextColor3 = Color3.new(1,1,1)
input.BackgroundColor3 = Color3.fromRGB(40,40,40)
input.Font = Enum.Font.Gotham
input.TextScaled = true
input.Parent = frame

Instance.new("UICorner", input).CornerRadius = UDim.new(0,8)

-- ==================== TIME LABEL ====================
local timeLabel = Instance.new("TextLabel")
timeLabel.Size = UDim2.new(0,220,0,35)
timeLabel.Position = UDim2.new(0,20,0,95)
timeLabel.BackgroundColor3 = Color3.fromRGB(35,35,35)
timeLabel.Text = "Thời gian: ..."
timeLabel.TextColor3 = Color3.new(1,1,1)
timeLabel.Font = Enum.Font.GothamBold
timeLabel.TextScaled = true
timeLabel.Parent = frame

Instance.new("UICorner", timeLabel).CornerRadius = UDim.new(0,8)

-- ==================== ADD BUTTON ====================
local addButton = Instance.new("TextButton")
addButton.Size = UDim2.new(0,220,0,35)
addButton.Position = UDim2.new(0,20,0,140)
addButton.BackgroundColor3 = Color3.fromRGB(0,170,255)
addButton.Text = "Add Animation"
addButton.TextColor3 = Color3.new(1,1,1)
addButton.Font = Enum.Font.GothamBold
addButton.TextScaled = true
addButton.Parent = frame

Instance.new("UICorner", addButton).CornerRadius = UDim.new(0,8)

-- ==================== LIST ====================
local listLabel = Instance.new("TextLabel")
listLabel.Size = UDim2.new(0,220,0,40)
listLabel.Position = UDim2.new(0,20,0,185)
listLabel.BackgroundTransparency = 1
listLabel.Text = "Animations: 0"
listLabel.TextColor3 = Color3.new(1,1,1)
listLabel.Font = Enum.Font.Gotham
listLabel.TextScaled = true
listLabel.Parent = frame

-- ==================== GET LENGTH ====================
local function getAnimationLength(id)
    local success, result = pcall(function()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. id

        local track = Animator:LoadAnimation(anim)

        task.wait(0.5)

        return track.Length
    end)

    if success then
        return result
    end

    return nil
end

-- ==================== ADD ====================
addButton.MouseButton1Click:Connect(function()
    local id = input.Text:gsub("rbxassetid://", "")

    if id == "" then
        return
    end

    AnimationIds["rbxassetid://" .. id] = true

    listLabel.Text = "Animations: " .. tostring(#(function()
        local t = {}
        for k,v in pairs(AnimationIds) do
            table.insert(t,k)
        end
        return t
    end)())

    local len = getAnimationLength(id)

    if len and len > 0 then
        timeLabel.Text = string.format("Thời gian: %.2fs", len)
    else
        timeLabel.Text = "Không lấy được thời gian"
    end

    print("Added Animation:", id)
end)

-- ==================== EXAMPLE CHECK ====================
local debounce = false

local function StickDash()
    print("DASH 🔥")
end

Humanoid.AnimationPlayed:Connect(function(track)
    if debounce then return end

    if track.Animation and AnimationIds[track.Animation.AnimationId] then
        debounce = true

        print("Matched:", track.Animation.AnimationId)

        task.wait(1.7)

        StickDash()

        debounce = false
    end
end)

print("Animation Dash Menu Loaded 🔥")
