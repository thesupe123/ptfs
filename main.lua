local spawnevent = workspace.Spawners.SpawnAircraftRequest

local function findClosestSpawner(position)
	local spawners = workspace.Spawners
	local closestSpawner = nil
	local closestAircraftSpawner = nil
	local closestIndex = nil
	local closestDistance = math.huge

	for _, child in ipairs(spawners:GetChildren()) do
		if child:IsA("Model") then
			for index, subChild in ipairs(child:GetChildren()) do
				if subChild.Name == "AircraftSpawner" then
					local click = subChild:FindFirstChild("Click")
					if click and click:IsA("BasePart") then
						local distance = (click.Position - position).Magnitude
						if distance < closestDistance then
							closestDistance = distance
							closestSpawner = child
							closestAircraftSpawner = subChild
							closestIndex = index
						end
					end
				end
			end
		end
	end

	return {
		Spawner = closestSpawner,
		AircraftSpawner = closestAircraftSpawner,
		Index = closestIndex
	}
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main frame
local frame = Instance.new("Frame")
frame.Name = "Frame"
frame.Size = UDim2.new(0, 280, 0, 130)
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

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -20, 0, 24)
title.Position = UDim2.new(0, 10, 0, 6)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(235, 235, 240)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "Admin Panel"
title.Parent = frame

-- Dropdown button (shows currently selected player)
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
dropdownArrow.Parent = dropdownButton

-- Dropdown list (ScrollingFrame, hidden by default)
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

-- Created ONCE, outside refreshPlayerList, and never destroyed
local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = dropdownList

-- Toggle row (label + switch)
local toggleLabel = Instance.new("TextLabel")
toggleLabel.Name = "ToggleLabel"
toggleLabel.Size = UDim2.new(0, 140, 0, 34)
toggleLabel.Position = UDim2.new(0, 10, 0, 82)
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
toggleButton.Position = UDim2.new(1, -60, 0, 86)
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

-- State
local selectedPlayer = nil
local toggleState = false

-- Populate dropdown with current players (only touches entry buttons, never the layout)
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

refreshPlayerList()
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function(plr)
	if plr == selectedPlayer then
		selectedPlayer = nil
		dropdownButton.Text = "  Select Player"
	end
	task.defer(refreshPlayerList)
end)

-- Dropdown toggle open/close
dropdownButton.MouseButton1Click:Connect(function()
	dropdownList.Visible = not dropdownList.Visible
	if dropdownList.Visible then
		local count = #Players:GetPlayers()
		dropdownList.Size = UDim2.new(1, -20, 0, math.min(count * 30, 150))
	else
		dropdownList.Size = UDim2.new(1, -20, 0, 0)
	end
end)

local playeraircraft = nil

workspace.Aircraft.ChildAdded:Connect(function(child)
    if child.Internal:GetAttribute("SpawnedPlayer").Value == LocalPlayer.UserId then
        playeraircraft = child
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

	local tweenGoal = toggleState
		and { Position = UDim2.new(1, -23, 0.5, -10), BackgroundColor3Knob = true }
		or { Position = UDim2.new(0, 3, 0.5, -10) }

	knob.Position = tweenGoal.Position
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

		local closestspawner = findClosestSpawner(hrp.Position)
		if not closestspawner.AircraftSpawner then
			warn("No AircraftSpawner found")
			return
		end

		-- NOTE: confirm what your server-side SpawnAircraftRequest actually
		-- expects as its first argument (the AircraftSpawner instance, the
		-- Spawner model, or the Index) — using AircraftSpawner here.
		spawnevent:InvokeServer(closestspawner.AircraftSpawner, "Paratrike", false)
	end

	print(("Toggled %s for %s"):format(tostring(toggleState), selectedPlayer.Name))
end)

game:GetService("RunService").PostSimulation:Connect(function()
    if toggleState and playeraircraft and selectedPlayer then
        playeraircraft.PrimaryPart.CFrame = CFrame.new(selectedPlayer.Character.HumanoidRootPart.Position)
    end
end)
