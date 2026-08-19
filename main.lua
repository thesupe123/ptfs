local replicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

print("new a350")
local spawnevent = workspace.Spawners.SpawnAircraftRequest
local updateevent = replicatedStorage.Requests.Update
local AIRCRAFT_OPTIONS = {
	"Paratrike",
	"B1 Lancer",
	"H135 Police",
	"Airbus A350"
	-- add more here
}

local function findClosestSpawner(position)
	local spawners = workspace.Spawners
	local closestSpawner = nil
	local closestAircraftSpawner = nil
	local closestIndex = nil
	local closestDistance = math.huge

	for _, descendant in ipairs(spawners:GetDescendants()) do
		if descendant.Name == "AircraftSpawner" then
			local click = descendant:FindFirstChild("Click")
			if click and click:IsA("BasePart") then
				local distance = (click.Position - position).Magnitude
				if distance < closestDistance then
					closestDistance = distance
					closestAircraftSpawner = descendant

					local ancestor = descendant
					while ancestor.Parent ~= spawners do
						ancestor = ancestor.Parent
						if ancestor == nil then
							break
						end
					end
					closestSpawner = ancestor

					local siblings = descendant.Parent:GetChildren()
					for i, sibling in ipairs(siblings) do
						if sibling == descendant then
							closestIndex = i
							break
						end
					end
				end
			end
		end
	end

	if closestSpawner then
		print(closestSpawner.Name)
	end

	return {
		Spawner = closestSpawner,
		AircraftSpawner = closestAircraftSpawner,
		Index = closestIndex
	}
end

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main frame
local frame = Instance.new("Frame")
frame.Name = "Frame"
frame.Size = UDim2.new(0, 280, 0, 176)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(60, 60, 68)
frameStroke.Thickness = 1
frameStroke.Parent = frame

-- Title bar (drag handle)
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 28)
titleBar.BackgroundTransparency = 1
titleBar.Parent = frame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(235, 235, 240)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "Admin Panel"
title.Parent = titleBar

-- Dragging logic
do
	local dragging = false
	local dragStart, startPos
	local dragInput

	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	titleBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- ===== Player dropdown =====
local dropdownButton = Instance.new("TextButton")
dropdownButton.Name = "DropdownButton"
dropdownButton.Size = UDim2.new(1, -20, 0, 34)
dropdownButton.Position = UDim2.new(0, 10, 0, 34)
dropdownButton.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
dropdownButton.AutoButtonColor = false
dropdownButton.TextColor3 = Color3.fromRGB(220, 220, 225)
dropdownButton.Font = Enum.Font.Gotham
dropdownButton.TextSize = 14
dropdownButton.Text = "  Select Player"
dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
dropdownButton.ZIndex = 2
dropdownButton.Parent = frame

local dropdownCorner = Instance.new("UICorner")
dropdownCorner.CornerRadius = UDim.new(0, 6)
dropdownCorner.Parent = dropdownButton

local dropdownArrow = Instance.new("TextLabel")
dropdownArrow.Name = "Arrow"
dropdownArrow.Size = UDim2.new(0, 24, 1, 0)
dropdownArrow.Position = UDim2.new(1, -28, 0, 0)
dropdownArrow.BackgroundTransparency = 1
dropdownArrow.TextColor3 = Color3.fromRGB(160, 160, 168)
dropdownArrow.Font = Enum.Font.GothamBold
dropdownArrow.TextSize = 12
dropdownArrow.Text = "▼"
dropdownArrow.ZIndex = 2
dropdownArrow.Parent = dropdownButton

local dropdownList = Instance.new("ScrollingFrame")
dropdownList.Name = "DropdownList"
dropdownList.Size = UDim2.new(1, -20, 0, 0)
dropdownList.Position = UDim2.new(0, 10, 0, 70)
dropdownList.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
dropdownList.BorderSizePixel = 0
dropdownList.ClipsDescendants = true
dropdownList.Visible = false
dropdownList.ScrollBarThickness = 4
dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
dropdownList.ZIndex = 5
dropdownList.Parent = frame

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 6)
listCorner.Parent = dropdownList

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = dropdownList

-- ===== Aircraft type dropdown =====
local aircraftButton = Instance.new("TextButton")
aircraftButton.Name = "AircraftButton"
aircraftButton.Size = UDim2.new(1, -20, 0, 34)
aircraftButton.Position = UDim2.new(0, 10, 0, 72)
aircraftButton.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
aircraftButton.AutoButtonColor = false
aircraftButton.TextColor3 = Color3.fromRGB(220, 220, 225)
aircraftButton.Font = Enum.Font.Gotham
aircraftButton.TextSize = 14
aircraftButton.Text = "  " .. AIRCRAFT_OPTIONS[1]
aircraftButton.TextXAlignment = Enum.TextXAlignment.Left
aircraftButton.ZIndex = 2
aircraftButton.Parent = frame

local aircraftCorner = Instance.new("UICorner")
aircraftCorner.CornerRadius = UDim.new(0, 6)
aircraftCorner.Parent = aircraftButton

local aircraftArrow = Instance.new("TextLabel")
aircraftArrow.Name = "Arrow"
aircraftArrow.Size = UDim2.new(0, 24, 1, 0)
aircraftArrow.Position = UDim2.new(1, -28, 0, 0)
aircraftArrow.BackgroundTransparency = 1
aircraftArrow.TextColor3 = Color3.fromRGB(160, 160, 168)
aircraftArrow.Font = Enum.Font.GothamBold
aircraftArrow.TextSize = 12
aircraftArrow.Text = "▼"
aircraftArrow.ZIndex = 2
aircraftArrow.Parent = aircraftButton

local aircraftList = Instance.new("ScrollingFrame")
aircraftList.Name = "AircraftList"
aircraftList.Size = UDim2.new(1, -20, 0, 0)
aircraftList.Position = UDim2.new(0, 10, 0, 108)
aircraftList.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
aircraftList.BorderSizePixel = 0
aircraftList.ClipsDescendants = true
aircraftList.Visible = false
aircraftList.ScrollBarThickness = 4
aircraftList.CanvasSize = UDim2.new(0, 0, 0, 0)
aircraftList.AutomaticCanvasSize = Enum.AutomaticSize.Y
aircraftList.ZIndex = 5
aircraftList.Parent = frame

local aircraftListCorner = Instance.new("UICorner")
aircraftListCorner.CornerRadius = UDim.new(0, 6)
aircraftListCorner.Parent = aircraftList

local aircraftListLayout = Instance.new("UIListLayout")
aircraftListLayout.SortOrder = Enum.SortOrder.LayoutOrder
aircraftListLayout.Parent = aircraftList

-- ===== Toggle row =====
local toggleLabel = Instance.new("TextLabel")
toggleLabel.Name = "ToggleLabel"
toggleLabel.Size = UDim2.new(0, 140, 0, 34)
toggleLabel.Position = UDim2.new(0, 10, 0, 130)
toggleLabel.BackgroundTransparency = 1
toggleLabel.TextColor3 = Color3.fromRGB(220, 220, 225)
toggleLabel.Font = Enum.Font.Gotham
toggleLabel.TextSize = 14
toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel.Text = "Spawn Aircraft"
toggleLabel.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 50, 0, 26)
toggleButton.Position = UDim2.new(1, -60, 0, 134)
toggleButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
toggleButton.AutoButtonColor = false
toggleButton.Text = ""
toggleButton.Parent = frame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleButton

local knob = Instance.new("Frame")
knob.Name = "Knob"
knob.Size = UDim2.new(0, 20, 0, 20)
knob.Position = UDim2.new(0, 3, 0.5, -10)
knob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
knob.Parent = toggleButton

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = knob

-- ===== State =====
local selectedPlayer = nil
local selectedAircraft = AIRCRAFT_OPTIONS[1]
local toggleState = false
local playeraircraft = nil
local targetPosition = Vector3.new(-3393, 4, 20663)
local targetMarker = nil

-- Create/update target marker function
local function setTargetMarker(pos)
	if not targetMarker or not targetMarker.Parent then
		targetMarker = Instance.new("Part")
		targetMarker.Name = "TargetMarker"
		targetMarker.Shape = Enum.PartType.Ball
		targetMarker.Size = Vector3.new(3, 3, 3)
		targetMarker.Color = Color3.fromRGB(0, 255, 0)
		targetMarker.Material = Enum.Material.Neon
		targetMarker.Anchored = true
		targetMarker.CanCollide = false
		targetMarker.Parent = workspace
	end
	targetMarker.Position = pos
end

-- ALT + CLICK TO SET TARGET POSITION AND SPAWN NEON GREEN PART
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local isAltHeld = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) 
			or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)

		if isAltHeld then
			if mouse.Hit then
				targetPosition = mouse.Hit.Position
				setTargetMarker(targetPosition)
				print("Target position updated to:", targetPosition)
			end
		end
	end
end)

-- Populate player dropdown
local function refreshPlayerList()
	for _, child in ipairs(dropdownList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		local entry = Instance.new("TextButton")
		entry.Size = UDim2.new(1, 0, 0, 30)
		entry.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
		entry.AutoButtonColor = false
		entry.TextColor3 = Color3.fromRGB(210, 210, 215)
		entry.Font = Enum.Font.Gotham
		entry.TextSize = 13
		entry.Text = plr.Name
		entry.ZIndex = 6
		entry.Parent = dropdownList

		entry.MouseEnter:Connect(function()
			entry.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
		end)
		entry.MouseLeave:Connect(function()
			entry.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
		end)

		entry.MouseButton1Click:Connect(function()
			selectedPlayer = plr
			dropdownButton.Text = "  " .. plr.Name
			dropdownList.Visible = false
			dropdownList.Size = UDim2.new(1, -20, 0, 0)
		end)
	end
end

-- Populate aircraft dropdown
local function populateAircraftList()
	for _, name in ipairs(AIRCRAFT_OPTIONS) do
		local entry = Instance.new("TextButton")
		entry.Size = UDim2.new(1, 0, 0, 30)
		entry.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
		entry.AutoButtonColor = false
		entry.TextColor3 = Color3.fromRGB(210, 210, 215)
		entry.Font = Enum.Font.Gotham
		entry.TextSize = 13
		entry.Text = name
		entry.ZIndex = 6
		entry.Parent = aircraftList

		entry.MouseEnter:Connect(function()
			entry.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
		end)
		entry.MouseLeave:Connect(function()
			entry.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
		end)

		entry.MouseButton1Click:Connect(function()
			selectedAircraft = name
			aircraftButton.Text = "  " .. name
			aircraftList.Visible = false
			aircraftList.Size = UDim2.new(1, -20, 0, 0)
		end)
	end
end

refreshPlayerList()
populateAircraftList()
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function(plr)
	if plr == selectedPlayer then
		selectedPlayer = nil
		dropdownButton.Text = "  Select Player"
	end
	task.defer(refreshPlayerList)
end)

dropdownButton.MouseButton1Click:Connect(function()
	aircraftList.Visible = false
	aircraftList.Size = UDim2.new(1, -20, 0, 0)

	dropdownList.Visible = not dropdownList.Visible
	if dropdownList.Visible then
		local count = #Players:GetPlayers()
		dropdownList.Size = UDim2.new(1, -20, 0, math.min(count * 30, 120))
	else
		dropdownList.Size = UDim2.new(1, -20, 0, 0)
	end
end)

aircraftButton.MouseButton1Click:Connect(function()
	dropdownList.Visible = false
	dropdownList.Size = UDim2.new(1, -20, 0, 0)

	aircraftList.Visible = not aircraftList.Visible
	if aircraftList.Visible then
		local count = #AIRCRAFT_OPTIONS
		aircraftList.Size = UDim2.new(1, -20, 0, math.min(count * 30, 120))
	else
		aircraftList.Size = UDim2.new(1, -20, 0, 0)
	end
end)

workspace.Aircraft.ChildAdded:Connect(function(child)
	if child.Internal:GetAttribute("SpawnedPlayer") == player.UserId then
		playeraircraft = child
		for _,v in pairs(child:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

workspace.Aircraft.ChildRemoved:Connect(function(child)
	if child == playeraircraft then
		playeraircraft = nil
	end
end)

-- Toggle button behavior
toggleButton.MouseButton1Click:Connect(function()
	if not selectedPlayer then
		local original = dropdownButton.Text
		dropdownButton.Text = "  Select a player first!"
		task.wait(1)
		dropdownButton.Text = original
		return
	end

	toggleState = not toggleState

	knob.Position = toggleState
		and UDim2.new(1, -23, 0.5, -10)
		or UDim2.new(0, 3, 0.5, -10)

	toggleButton.BackgroundColor3 = toggleState
		and Color3.fromRGB(40, 150, 70)
		or Color3.fromRGB(120, 40, 40)

	if playeraircraft == nil then
		local character = selectedPlayer.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		if not hrp then
			warn("Selected player has no character/HumanoidRootPart to find a spawner near")
			return
		end

		local closestspawner = findClosestSpawner(player.Character.HumanoidRootPart.Position)
		if not closestspawner.AircraftSpawner then
			warn("No AircraftSpawner found")
			return
		end

		spawnevent:InvokeServer(closestspawner.AircraftSpawner, selectedAircraft, "Azol")
	end

	print(("Toggled %s for %s with %s"):format(tostring(toggleState), selectedPlayer.Name, selectedAircraft))
end)

-- Fly loop driving directly towards targetPosition
RunService.PostSimulation:Connect(function()
	if toggleState and playeraircraft and selectedPlayer and targetPosition then
		local primaryPart = playeraircraft.PrimaryPart
		if primaryPart then
			local currentPos = primaryPart.CFrame.Position
			local toTarget = targetPosition - currentPos
			local distance = toTarget.Magnitude

			if distance <= 5 then
				primaryPart.AssemblyLinearVelocity = Vector3.zero
			else
				local flySpeed = 100
				primaryPart.AssemblyLinearVelocity = toTarget.Unit * flySpeed
			end
		end
	end
end)
