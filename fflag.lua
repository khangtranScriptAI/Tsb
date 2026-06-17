local player = game.Players.LocalPlayer
local lighting = game.Lighting

-- ===== ĐỒ HỌA BAN ĐÊM CÓ ÁNH TRĂNG (GIỮ SAU KHI CHẾT) =====
local function setNightLighting()
	pcall(function()
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		settings().Rendering.EnableFRM = false
		
		lighting.TimeOfDay = "00:00:00"
		lighting.Brightness = 1.2
		lighting.OutdoorAmbient = Color3.fromRGB(70, 80, 110)
		lighting.Ambient = Color3.fromRGB(60, 65, 90)
		lighting.FogEnd = 800
		lighting.FogColor = Color3.fromRGB(40, 45, 70)
		lighting.ExposureCompensation = 0.2
		lighting.ShadowSoftness = 0.5
		lighting.GlobalShadows = false
		lighting.ClockTime = 1
		lighting.GeographicLatitude = 41
	end)
end

setNightLighting()

-- ===== CHỐNG RESET ÁNH SÁNG =====
lighting:GetPropertyChangedSignal("TimeOfDay"):Connect(function()
	if lighting.TimeOfDay ~= "00:00:00" then setNightLighting() end
end)

lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
	if lighting.ClockTime > 5 or lighting.ClockTime < 0.5 then setNightLighting() end
end)

task.spawn(function()
	while true do
		if lighting.TimeOfDay ~= "00:00:00" or lighting.ClockTime > 5 then
			setNightLighting()
		end
		task.wait(1)
	end
end)

-- ===== LOW TEXTURE =====
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

-- ===== XÓA BỤI =====
local function removeDust(v)
	if v:IsA("ParticleEmitter") then
		v:Destroy()
	end
end

for _, v in pairs(workspace:GetDescendants()) do
	removeDust(v)
end

workspace.DescendantAdded:Connect(function(v)
	removeDust(v)
end)

-- ===== XÓA MẢNH VỠ (DEBRIS) =====
local debrisKeywords = {"debris", "mảnh", "vỡ", "shatter", "piece", "fragment", "chunk", "rubble", "scrap", "mảnh vụn"}

local function isDebris(obj)
	if obj:IsA("Part") or obj:IsA("MeshPart") then
		local name = obj.Name:lower()
		for _, keyword in ipairs(debrisKeywords) do
			if name:find(keyword) then
				return true
			end
		end
		if obj.Size.X < 0.3 and obj.Size.Y < 0.3 and obj.Size.Z < 0.3 then
			return true
		end
		if not obj.CanCollide and obj.Anchored == false then
			return true
		end
	end
	return false
end

local function removeDebris(v)
	if isDebris(v) then
		v:Destroy()
	end
end

for _, v in pairs(workspace:GetDescendants()) do
	removeDebris(v)
end

workspace.DescendantAdded:Connect(function(v)
	task.wait(0.05)
	removeDebris(v)
end)

-- ===== XÓA ĐẦU (GIỮ SAU KHI CHẾT/RESET) =====
local function hideHead(char)
	task.spawn(function()
		while char and char.Parent do
			local head = char:FindFirstChild("Head")
			if head then
				head.LocalTransparencyModifier = 1
				-- Xóa mặt trên đầu
				local face = head:FindFirstChildWhichIsA("Decal")
				if face then
					face:Destroy()
				end
			end
			task.wait(0.1)
		end
	end)
end

local function onCharacter(char)
	char:WaitForChild("Humanoid")
	task.wait(0.1)
	hideHead(char)
end

-- Kết nối khi nhân vật xuất hiện
player.CharacterAdded:Connect(onCharacter)

-- Áp dụng cho nhân vật hiện tại nếu có
if player.Character then
	onCharacter(player.Character)
end
