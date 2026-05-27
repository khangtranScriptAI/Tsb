--// ORBIT GUI FULL - ENHANCED (PURPLE THEME)

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
local smoothLookAt = 0.12 -- Smoothing for look-at

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "OrbitGUI"
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- PURPLE COLOR PALETTE
local purplePrimary = Color3.fromRGB(140, 80, 255)
local purpleDark = Color3.fromRGB(80, 40, 160)
local purpleLight = Color3.fromRGB(180, 140, 255)
local purpleAccent = Color3.fromRGB(200, 160, 255)
local bgDark = Color3.fromRGB(20, 15, 30)
local bgMedium = Color3.fromRGB(30, 25, 45)
local bgLight = Color3.fromRGB(40, 35, 55)

-- MAIN TOGGLE BUTTON
local mainToggle = Instance.new("TextButton")
mainToggle.Parent = gui
mainToggle.Size = UDim2.new(0, 85, 0, 85)
mainToggle.Position = UDim2.new(0, 25, 0.5, -42)
mainToggle.BackgroundColor3 = bgMedium
mainToggle.Text = ""
mainToggle.BorderSizePixel = 0
mainToggle.Active = true
mainToggle.Draggable = true
mainToggle.ZIndex = 10

local corner = Instance.new("UICorner", mainToggle)
corner.CornerRadius = UDim.new(1, 0)

local stroke = Instance.new("UIStroke", mainToggle)
stroke.Color = purplePrimary
stroke.Thickness = 3
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Glow effect
local glow = Instance.new("ImageLabel")
glow.Parent = mainToggle
glow.Size = UDim2.new(0, 110, 0, 110)
glow.Position = UDim2.new(0.5, -55, 0.5, -55)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://6014261993"
glow.ImageColor3 = purplePrimary
glow.ImageTransparency = 0.7
glow.ZIndex = 9

-- Pulsing glow animation
local pulseTween = TweenService:Create(glow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1), {
    ImageTransparency = 0.85,
    Size = UDim2.new(0, 120, 0, 120),
    Position = UDim2.new(0.5, -60, 0.5, -60)
})
pulseTween:Play()

-- Orbital icon
local iconFrame = Instance.new("Frame")
iconFrame.Parent = mainToggle
iconFrame.Size = UDim2.new(0, 50, 0, 50)
iconFrame.Position = UDim2.new(0.5, -25, 0.5, -25)
iconFrame.BackgroundTransparency = 1
iconFrame.ZIndex = 11

local iconCircle = Instance.new("Frame")
iconCircle.Parent = iconFrame
iconCircle.Size = UDim2.new(0, 30, 0, 30)
iconCircle.Position = UDim2.new(0.5, -15, 0.5, -15)
iconCircle.BackgroundColor3 = purpleLight
iconCircle.BorderSizePixel = 0

local iconCorner = Instance.new("UICorner", iconCircle)
iconCorner.CornerRadius = UDim.new(1, 0)

local iconDot = Instance.new("Frame")
iconDot.Parent = iconFrame
iconDot.Size = UDim2.new(0, 8, 0, 8)
iconDot.Position = UDim2.new(0.7, -4, 0.3, -4)
iconDot.BackgroundColor3 = Color3.new(1, 1, 1)
iconDot.BorderSizePixel = 0

local dotCorner = Instance.new("UICorner", iconDot)
dotCorner.CornerRadius = UDim.new(1, 0)

-- Status indicator
local statusIndicator = Instance.new("Frame")
statusIndicator.Parent = mainToggle
statusIndicator.Size = UDim2.new(0, 16, 0, 16)
statusIndicator.Position = UDim2.new(1, -22, 0, -6)
statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
statusIndicator.BorderSizePixel = 0
statusIndicator.ZIndex = 12

local indicatorCorner = Instance.new("UICorner", statusIndicator)
indicatorCorner.CornerRadius = UDim.new(1, 0)

local indicatorStroke = Instance.new("UIStroke", statusIndicator)
indicatorStroke.Color = Color3.fromRGB(255, 255, 255)
indicatorStroke.Thickness = 2

-- MAIN MENU
local menu = Instance.new("Frame")
menu.Parent = gui
menu.Size = UDim2.new(0, 440, 0, 370)
menu.Position = UDim2.new(0, 130, 0, 70)
menu.BackgroundColor3 = bgDark
menu.BackgroundTransparency = 0.05
menu.BorderSizePixel = 0
menu.Active = true
menu.Draggable = true
menu.Visible = false
menu.ZIndex = 5
menu.ClipsDescendants = true

local menuCorner = Instance.new("UICorner", menu)
menuCorner.CornerRadius = UDim.new(0, 16)

local menuStroke = Instance.new("UIStroke", menu)
menuStroke.Color = purplePrimary
menuStroke.Thickness = 2
menuStroke.Transparency = 0.2

-- Menu gradient
local menuGradient = Instance.new("UIGradient")
menuGradient.Parent = menu
menuGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, bgDark),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 20, 40)),
    ColorSequenceKeypoint.new(1, bgMedium)
})
menuGradient.Rotation = 135

-- Menu open animation
local menuOpenTween = TweenService:Create(menu, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 440, 0, 370),
    BackgroundTransparency = 0.05
})

-- TITLE BAR
local titleBar = Instance.new("Frame")
titleBar.Parent = menu
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = purpleDark
titleBar.BackgroundTransparency = 0.3
titleBar.BorderSizePixel = 0

local titleBarCorner = Instance.new("UICorner", titleBar)
titleBarCorner.CornerRadius = UDim.new(0, 16)

local titleBarGradient = Instance.new("UIGradient")
titleBarGradient.Parent = titleBar
titleBarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, purplePrimary),
    ColorSequenceKeypoint.new(1, purpleDark)
})
titleBarGradient.Rotation = 90

local title = Instance.new("TextLabel")
title.Parent = titleBar
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "✦ Orbit Controller"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 6

-- CLOSE BUTTON
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titleBar
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -42, 0, 9)
closeBtn.Text = "✕"
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 6

local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(1, 0)

-- Close button hover effect
closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    }):Play()
end)

closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    }):Play()
end)

-- TOGGLE BUTTON
local toggleBtn = Instance.new("TextButton")
toggleBtn.Parent = menu
toggleBtn.Position = UDim2.new(0, 20, 0, 65)
toggleBtn.Size = UDim2.new(0, 190, 0, 50)
toggleBtn.Text = "DISABLED"
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BackgroundColor3 = bgMedium
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.BorderSizePixel = 0
toggleBtn.ZIndex = 6

local toggleCorner = Instance.new("UICorner", toggleBtn)
toggleCorner.CornerRadius = UDim.new(0, 10)

local toggleStroke = Instance.new("UIStroke", toggleBtn)
toggleStroke.Color = Color3.fromRGB(255, 80, 80)
toggleStroke.Thickness = 2

-- MODE BUTTON
local modeBtn = Instance.new("TextButton")
modeBtn.Parent = menu
modeBtn.Position = UDim2.new(0, 230, 0, 65)
modeBtn.Size = UDim2.new(0, 190, 0, 50)
modeBtn.Text = "🌀 Orbit"
modeBtn.TextScaled = true
modeBtn.Font = Enum.Font.GothamBold
modeBtn.BackgroundColor3 = purplePrimary
modeBtn.TextColor3 = Color3.new(1, 1, 1)
modeBtn.BorderSizePixel = 0
modeBtn.ZIndex = 6

local modeCorner = Instance.new("UICorner", modeBtn)
modeCorner.CornerRadius = UDim.new(0, 10)

local modeStroke = Instance.new("UIStroke", modeBtn)
modeStroke.Color = purpleLight
modeStroke.Thickness = 1

-- MODE ICONS
local modeIcons = {
    Orbit = "🌀",
    Under = "⬇️", 
    Behind = "👁️"
}

-- SEPARATOR
local separator = Instance.new("Frame")
separator.Parent = menu
separator.Position = UDim2.new(0, 20, 0, 130)
separator.Size = UDim2.new(1, -40, 0, 2)
separator.BackgroundColor3 = purplePrimary
separator.BackgroundTransparency = 0.7
separator.BorderSizePixel = 0
separator.ZIndex = 6

-- SPEED SECTION
local speedLabel = Instance.new("TextLabel")
speedLabel.Parent = menu
speedLabel.Position = UDim2.new(0, 20, 0, 145)
speedLabel.Size = UDim2.new(0, 190, 0, 22)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "⚡ SPEED"
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextColor3 = purpleLight
speedLabel.TextSize = 16
speedLabel.ZIndex = 6

local speedBox = Instance.new("TextBox")
speedBox.Parent = menu
speedBox.Position = UDim2.new(0, 20, 0, 172)
speedBox.Size = UDim2.new(0, 190, 0, 45)
speedBox.Text = tostring(SPEED)
speedBox.PlaceholderText = "Speed value..."
speedBox.TextScaled = true
speedBox.Font = Enum.Font.Gotham
speedBox.BackgroundColor3 = bgMedium
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.BorderSizePixel = 0
speedBox.ZIndex = 6

local speedCorner = Instance.new("UICorner", speedBox)
speedCorner.CornerRadius = UDim.new(0, 10)

local speedStroke = Instance.new("UIStroke", speedBox)
speedStroke.Color = purplePrimary
speedStroke.Thickness = 1
speedStroke.Transparency = 0.5

-- Speed label
local speedUnit = Instance.new("TextLabel")
speedUnit.Parent = speedBox
speedUnit.Size = UDim2.new(0, 50, 1, 0)
speedUnit.Position = UDim2.new(1, -55, 0, 0)
speedUnit.BackgroundTransparency = 1
speedUnit.Text = "rad/s"
speedUnit.TextScaled = true
speedUnit.Font = Enum.Font.Gotham
speedUnit.TextColor3 = Color3.fromRGB(180, 140, 255)
speedUnit.TextXAlignment = Enum.TextXAlignment.Right
speedUnit.ZIndex = 7

-- DISTANCE SECTION
local distLabel = Instance.new("TextLabel")
distLabel.Parent = menu
distLabel.Position = UDim2.new(0, 230, 0, 145)
distLabel.Size = UDim2.new(0, 190, 0, 22)
distLabel.BackgroundTransparency = 1
distLabel.Text = "📏 DISTANCE"
distLabel.TextXAlignment = Enum.TextXAlignment.Left
distLabel.Font = Enum.Font.GothamBold
distLabel.TextColor3 = purpleLight
distLabel.TextSize = 16
distLabel.ZIndex = 6

local distBox = Instance.new("TextBox")
distBox.Parent = menu
distBox.Position = UDim2.new(0, 230, 0, 172)
distBox.Size = UDim2.new(0, 190, 0, 45)
distBox.Text = tostring(DISTANCE)
distBox.PlaceholderText = "Distance value..."
distBox.TextScaled = true
distBox.Font = Enum.Font.Gotham
distBox.BackgroundColor3 = bgMedium
distBox.TextColor3 = Color3.new(1, 1, 1)
distBox.BorderSizePixel = 0
distBox.ZIndex = 6

local distCorner = Instance.new("UICorner", distBox)
distCorner.CornerRadius = UDim.new(0, 10)

local distStroke = Instance.new("UIStroke", distBox)
distStroke.Color = purplePrimary
distStroke.Thickness = 1
distStroke.Transparency = 0.5

-- Distance label
local distUnit = Instance.new("TextLabel")
distUnit.Parent = distBox
distUnit.Size = UDim2.new(0, 60, 1, 0)
distUnit.Position = UDim2.new(1, -65, 0, 0)
distUnit.BackgroundTransparency = 1
distUnit.Text = "studs"
distUnit.TextScaled = true
distUnit.Font = Enum.Font.Gotham
distUnit.TextColor3 = Color3.fromRGB(180, 140, 255)
distUnit.TextXAlignment = Enum.TextXAlignment.Right
distUnit.ZIndex = 7

-- SEPARATOR 2
local separator2 = Instance.new("Frame")
separator2.Parent = menu
separator2.Position = UDim2.new(0, 20, 0, 232)
separator2.Size = UDim2.new(1, -40, 0, 2)
separator2.BackgroundColor3 = purplePrimary
separator2.BackgroundTransparency = 0.7
separator2.BorderSizePixel = 0
separator2.ZIndex = 6

-- TARGET BUTTON
local targetBtn = Instance.new("TextButton")
targetBtn.Parent = menu
targetBtn.Position = UDim2.new(0, 20, 0, 245)
targetBtn.Size = UDim2.new(1, -40, 0, 50)
targetBtn.Text = "🎯 Select Target"
targetBtn.TextScaled = true
targetBtn.Font = Enum.Font.GothamBold
targetBtn.BackgroundColor3 = purplePrimary
targetBtn.TextColor3 = Color3.new(1, 1, 1)
targetBtn.BorderSizePixel = 0
targetBtn.ZIndex = 6

local targetCorner = Instance.new("UICorner", targetBtn)
targetCorner.CornerRadius = UDim.new(0, 10)

local targetStroke = Instance.new("UIStroke", targetBtn)
targetStroke.Color = purpleLight
targetStroke.Thickness = 1

-- PLAYER LIST
local playerFrame = Instance.new("ScrollingFrame")
playerFrame.Parent = menu
playerFrame.Position = UDim2.new(0, 20, 0, 310)
playerFrame.Size = UDim2.new(1, -40, 0, 0)
playerFrame.BackgroundColor3 = bgMedium
playerFrame.BackgroundTransparency = 0.5
playerFrame.Visible = false
playerFrame.ScrollBarThickness = 3
playerFrame.ScrollBarImageColor3 = purplePrimary
playerFrame.BorderSizePixel = 0
playerFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playerFrame.ZIndex = 6

local playerCorner = Instance.new("UICorner", playerFrame)
playerCorner.CornerRadius = UDim.new(0, 10)

local playerListStroke = Instance.new("UIStroke", playerFrame)
playerListStroke.Color = purplePrimary
playerListStroke.Thickness = 1
playerListStroke.Transparency = 0.5

local layout = Instance.new("UIListLayout")
layout.Parent = playerFrame
layout.Padding = UDim.new(0, 5)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.Name

local padding = Instance.new("UIPadding")
padding.Parent = playerFrame
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 5)
padding.PaddingRight = UDim.new(0, 5)

-- Player list open animation
local function animatePlayerList(open)
    if open then
        playerFrame.Visible = true
        TweenService:Create(playerFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, -40, 0, 180),
            BackgroundTransparency = 0.5
        }):Play()
        
        TweenService:Create(menu, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 440, 0, 510)
        }):Play()
    else
        TweenService:Create(playerFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(1, -40, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        
        TweenService:Create(menu, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 440, 0, 370)
        }):Play()
        
        task.wait(0.3)
        playerFrame.Visible = false
    end
end

-- OPEN MENU
mainToggle.MouseButton1Click:Connect(function()
    if menu.Visible then
        menu.Visible = false
        playerFrame.Visible = false
        menu.Size = UDim2.new(0, 440, 0, 370)
        playerFrame.Size = UDim2.new(1, -40, 0, 0)
    else
        menu.Visible = true
        menu.Size = UDim2.new(0, 440, 0, 0)
        menuOpenTween:Play()
    end
end)

-- CLOSE MENU
closeBtn.MouseButton1Click:Connect(function()
    menu.Visible = false
    playerFrame.Visible = false
    menu.Size = UDim2.new(0, 440, 0, 370)
    playerFrame.Size = UDim2.new(1, -40, 0, 0)
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
    
    modeBtn.Text = modeIcons[MODE] .. " " .. MODE
    
    -- Button press animation
    TweenService:Create(modeBtn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 185, 0, 48)
    }):Play()
    
    task.wait(0.1)
    
    TweenService:Create(modeBtn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 190, 0, 50)
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

-- PLAYER LIST
local function refreshPlayers()
    for _, v in pairs(playerFrame:GetChildren()) do
        if v:IsA("TextButton") then
            v:Destroy()
        end
    end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Parent = playerFrame
            btn.Size = UDim2.new(1, -10, 0, 38)
            btn.Text = plr.DisplayName
            btn.TextScaled = true
            btn.Font = Enum.Font.GothamBold
            btn.BackgroundColor3 = bgLight
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.BorderSizePixel = 0
            btn.ZIndex = 7
            
            local btnCorner = Instance.new("UICorner", btn)
            btnCorner.CornerRadius = UDim.new(0, 8)
            
            if TARGET == plr then
                btn.BackgroundColor3 = purplePrimary
            end
            
            -- Hover effects
            btn.MouseEnter:Connect(function()
                if TARGET ~= plr then
                    TweenService:Create(btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(60, 50, 80)
                    }):Play()
                end
            end)
            
            btn.MouseLeave:Connect(function()
                if TARGET ~= plr then
                    TweenService:Create(btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = bgLight
                    }):Play()
                end
            end)
            
            btn.MouseButton1Click:Connect(function()
                if TARGET == plr then
                    TARGET = nil
                    targetBtn.Text = "🎯 Select Target"
                    
                    TweenService:Create(btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = bgLight
                    }):Play()
                else
                    -- Reset all buttons
                    for _, b in pairs(playerFrame:GetChildren()) do
                        if b:IsA("TextButton") then
                            TweenService:Create(b, TweenInfo.new(0.2), {
                                BackgroundColor3 = bgLight
                            }):Play()
                        end
                    end
                    
                    TARGET = plr
                    targetBtn.Text = "🎯 Target: " .. plr.DisplayName
                    
                    TweenService:Create(btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = purplePrimary
                    }):Play()
                end
            end)
        end
    end
    
    task.wait()
    playerFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 15)
end

-- TARGET MENU
local playerListOpen = false

targetBtn.MouseButton1Click:Connect(function()
    playerListOpen = not playerListOpen
    animatePlayerList(playerListOpen)
    
    if playerListOpen then
        refreshPlayers()
    end
end)

-- TOGGLE BUTTON FUNCTIONS
local function enableOrbit()
    enabled = true
    toggleBtn.Text = "ENABLED"
    
    -- Animate toggle button
    TweenService:Create(toggleBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = purplePrimary
    }):Play()
    
    TweenService:Create(toggleStroke, TweenInfo.new(0.3), {
        Color = Color3.fromRGB(140, 255, 100)
    }):Play()
    
    -- Update main toggle indicator
    TweenService:Create(statusIndicator, TweenInfo.new(0.3), {
        BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    }):Play()
    
    -- Start orbit
    lastCFrame = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.CFrame
    
    orbitConnection = RunService.RenderStepped:Connect(function(dt)
        if not TARGET then return end
        if not TARGET.Character then return end
        
        local targetHRP = TARGET.Character:FindFirstChild("HumanoidRootPart")
        local char = LocalPlayer.Character
        
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        
        if not targetHRP or not hrp then return end
        
        -- Disable auto rotate
        if humanoid then
            humanoid.AutoRotate = false
        end
        
        -- Calculate position based on mode
        local targetPos
        local lookTarget = targetHRP.Position
        
        if MODE == "Orbit" then
            angle = angle + SPEED * dt
            
            targetPos = targetHRP.Position + Vector3.new(
                math.cos(angle) * DISTANCE,
                0,
                math.sin(angle) * DISTANCE
            )
            
        elseif MODE == "Under" then
            targetPos = (targetHRP.CFrame * CFrame.new(0, -DISTANCE, 0)).Position
            
        else -- Behind
            targetPos = (targetHRP.CFrame * CFrame.new(0, 0, DISTANCE)).Position
        end
        
        -- Smooth look-at using lerp
        local targetCFrame = CFrame.lookAt(targetPos, lookTarget)
        
        if not lastCFrame then
            lastCFrame = targetCFrame
        end
        
        -- Smooth interpolation for look-at
        local smoothedCFrame = lastCFrame:Lerp(targetCFrame, 1 - math.exp(-smoothLookAt * 60 * dt))
        hrp.CFrame = smoothedCFrame
        
        lastCFrame = smoothedCFrame
    end)
end

local function disableOrbit()
    enabled = false
    toggleBtn.Text = "DISABLED"
    
    -- Animate toggle button
    TweenService:Create(toggleBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = bgMedium
    }):Play()
    
    TweenService:Create(toggleStroke, TweenInfo.new(0.3), {
        Color = Color3.fromRGB(255, 80, 80)
    }):Play()
    
    -- Update main toggle indicator
    TweenService:Create(statusIndicator, TweenInfo.new(0.3), {
        BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    }):Play()
    
    -- Stop orbit
    if orbitConnection then
        orbitConnection:Disconnect()
        orbitConnection = nil
    end
    
    lastCFrame = nil
    
    -- Re-enable auto rotate
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.AutoRotate = true
        end
    end
end

-- TOGGLE
toggleBtn.MouseButton1Click:Connect(function()
    if enabled then
        disableOrbit()
    else
        enableOrbit()
    end
end)

-- Main toggle quick enable/disable (right click)
mainToggle.MouseButton2Click:Connect(function()
    if enabled then
        disableOrbit()
    else
        enableOrbit()
    end
end)

-- Cleanup on character removal
LocalPlayer.CharacterAdded:Connect(function(char)
    if enabled then
        task.wait(0.5) -- Wait for character to load
        lastCFrame = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.CFrame
    end
end)

-- Initial state
toggleBtn.Text = "DISABLED"
