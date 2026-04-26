local player = game.Players.LocalPlayer
local lighting = game:GetService("Lighting")

-- ===== LOW TEXTURE =====
pcall(function()
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)

local blur = Instance.new("BlurEffect")
blur.Size = 6
blur.Parent = lighting

for _, v in pairs(workspace:GetDescendants()) do
	if v:IsA("Part") or v:IsA("MeshPart") then
		v.Material = Enum.Material.SmoothPlastic
		v.Reflectance = 0
	end

	if v:IsA("Decal") or v:IsA("Texture") then
		v.Transparency = 0.4
	end
end

workspace.DescendantAdded:Connect(function(v)
	if v:IsA("Part") or v:IsA("MeshPart") then
		v.Material = Enum.Material.SmoothPlastic
		v.Reflectance = 0
	end

	if v:IsA("Decal") or v:IsA("Texture") then
		v.Transparency = 0.4
	end
end)

-- ===== ẨN BODY (ANTI RESET) =====
local function hideParts(char)
	while char and char.Parent do
		local head = char:FindFirstChild("Head")
		if head then
			head.Transparency = 1

			local face = head:FindFirstChildWhichIsA("Decal")
			if face then
				face:Destroy()
			end
		end

		-- chân phải (R15 + R6)
		local rightLeg = char:FindFirstChild("RightLowerLeg") 
			or char:FindFirstChild("RightUpperLeg")
			or char:FindFirstChild("Right Leg")

		if rightLeg then
			rightLeg.Transparency = 1
		end

		task.wait(0.5) -- loop chống game hồi lại
	end
end

local function onCharacter(char)
	char:WaitForChild("Humanoid")
	task.wait(0.2)
	task.spawn(function()
		hideParts(char)
	end)
end

-- lần đầu
if player.Character then
	onCharacter(player.Character)
end

-- mỗi lần respawn
player.CharacterAdded:Connect(onCharacter)
