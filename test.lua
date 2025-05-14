local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local currentCharacter = nil
local humanoidRootPart = nil
local humanoid = nil
local busy = false
local holdKeys = {}

function holdKey(key)
	if not holdKeys[key] then
		holdKeys[key] = true
		VirtualInputManager:SendKeyEvent(true, key, false, nil)
	end
end

function releaseKey(key)
	if holdKeys[key] then
		holdKeys[key] = false
		VirtualInputManager:SendKeyEvent(false, key, false, nil)
	end
end

function resetAllKeys()
	for key, _ in pairs(holdKeys) do
		releaseKey(key)
	end
end

function getCharacter()
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		currentCharacter = player.Character
		humanoidRootPart = currentCharacter:FindFirstChild("HumanoidRootPart")
		humanoid = currentCharacter:FindFirstChildWhichIsA("Humanoid")
	end
end

function getPath(goal)
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentJumpHeight = 10,
		AgentMaxSlope = 45
	})
	path:ComputeAsync(humanoidRootPart.Position, goal.Position)
	if path.Status == Enum.PathStatus.Complete then
		return path:GetWaypoints()
	else
		return nil
	end
end

function moveTo(target)
	if busy then return end
	busy = true
	getCharacter()
	if not humanoidRootPart then
		busy = false
		return
	end

	local waypoints = getPath(target)
	if not waypoints then
		busy = false
		return
	end

	for _, waypoint in ipairs(waypoints) do
		if not humanoidRootPart then break end
		local direction = (waypoint.Position - humanoidRootPart.Position).Unit
		local velocity = (waypoint.Position - humanoidRootPart.Position).Magnitude

		if direction.Z > 0 then holdKey("W") else releaseKey("W") end
		if direction.Z < 0 then holdKey("S") else releaseKey("S") end
		if direction.X > 0 then holdKey("D") else releaseKey("D") end
		if direction.X < 0 then holdKey("A") else releaseKey("A") end

		repeat
			RunService.RenderStepped:Wait()
		until (humanoidRootPart.Position - waypoint.Position).Magnitude < 2 or not currentCharacter

		resetAllKeys()
	end

	busy = false
end

function findNearest(targets)
	local closest, distance = nil, math.huge
	getCharacter()
	if not humanoidRootPart then return nil end

	for _, obj in pairs(targets) do
		if obj:IsA("BasePart") and obj:IsDescendantOf(workspace) then
			local dist = (obj.Position - humanoidRootPart.Position).Magnitude
			if dist < distance then
				distance = dist
				closest = obj
			end
		end
	end
	return closest
end

function autoGen()
	while true do
		task.wait(1.25)
		if busy then continue end

		local gens = workspace:FindFirstChild("Machines")
		if gens then
			local targets = {}
			for _, gen in pairs(gens:GetChildren()) do
				if gen:FindFirstChild("Progress") and gen.Progress.Value < 100 then
					table.insert(targets, gen)
				end
			end

			local target = findNearest(targets)
			if target then
				moveTo(target)
			end
		end
	end
end

task.spawn(autoGen)
