local player = game.Players.LocalPlayer

-- ===== ĐỒ HỌA BAN ĐÊM (SMOOTH HƠN) =====
pcall(function()
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	settings().Rendering.EnableFRM = false
	
	-- Chỉnh ánh sáng về ban đêm
	game.Lighting.TimeOfDay = "00:00:00"
	game.Lighting.Brightness = 0.5
	game.Lighting.OutdoorAmbient = Color3.fromRGB(20, 20, 40)
	game.Lighting.FogEnd = 500
	game.Lighting.FogColor = Color3.fromRGB(10, 10, 30)
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

-- ===== XÓA MẢNH VỠ (DEBRIS) =====
local function removeDebris(v)
	if v:IsA("Part") or v:IsA("MeshPart") then
		local name = v.Name:lower()
		if name:find("debris") or name:find("mảnh") or name:find("vỡ") or name:find("shatter") 
			or name:find("piece") or name:find("fragment") or name:find("chunk") then
			v:Destroy()
		end
	end
end

for _, v in pairs(workspace:GetDescendants()) do
	removeDebris(v)
end

workspace.DescendantAdded:Connect(function(v)
	task.wait(0.05) -- Chờ chút để object load xong
	removeDebris(v)
end)

-- ===== XÓA HIỆU ỨNG NỔ /
