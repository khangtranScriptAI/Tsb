--// TARGET PRIORITY: only uppercut victims
local function findUppercutVictim()
	local character = player.Character
	if not character then return nil end

	local myRoot = character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil end

	local candidates = {}

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local enemyChar = p.Character
			local hum = enemyChar:FindFirstChild("Humanoid")
			local root = enemyChar:FindFirstChild("HumanoidRootPart")

			if hum and root and hum.Health > 0 then
				local upwardVelocity = root.AssemblyLinearVelocity.Y
				local distance = (root.Position - myRoot.Position).Magnitude

				local isAirborne =
					hum:GetState() == Enum.HumanoidStateType.Freefall
					or hum.FloorMaterial == Enum.Material.Air

				-- chỉ detect người bị uppercut / hất tung
				local isUppercuted =
					isAirborne
					and upwardVelocity > 15
					and upwardVelocity < 80
					and distance < MAX_DISTANCE

				if isUppercuted then
					table.insert(candidates, enemyChar)
				end
			end
		end
	end

	if #candidates == 0 then
		return nil
	end

	local bestTarget = nil
	local bestScore = math.huge

	for _, char in ipairs(candidates) do
		local root = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChild("Humanoid")

		if root and hum then
			local distance = (root.Position - myRoot.Position).Magnitude

			-- máu thấp hơn = ưu tiên hơn
			local healthPercent = hum.Health / hum.MaxHealth

			-- gần hướng nhìn hơn = ưu tiên hơn
			local direction = (root.Position - myRoot.Position).Unit
			local lookVector = myRoot.CFrame.LookVector
			local dot = math.clamp(direction:Dot(lookVector), -1, 1)
			local angleScore = 1 - math.max(dot, 0)

			-- score thấp hơn = ưu tiên hơn
			local score =
				(distance * 1)
				+ (healthPercent * 35)
				+ (angleScore * 20)

			if score < bestScore then
				bestScore = score
				bestTarget = char
			end
		end
	end

	return bestTarget
end
