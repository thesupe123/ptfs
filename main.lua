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
frame.Size = UDim2.new(0, 250, 0, 100)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(0, 8)
uicorner.Parent = frame

-- Dropdown button (shows currently selected player)
local dropdownButton = Instance.new("TextButton")
dropdownButton.Name = "DropdownButton"
dropdownButton.Size = UDim2.new(1, -20, 0, 35)
dropdownButton.Position = UDim2.new(0, 10, 0, 10)
dropdownButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
dropdownButton.TextColor3 = Color3.new(1, 1, 1)
dropdownButton.Font = Enum.Font.SourceSansBold
dropdownButton.TextSize = 16
dropdownButton.Text = "Select Player"
dropdownButton.Parent = frame

local dropdownCorner = Instance.new("UICorner")
dropdownCorner.CornerRadius = UDim.new(0, 6)
dropdownCorner.Parent = dropdownButton

-- Dropdown list (hidden by default)
local dropdownList = Instance.new("Frame")
dropdownList.Name = "DropdownList"
dropdownList.Size = UDim2.new(1, -20, 0, 0)
dropdownList.Position = UDim2.new(0, 10, 0, 50)
dropdownList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
dropdownList.ClipsDescendants = true
dropdownList.Visible = false
dropdownList.Parent = frame

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 6)
listCorner.Parent = dropdownList

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = dropdownList

-- Toggle button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(1, -20, 0, 35)
toggleButton.Position = UDim2.new(0, 10, 0, 55)
toggleButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 16
toggleButton.Text = "Toggle: OFF"
toggleButton.Parent = frame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleButton

-- State
local selectedPlayer = nil
local toggleState = false

-- Populate dropdown with current players
local function refreshPlayerList()
	dropdownList:ClearAllChildren()
	listLayout.Parent = dropdownList -- re-parent since ClearAllChildren wiped it

	for _, plr in ipairs(Players:GetPlayers()) do
		local entry = Instance.new("TextButton")
		entry.Size = UDim2.new(1, 0, 0, 30)
		entry.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		entry.TextColor3 = Color3.new(1, 1, 1)
		entry.Font = Enum.Font.SourceSans
		entry.TextSize = 15
		entry.Text = plr.Name
		entry.Parent = dropdownList

		entry.MouseButton1Click:Connect(function()
			selectedPlayer = plr
			dropdownButton.Text = plr.Name
			dropdownList.Visible = false
			dropdownList.Size = UDim2.new(1, -20, 0, 0)
		end)
	end

	dropdownList.CanvasSize = nil -- not a ScrollingFrame here, kept simple
end

refreshPlayerList()
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function()
	task.wait() -- let the player actually leave the list first
	refreshPlayerList()
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







-- Toggle button behavior
toggleButton.MouseButton1Click:Connect(function()
	if not selectedPlayer then
		toggleButton.Text = "Select a player first!"
		task.wait(1)
		toggleButton.Text = "Toggle: " .. (toggleState and "ON" or "OFF")
		return
	end

	toggleState = not toggleState
	toggleButton.Text = "Toggle: " .. (toggleState and "ON" or "OFF")
	toggleButton.BackgroundColor3 = toggleState
		and Color3.fromRGB(40, 120, 60)
		or Color3.fromRGB(120, 40, 40)

	if playeraircraft == nil then
        local closestspawner = findClosestSpawner()
        spawnevent:InvokeServer(closestspawner[2], "B1 Lancer", false)
    end
	print(("Toggled %s for %s"):format(tostring(toggleState), selectedPlayer.Name))
end)
