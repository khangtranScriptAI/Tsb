--// ORBIT GUI FULL - ENHANCED (PURPLE THEME V2)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- SETTINGS
local SPEED = 20
local DISTANCE = 5
local MODE = "Orbit"
local TARGET = nil

local enabled = false
local angle = 0
local orbitConnection
local lastCFrame = nil
local smoothLookAt = 0.15

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "OrbitGUI"
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- COLOR PALETTE
local purpleMain = Color3.fromRGB(130, 70, 240)
local purpleLight = Color3.fromRGB(170, 120, 255)
local purpleDark = Color3.fromRGB(60, 30, 130)
local purpleAccent = Color3.fromRGB(200, 160, 255)
local bg0 = Color3.fromRGB(12, 8, 20)
local bg1 = Color3.fromRGB(18, 14, 28)
local bg2 = Color3.fromRGB(24, 20, 35)
local bg3 = Color3.fromRGB(32, 28, 44)
local white = Color3.new(1, 1, 1)
local red = Color3.fromRGB(255, 60, 60)
local green = Color3.fromRGB(80, 220, 80)

-- ==================== MAIN TOGGLE BUTTON ====================
local mainToggle = Instance.new("Frame")
mainToggle.Parent = gui
mainToggle.Size = UDim2.new(0, 70, 0, 70)
mainToggle.Position = UDim2.new(0, 20, 0.5, -35)
mainToggle.BackgroundTransparency = 1
mainToggle.ZIndex = 10

local toggleButton = Instance.new("TextButton")
toggleButton.Parent = mainToggle
toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(0.5, -30, 0.5, -30)
toggleButton.BackgroundColor3 = bg1
toggleButton.Text = ""
toggleButton.BorderSizePixel = 0
toggleButton.Active = true
toggleButton.Draggable = true
toggleButton.ZIndex = 10

local toggleCorner = Instance.new("UICorner", toggleButton)
toggleCorner.CornerRadius = UDim.new(0, 16)

local toggleStroke = Instance.new("UIStroke", toggleButton)
toggleStroke.Color = purpleMain
toggleStroke.Thickness = 2.5
toggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Glow behind button
local glowEffect = Instance.new("ImageLabel")
glowEffect.Parent = mainToggle
glowEffect.Size = UDim2.new(0, 80, 0, 80)
glowEffect.Position = UDim2.new(0.5, -40, 0.5, -40)
glowEffect.BackgroundTransparency = 1
glowEffect.Image = "rbxassetid://6014261993"
glowEffect.ImageColor3 = purpleMain
glowEffect.ImageTransparency = 0.75
glowEffect.ZIndex = 9

-- Pulse glow
TweenService:Create(glowEffect, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1), {
    ImageTransparency = 0.85,
    Size = UDim2.new(0, 90, 0, 90),
    Position = UDim2.new(0.5, -45, 0.5, -45)
}):Play()

-- Center icon
local centerDot = Instance.new("Frame")
centerDot.Parent = toggleButton
centerDot.Size = UDim2.new(0, 14, 0, 14)
centerDot.Position = UDim2.new(0.5, -7, 0.5, -7)
centerDot.BackgroundColor3 = purpleLight
centerDot.BorderSizePixel = 0
centerDot.ZIndex = 11

local dotCorner = Instance.new("UICorner", centerDot)
dotCorner.CornerRadius = UDim.new(1, 0)

-- Orbiting dot
local orbitDot = Instance.new("Frame")
orbitDot.Parent = toggleButton
orbitDot.Size = UDim2.new(0, 6, 0, 6)
orbitDot.BackgroundColor3 = white
orbitDot.BorderSizePixel = 0
orbitDot.ZIndex = 11

local orbitDotCorner = Instance.new("UICorner", orbitDot)
orbitDotCorner.CornerRadius = UDim.new(1, 0)

-- Animate orbit dot
local orbitAngle = 0
RunService.RenderStepped:Connect(function(dt)
    if not mainToggle.Parent then return end
    orbitAngle = orbitAngle + 2 * dt
    local radius = 20
    orbitDot.Position = UDim2.new(0.5, math.cos(orbitAngle) * radius - 3, 0.5, math.sin(orbitAngle) * radius - 3)
end)

-- 15x15 Status Indicator
local statusDot = Instance.new("Frame")
statusDot.Parent = toggleButton
statusDot.Size = UDim2.new(0, 15, 0, 15)
statusDot.Position = UDim2.new(1, -18, 0, -5)
statusDot.BackgroundColor3 = red
statusDot.BorderSizePixel = 0
statusDot.ZIndex = 12

local statusCorner = Instance.new("UICorner", statusDot)
statusCorner.CornerRadius = UDim.new(0, 5)

local statusInnerDot = Instance.new("Frame")
statusInnerDot.Parent = statusDot
statusInnerDot.Size = UDim2.new(0, 6, 0, 6)
statusInnerDot.Position = UDim2.new(0.5, -3, 0.5, -3)
statusInnerDot.BackgroundColor3 = white
statusInnerDot.BackgroundTransparency = 0.3
statusInnerDot.BorderSizePixel = 0

local statusInnerCorner = Instance.new("UICorner", statusInnerDot)
statusInnerCorner.CornerRadius = UDim.new(1, 0)

-- ==================== MAIN MENU ====================
local menuContainer = Instance.new("Frame")
menuContainer.Parent = gui
menuContainer.Size = UDim2.new(0, 380, 0, 290)
menuContainer.Position = UDim2.new(0, 110, 0, 60)
menuContainer.BackgroundTransparency = 1
menuContainer.Visible = false
menuContainer.ZIndex = 5

-- Menu background
local menu = Instance.new("Frame")
menu.Parent = menuContainer
menu.Size = UDim2.new(0, 260, 0, 290)
menu.Position = UDim2.new(0, 0, 0, 0)
menu.BackgroundColor3 = bg0
menu.BorderSizePixel = 0
menu.Active = true
menu.Draggable = true
menu.ZIndex = 5

local menuCorner = Instance.new("UICorner", menu)
menuCorner.CornerRadius = UDim.new(0, 14)

local menuStroke = Instance.new("UIStroke", menu)
menuStroke.Color = purpleMain
menuStroke.Thickness = 1.5
menuStroke.Transparency = 0.4

-- Menu gradient
local menuGradient = Instance.new("UIGradient")
menuGradient.Parent = menu
menuGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 12, 30)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14, 10, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 16, 32))
})
menuGradient.Rotation = -30

-- ==================== TITLE BAR ====================
local titleBar = Instance.new("Frame")
titleBar.Parent = menu
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = purpleDark
titleBar.BackgroundTransparency = 0.5
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 6

local titleBarCorner = Instance.new("UICorner", titleBar)
titleBarCorner.CornerRadius = UDim.new(0, 14)

local titleGradient = Instance.new("UIGradient")
titleGradient.Parent = titleBar
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, purpleDark),
    ColorSequenceKeypoint.new(1, purpleMain)
})
titleGradient.Rotation = 90

local titleText = Instance.new("TextLabel")
titleText.Parent = titleBar
titleText.Size = UDim2.new(1, -50, 1, 0)
titleText.Position = UDim2.new(0, 14, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Orbit"
titleText.TextScaled = true
titleText.Font = Enum.Font.GothamBold
titleText.TextColor3 = white
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.TextSize = 18
titleText.ZIndex = 7

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titleBar
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0, 6)
closeBtn.Text = "✕"
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
closeBtn.TextColor3 = white
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 7

local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 8)

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = red
    }):Play()
end)

closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(40, 30, 60)
    }):Play()
end)

-- ==================== CONTENT ====================
-- Separator line
local sep = Instance.new("Frame")
sep.Parent = menu
sep.Position = UDim2.new(0, 12, 0, 46)
sep.Size = UDim2.new(1, -24, 0, 1)
sep.BackgroundColor3 = purpleMain
sep.BackgroundTransparency = 0.6
sep.BorderSizePixel = 0
sep.ZIndex = 6

-- MODE BUTTON
local modeBtn = Instance.new("TextButton")
modeBtn.Parent = menu
modeBtn.Position = UDim2.new(0, 12, 0, 55)
modeBtn.Size = UDim2.new(1, -24, 0, 34)
modeBtn.Text = "🌀 Orbit"
modeBtn.TextScaled = true
modeBtn.Font = Enum.Font.GothamBold
modeBtn.BackgroundColor3 = bg2
modeBtn.TextColor3 = white
modeBtn.BorderSizePixel = 0
modeBtn.ZIndex = 6

local modeCorner = Instance.new("UICorner", modeBtn)
modeCorner.CornerRadius = UDim.new(0, 8)

local modeStroke = Instance.new("UIStroke", modeBtn)
modeStroke.Color = purpleMain
modeStroke.Thickness = 1
modeStroke.Transparency = 0.5

-- SPEED INPUT
local speedLabel = Instance.new("TextLabel")
speedLabel.Parent = menu
speedLabel.Position = UDim2.new(0, 12, 0, 97)
speedLabel.Size = UDim2.new(0, 110, 0, 16)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed"
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Font = Enum.Font.GothamMedium
speedLabel.TextColor3 = purpleAccent
speedLabel.TextSize = 13
speedLabel.ZIndex = 6

local speedBox = Instance.new("TextBox")
speedBox.Parent = menu
speedBox.Position = UDim2.new(0, 12, 0, 115)
speedBox.Size = UDim2.new(0, 110, 0, 32)
speedBox.Text = tostring(SPEED)
speedBox.PlaceholderText = "20"
speedBox.TextScaled = true
speedBox.Font = Enum.Font.Gotham
speedBox.BackgroundColor3 = bg2
speedBox.TextColor3 = white
speedBox.BorderSizePixel = 0
speedBox.ZIndex = 6

local speedCorner = Instance.new("UICorner", speedBox)
speedCorner.CornerRadius = UDim.new(0, 8)

local speedStroke = Instance.new("UIStroke", speedBox)
speedStroke.Color = purpleMain
speedStroke.Thickness = 1
speedStroke.Transparency = 0.5

-- DISTANCE INPUT
local distLabel = Instance.new("TextLabel")
distLabel.Parent = menu
distLabel.Position = UDim2.new(0, 138, 0, 97)
distLabel.Size = UDim2.new(0, 110, 0, 16)
distLabel.BackgroundTransparency = 1
distLabel.Text = "Distance"
distLabel.TextXAlignment = Enum.TextXAlignment.Left
distLabel.Font = Enum.Font.GothamMedium
distLabel.TextColor3 = purpleAccent
distLabel.TextSize = 13
distLabel.ZIndex = 6

local distBox = Instance.new("TextBox")
distBox.Parent = menu
distBox.Position = UDim2.new(0, 138, 0, 115)
distBox.Size = UDim2.new(0, 110, 0, 32)
distBox.Text = tostring(DISTANCE)
distBox.PlaceholderText = "5"
distBox.TextScaled = true
distBox.Font = Enum.Font.Gotham
distBox.BackgroundColor3 = bg2
distBox.TextColor3 = white
distBox.BorderSizePixel = 0
distBox.ZIndex = 6

local distCorner = Instance.new("UICorner", distBox)
distCorner.CornerRadius = UDim.new(0, 8)

local distStroke = Instance.new("UIStroke", distBox)
distStroke.Color = purpleMain
distStroke.Thickness = 1
distStroke.Transparency = 0.5

-- TARGET BUTTON
local targetBtn = Instance.new("TextButton")
targetBtn.Parent = menu
targetBtn.Position = UDim2.new(0, 12, 0, 158)
targetBtn.Size = UDim2.new(1, -24, 0, 34)
targetBtn.Text = "🎯 Select Target"
targetBtn.TextScaled = true
targetBtn.Font = Enum.Font.GothamBold
targetBtn.BackgroundColor3 = purpleMain
targetBtn.TextColor3 = white
targetBtn.BorderSizePixel = 0
targetBtn.ZIndex = 6

local targetCorner = Instance.new("UICorner", targetBtn)
targetCorner.CornerRadius = UDim.new(0, 8)

local targetStroke = Instance.new("UIStroke", targetBtn)
targetStroke.Color = purpleLight
targetStroke.Thickness = 1
targetStroke.Transparency = 0.3

-- TOGGLE BUTTON
local toggleBtn = Instance.new("TextButton")
toggleBtn.Parent = menu
toggleBtn.Position = UDim2.new(0, 12, 0, 202)
toggleBtn.Size = UDim2.new(1, -24, 0, 36)
toggleBtn.Text = "DISABLED"
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BackgroundColor3 = bg2
toggleBtn.TextColor3 = white
toggleBtn.BorderSizePixel = 0
toggleBtn.ZIndex = 6

local toggleCorner = Instance.new("UICorner", toggleBtn)
toggleCorner.CornerRadius = UDim.new(0, 8)

local toggleBtnStroke = Instance.new("UIStroke", toggleBtn)
toggleBtnStroke.Color = red
toggleBtnStroke.Thickness = 1.5

-- 15x15 indicator on toggle button
local toggleIndicator = Instance.new("Frame")
toggleIndicator.Parent = toggleBtn
toggleIndicator.Size = UDim2.new(0, 15, 0, 15)
toggleIndicator.Position = UDim2.new(1, -20, 0.5, -7)
toggleIndicator.BackgroundColor3 = red
toggleIndicator.BorderSizePixel = 0
toggleIndicator.ZIndex = 7

local toggleIndCorner = Instance.new("UICorner", toggleIndicator)
toggleIndCorner.CornerRadius = UDim.new(0, 5)

local toggleIndDot = Instance.new("Frame")
toggleIndDot.Parent = toggleIndicator
toggleIndDot.Size = UDim2.new(0, 6, 0, 6)
toggleIndDot.Position = UDim2.new(0.5, -3, 0.5, -3)
toggleIndDot.BackgroundColor3 = white
toggleIndDot.BackgroundTransparency = 0.3
toggleIndDot.BorderSizePixel = 0

local toggleIndDotCorner = Instance.new("UICorner", toggleIndDot)
toggleIndDotCorner.CornerRadius = UDim.new(1, 0)

-- INFINITE YIELD
local infYield = Instance.new("TextLabel")
infYield.Parent = menu
infYield.Position = UDim2.new(0, 12, 0, 250)
infYield.Size = UDim2.new(1, -24, 0, 14)
infYield.BackgroundTransparency = 1
infYield.Text = "made by zen"
infYield.TextXAlignment = Enum.TextXAlignment.Center
infYield.Font = Enum.Font.GothamMedium
infYield.TextColor3 = purpleMain
infYield.TextTransparency = 0.6
infYield.TextSize = 11
infYield.ZIndex = 6

-- ==================== PLAYER LIST (Right side panel) ====================
local playerPanel = Instance.new("Frame")
playerPanel.Parent = menuContainer
playerPanel.Size = UDim2.new(0, 110, 0, 290)
playerPanel.Position = UDim2.new(0, 270, 0, 0)
playerPanel.BackgroundColor3 = bg0
playerPanel.BorderSizePixel = 0
playerPanel.Visible = false
playerPanel.ZIndex = 5

local playerPanelCorner = Instance.new("UICorner", playerPanel)
playerPanelCorner.CornerRadius = UDim.new(0, 14)

local playerPanelStroke = Instance.new("UIStroke", playerPanel)
playerPanelStroke.Color = purpleMain
playerPanelStroke.Thickness = 1.5
playerPanelStroke.Transparency = 0.4

-- Panel title
local panelTitle = Instance.new("Frame")
panelTitle.Parent = playerPanel
panelTitle.Size = UDim2.new(1, 0, 0, 38)
panelTitle.BackgroundColor3 = purpleDark
panelTitle.BackgroundTransparency = 0.5
panelTitle.BorderSizePixel = 0
panelTitle.ZIndex = 6

local panelTitleCorner = Instance.new("UICorner", panelTitle)
panelTitleCorner.CornerRadius = UDim.new(0, 14)

local panelTitleGradient = Instance.new("UIGradient")
panelTitleGradient.Parent = panelTitle
panelTitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, purpleDark),
    ColorSequenceKeypoint.new(1, purpleMain)
})
panelTitleGradient.Rotation = 90

local panelTitleText = Instance.new("TextLabel")
panelTitleText.Parent = panelTitle
panelTitleText.Size = UDim2.new(1, 0, 1, 0)
panelTitleText.BackgroundTransparency = 1
panelTitleText.Text = "Players"
panelTitleText.TextScaled = true
panelTitleText.Font = Enum.Font.GothamBold
panelTitleText.TextColor3 = white
panelTitleText.TextSize = 15
panelTitleText.ZIndex = 7

-- Player list scroller
local playerList = Instance.new("ScrollingFrame")
playerList.Parent = playerPanel
playerList.Position = UDim2.new(0, 6, 0, 46)
playerList.Size = UDim2.new(1, -12, 0, 236)
playerList.BackgroundTransparency = 1
playerList.ScrollBarThickness = 2
playerList.ScrollBarImageColor3 = purpleMain
playerList.BorderSizePixel = 0
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
playerList.ZIndex = 6

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = playerList
listLayout.Padding = UDim.new(0, 3)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.Name

-- Player list show/hide animation
local function showPlayerPanel()
    playerPanel.Visible = true
    playerPanel.Size = UDim2.new(0, 0, 0, 290)
    menu.Size = UDim2.new(0, 260, 0, 290)
    menuContainer.Size = UDim2.new(0, 260, 0, 290)
    
    TweenService:Create(playerPanel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 110, 0, 290)
    }):Play()
    
    TweenService:Create(menuContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 380, 0, 290)
    }):Play()
end

local function hidePlayerPanel()
    TweenService:Create(playerPanel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 290)
    }):Play()
    
    TweenService:Create(menuContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 260, 0, 290)
    }):Play()
    
    task.wait(0.2)
    playerPanel.Visible = false
    menu.Size = UDim2.new(0, 260, 0, 290)
end

-- Refresh player list
local function refreshPlayerList()
    for _, v in pairs(playerList:GetChildren()) do
        if v:IsA("TextButton") then
            v:Destroy()
        end
    end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Parent = playerList
            btn.Size = UDim2.new(1, 0, 0, 26)
            btn.Text = plr.DisplayName
            btn.TextScaled = true
            btn.Font = Enum.Font.GothamMedium
            btn.BackgroundColor3 = (TARGET == plr) and purpleMain or bg2
            btn.TextColor3 = white
            btn.BorderSizePixel = 0
            btn.ZIndex = 7
            btn.TextSize = 12
            
            local btnCorner = Instance.new("UICorner", btn)
            btnCorner.CornerRadius = UDim.new(0, 6)
            
            btn.MouseEnter:Connect(function()
                if TARGET ~= plr then
                    TweenService:Create(btn, TweenInfo.new(0.15), {
                        BackgroundColor3 = bg3
                    }):Play()
                end
            end)
            
            btn.MouseLeave:Connect(function()
                if TARGET ~= plr then
                    TweenService:Create(btn, TweenInfo.new(0.15), {
                        BackgroundColor3 = bg2
                    }):Play()
                end
            end)
            
            btn.MouseButton1Click:Connect(function()
                if TARGET == plr then
                    TARGET = nil
                    targetBtn.Text = "🎯 Select Target"
                    TweenService:Create(btn, TweenInfo.new(0.15), {
                        BackgroundColor3 = bg2
                    }):Play()
                else
                    for _, b in pairs(playerList:GetChildren()) do
                        if b:IsA("TextButton") then
                            TweenService:Create(b, TweenInfo.new(0.15), {
                                BackgroundColor3 = bg2
                            }):Play()
                        end
                    end
                    TARGET = plr
                    targetBtn.Text = "🎯 " .. plr.DisplayName
                    TweenService:Create(btn, TweenInfo.new(0.15), {
                        BackgroundColor3 = purpleMain
                    }):Play()
                end
            end)
        end
    end
    
    task.wait()
    playerList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 6)
end

-- ==================== FUNCTIONALITY ====================
local playerListVisible = false

targetBtn.MouseButton1Click:Connect(function()
    playerListVisible = not playerListVisible
    if playerListVisible then
        showPlayerPanel()
        refreshPlayerList()
    else
        hidePlayerPanel()
    end
end)

mainToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        menuContainer.Visible = not menuContainer.Visible
        if not menuContainer.Visible then
            playerListVisible = false
            hidePlayerPanel()
        end
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        enabled = not enabled
        if enabled then
            enableOrbit()
        else
            disableOrbit()
        end
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    menuContainer.Visible = false
    playerListVisible = false
    hidePlayerPanel()
end)

-- MODE
modeBtn.MouseButton1Click:Connect(function()
    if MODE == "Orbit" then
        MODE = "Under"
        modeBtn.Text = "⬇️ Under"
    elseif MODE == "Under" then
        MODE = "Behind"
        modeBtn.Text = "👁️ Behind"
    else
        MODE = "Orbit"
        modeBtn.Text = "🌀 Orbit"
    end
    
    TweenService:Create(modeBtn, TweenInfo.new(0.08), {
        Size = UDim2.new(1, -28, 0, 32)
    }):Play()
    task.wait(0.08)
    TweenService:Create(modeBtn, TweenInfo.new(0.08), {
        Size = UDim2.new(1, -24, 0, 34)
    }):Play()
end)

-- SPEED
speedBox.FocusLost:Connect(function()
    local num = tonumber(speedBox.Text:match("%d+%.?%d*"))
    if num and num > 0 then
        SPEED = num
        speedBox.Text = tostring(num)
    else
        speedBox.Text = tostring(SPEED)
    end
end)

-- DISTANCE
distBox.FocusLost:Connect(function()
    local num = tonumber(distBox.Text:match("%d+%.?%d*"))
    if num and num > 0 then
        DISTANCE = num
        distBox.Text = tostring(num)
    else
        distBox.Text = tostring(DISTANCE)
    end
end)

-- ENABLE/DISABLE ORBIT
function enableOrbit()
    enabled = true
    toggleBtn.Text = "ENABLED"
    
    TweenService:Create(toggleBtn, TweenInfo.new(0.25), {
        BackgroundColor3 = purpleMain
    }):Play()
    TweenService:Create(toggleBtnStroke, TweenInfo.new(0.25), {
        Color = green
    }):Play()
    TweenService:Create(toggleIndicator, TweenInfo.new(0.25), {
        BackgroundColor3 = green
    }):Play()
    TweenService:Create(statusDot, TweenInfo.new(0.25), {
        BackgroundColor3 = green
    }):Play()
    
    lastCFrame = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.CFrame
    
    orbitConnection = RunService.RenderStepped:Connect(function(dt)
        if not TARGET or not TARGET.Character then return end
        
        local targetHRP = TARGET.Character:FindFirstChild("HumanoidRootPart")
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not targetHRP or not hrp then return end
        
        if humanoid then humanoid.AutoRotate = false end
        
        local targetPos, lookTarget = targetHRP.Position, targetHRP.Position
        
        if MODE == "Orbit" then
            angle = angle + SPEED * dt
            targetPos = targetHRP.Position + Vector3.new(math.cos(angle) * DISTANCE, 0, math.sin(angle) * DISTANCE)
        elseif MODE == "Under" then
            targetPos = (targetHRP.CFrame * CFrame.new(0, -DISTANCE, 0)).Position
        else
            targetPos = (targetHRP.CFrame * CFrame.new(0, 0, DISTANCE)).Position
        end
        
        local targetCFrame = CFrame.lookAt(targetPos, lookTarget)
        if not lastCFrame then lastCFrame = targetCFrame end
        local smoothed = lastCFrame:Lerp(targetCFrame, 1 - math.exp(-smoothLookAt * 60 * dt))
        hrp.CFrame = smoothed
        lastCFrame = smoothed
    end)
end

function disableOrbit()
    enabled = false
    toggleBtn.Text = "DISABLED"
    
    TweenService:Create(toggleBtn, TweenInfo.new(0.25), {
        BackgroundColor3 = bg2
    }):Play()
    TweenService:Create(toggleBtnStroke, TweenInfo.new(0.25), {
        Color = red
    }):Play()
    TweenService:Create(toggleIndicator, TweenInfo.new(0.25), {
        BackgroundColor3 = red
    }):Play()
    TweenService:Create(statusDot, TweenInfo.new(0.25), {
        BackgroundColor3 = red
    }):Play()
    
    if orbitConnection then
        orbitConnection:Disconnect()
        orbitConnection = nil
    end
    lastCFrame = nil
    
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.AutoRotate = true end
    end
end

toggleBtn.MouseButton1Click:Connect(function()
    if enabled then disableOrbit() else enableOrbit() end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    if enabled then
        task.wait(0.5)
        lastCFrame = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.CFrame
    end
end)
