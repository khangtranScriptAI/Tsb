local player = game.Players.LocalPlayer

-- ===== LOW TEXTURE =====
pcall(function()
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)

local function lowTex(v)
	if v:IsA("Part") or v:IsA("MeshPart") then
		v.Material = Enum.Material.SmoothPlastic
		v.Reflectance = 0
	elseif v:IsA("Decal") or v:IsA("Texture") then
		v.Transparency = 0.4
	end
end

for _, v in pairs(workspace:GetDescendants()) do
	lowTex(v)
end

workspace.DescendantAdded:Connect(lowTex)

-- ===== XÓA BỤI / EFFECT =====
local function removeEffects(v)
	if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
		v:Destroy()
	end
end

for _, v in pairs(workspace:GetDescendants()) do
	removeEffects(v)
end

workspace.DescendantAdded:Connect(removeEffects)

-- ===== ẨN ĐẦU + CHÂN PHẢI =====
local function hideParts(char)
	while char.Parent do
		local head = char:FindFirstChild("Head")
		if head then
			head.LocalTransparencyModifier = 1
			
			local face = head:FindFirstChildWhichIsA("Decal")
			if face then
				face:Destroy()
			end
		end

		local rightLeg = char:FindFirstChild("RightLowerLeg") 
			or char:FindFirstChild("RightUpperLeg")
			or char:FindFirstChild("Right Leg")

		if rightLeg then
			rightLeg.LocalTransparencyModifier = 1
		end

		task.wait(0.1)
	end
end

local function onCharacter(char)
	char:WaitForChild("Humanoid")
	task.wait(0.1)
	task.spawn(function()
		hideParts(char)
	end)
end

if player.Character then
	onCharacter(player.Character)
end

player.CharacterAdded:Connect(onCharacter)
