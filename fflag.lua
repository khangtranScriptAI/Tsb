local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------
-- NIGHT MODE (ổn định + chống reset)
--------------------------------------------------

local function applyNight()
	pcall(function()
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	end)

	Lighting.ClockTime = 0
	Lighting.Brightness = 1.1
	Lighting.GlobalShadows = false

	Lighting.Ambient = Color3.fromRGB(70, 75, 95)
	Lighting.OutdoorAmbient = Color3.fromRGB(70, 75, 95)

	Lighting.FogColor = Color3.fromRGB(40, 45, 60)
	Lighting.FogEnd = 1200
end

applyNight()

-- giữ ban đêm liên tục (chống game override)
task.spawn(function()
	while task.wait(2) do
		if Lighting.ClockTime > 1 then
			applyNight()
		end
	end
end)

--------------------------------------------------
-- LOW GRAPHICS (KHÔNG ĐỤNG CHARACTER)
--------------------------------------------------

local function isCharacterPart(obj)
	local model = obj:FindFirstAncestorOfClass("Model")
	if model and model:FindFirstChildOfClass("Humanoid") then
		return true
	end
	return false
end

local function lowGraphics(obj)
	-- chỉ map, không đụng nhân vật
	if obj:IsA("BasePart") and not isCharacterPart(obj) then
		pcall(function()
			obj.Material = Enum.Material.SmoothPlastic
			obj.Reflectance = 0
			obj.CastShadow = false
		end)
	end

	if obj:IsA("Texture") or obj:IsA("Decal") then
		pcall(function()
			obj.Transparency = 0.5
		end)
	end
end

for _, v in ipairs(workspace:GetDescendants()) do
	lowGraphics(v)
end

workspace.DescendantAdded:Connect(lowGraphics)

--------------------------------------------------
-- REMOVE DUST ONLY (KHÔNG XÓA EFFECT KHÁC)
--------------------------------------------------

local function isDustEmitter(obj)
	if not obj:IsA("ParticleEmitter") then
		return false
	end

	local name = string.lower(obj.Name)

	local dustKeywords = {
		dust = true,
		smoke = true,
		sand = true,
		dirt = true,
	}

	return dustKeywords[name] == true
end

local function removeDust(obj)
	if isDustEmitter(obj) then
		pcall(function()
			obj:Destroy()
		end)
	end
end

for _, v in ipairs(workspace:GetDescendants()) do
	removeDust(v)
end

workspace.DescendantAdded:Connect(removeDust)

--------------------------------------------------
-- HIDE HEAD (LOCAL ONLY, KHÔNG ẢNH HƯỞNG NGƯỜI KHÁC)
--------------------------------------------------

local function hideHead(character)
	local function apply()
		local head = character:FindFirstChild("Head")
		if head then
			head.LocalTransparencyModifier = 1

			for _, v in ipairs(head:GetChildren()) do
				if v:IsA("Decal") then
					v.Transparency = 1
				end
			end
		end
	end

	apply()

	-- chống reset character
	character.DescendantAdded:Connect(function(obj)
		if obj.Name == "Head" then
			task.wait()
			apply()
		end
	end)
end

local function onCharacter(char)
	char:WaitForChild("Head", 5)
	task.wait(0.2)
	hideHead(char)
end

LocalPlayer.CharacterAdded:Connect(onCharacter)

if LocalPlayer.Character then
	onCharacter(LocalPlayer.Character)
end
