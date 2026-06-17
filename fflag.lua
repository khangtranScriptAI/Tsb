local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

---

-- NIGHT MODE

local NIGHT_TIME = "00:00:00"

local function applyNight()
pcall(function()
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)

Lighting.TimeOfDay = NIGHT_TIME
Lighting.ClockTime = 0

Lighting.Brightness = 1.1
Lighting.GlobalShadows = false

Lighting.Ambient = Color3.fromRGB(65, 70, 90)
Lighting.OutdoorAmbient = Color3.fromRGB(75, 80, 100)

Lighting.FogColor = Color3.fromRGB(40, 45, 60)
Lighting.FogEnd = 1000

end

applyNight()

Lighting:GetPropertyChangedSignal("TimeOfDay"):Connect(function()
if Lighting.TimeOfDay ~= NIGHT_TIME then
applyNight()
end
end)

Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
if Lighting.ClockTime > 1 then
applyNight()
end
end)

---

-- LOW TEXTURE

local function lowTexture(obj)
if obj:IsA("BasePart") then
pcall(function()
obj.Material = Enum.Material.SmoothPlastic
obj.Reflectance = 0

		if obj:IsA("MeshPart") then
			obj.TextureID = ""
		end
	end)
end

if obj:IsA("Texture") then
	obj.Transparency = 1
end

end

for _, obj in ipairs(workspace:GetDescendants()) do
lowTexture(obj)
end

workspace.DescendantAdded:Connect(lowTexture)

---

-- REMOVE DUST ONLY

local dustNames = {
dust = true,
smoke = true,
sand = true,
dirt = true,
debrisdust = true
}

local function removeDust(obj)
if obj:IsA("ParticleEmitter") then
local n = string.lower(obj.Name)

	if dustNames[n] then
		obj:Destroy()
	end
end

end

for _, obj in ipairs(workspace:GetDescendants()) do
removeDust(obj)
end

workspace.DescendantAdded:Connect(removeDust)

---

-- HIDE HEAD ONLY

local function hideHead(character)
local head = character:FindFirstChild("Head")

if not head then
	return
end

head.LocalTransparencyModifier = 1

for _, v in ipairs(head:GetChildren()) do
	if v:IsA("Decal") then
		v.Transparency = 1
	end
end

end

local function characterAdded(character)
character:WaitForChild("Head", 5)
task.wait(0.2)
hideHead(character)
end

LocalPlayer.CharacterAdded:Connect(characterAdded)

if LocalPlayer.Character then
characterAdded(LocalPlayer.Character)
end
