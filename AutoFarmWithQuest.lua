-- Expanded Auto Farm With Quest System | Educational Use

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

-- Customize these based on your game's structure
local enemyFolder = workspace:WaitForChild("Enemies")
local DealDamage = ReplicatedStorage:WaitForChild("DealDamage")
local QuestSystem = ReplicatedStorage:WaitForChild("QuestSystem")
local TakeQuest = QuestSystem:WaitForChild("TakeQuest") -- RemoteFunction

-- Variables
local autoFarm = false
local teleportToEnemy = true
local currentQuestTarget = "Bandit" -- Default quest target
local questID = "BanditQuest"       -- Default quest ID

-- GUI Creation
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "AutoFarmGUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 320)
frame.Position = UDim2.new(0, 20, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true

local uiCorner = Instance.new("UICorner", frame)
uiCorner.CornerRadius = UDim.new(0, 8)

-- Title Label
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Auto Farm Menu"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 22

-- Status Label
local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 45)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 16
statusLabel.Text = "Status: Stopped"

-- Teleport Status Label
local teleportLabel = Instance.new("TextLabel", frame)
teleportLabel.Size = UDim2.new(1, -20, 0, 25)
teleportLabel.Position = UDim2.new(0, 10, 0, 70)
teleportLabel.BackgroundTransparency = 1
teleportLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
teleportLabel.Font = Enum.Font.Gotham
teleportLabel.TextSize = 16
teleportLabel.Text = "Teleport: ON"

-- Function to create buttons
local TweenService = game:GetService("TweenService")
local function createButton(text, posY, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, -20, 0, 40)
	btn.Position = UDim2.new(0, 10, 0, posY)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.BorderSizePixel = 0
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 18
	btn.Text = text

	local uiCornerBtn = Instance.new("UICorner", btn)
	uiCornerBtn.CornerRadius = UDim.new(0, 6)

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(65,65,65)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45,45,45)}):Play()
	end)

	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- Dropdown for quest target selection
local dropdownFrame = Instance.new("Frame", frame)
dropdownFrame.Size = UDim2.new(1, -20, 0, 30)
dropdownFrame.Position = UDim2.new(0, 10, 0, 105)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropdownFrame.BorderSizePixel = 0

local uiCornerDrop = Instance.new("UICorner", dropdownFrame)
uiCornerDrop.CornerRadius = UDim.new(0, 6)

local dropdownLabel = Instance.new("TextLabel", dropdownFrame)
dropdownLabel.Size = UDim2.new(0.8, 0, 1, 0)
dropdownLabel.Position = UDim2.new(0, 10, 0, 0)
dropdownLabel.BackgroundTransparency = 1
dropdownLabel.TextColor3 = Color3.new(1,1,1)
dropdownLabel.Font = Enum.Font.Gotham
dropdownLabel.TextSize = 16
dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
dropdownLabel.Text = "Target: " .. currentQuestTarget

local dropdownArrow = Instance.new("TextLabel", dropdownFrame)
dropdownArrow.Size = UDim2.new(0, 20, 1, 0)
dropdownArrow.Position = UDim2.new(0.9, 0, 0, 0)
dropdownArrow.BackgroundTransparency = 1
dropdownArrow.TextColor3 = Color3.new(1,1,1)
dropdownArrow.Font = Enum.Font.GothamBold
dropdownArrow.TextSize = 18
dropdownArrow.Text = "▼"

-- Dropdown List
local dropdownList = Instance.new("Frame", frame)
dropdownList.Size = UDim2.new(1, -20, 0, 0)
dropdownList.Position = UDim2.new(0, 10, 0, 135)
dropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropdownList.BorderSizePixel = 0
dropdownList.ClipsDescendants = true

local uiCornerList = Instance.new("UICorner", dropdownList)
uiCornerList.CornerRadius = UDim.new(0, 6)

local isDropdownOpen = false
local dropdownItems = {}

local function toggleDropdown()
	if isDropdownOpen then
		-- close dropdown
		TweenService:Create(dropdownList, TweenInfo.new(0.3), {Size = UDim2.new(1, -20, 0, 0)}):Play()
		isDropdownOpen = false
	else
		-- populate dropdown items dynamically from enemy folder
		for _, item in pairs(dropdownItems) do
			item:Destroy()
		end
		dropdownItems = {}
		
		local enemies = enemyFolder:GetChildren()
		local height = 0
		for i, enemy in ipairs(enemies) do
			if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
				local btn = Instance.new("TextButton", dropdownList)
				btn.Size = UDim2.new(1, -10, 0, 30)
				btn.Position = UDim2.new(0, 5, 0, height)
				btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				btn.BorderSizePixel = 0
				btn.TextColor3 = Color3.new(1,1,1)
				btn.Font = Enum.Font.Gotham
				btn.TextSize = 16
				btn.Text = enemy.Name
				
				local uiCornerItem = Instance.new("UICorner", btn)
				uiCornerItem.CornerRadius = UDim.new(0, 4)
				
				btn.MouseButton1Click:Connect(function()
					currentQuestTarget = enemy.Name
					questID = enemy.Name .. "Quest" -- Assuming questID follows this pattern, adjust as needed
					dropdownLabel.Text = "Target: " .. currentQuestTarget
					toggleDropdown()
				end)
				
				table.insert(dropdownItems, btn)
				height = height + 32
			end
		end
		
		TweenService:Create(dropdownList, TweenInfo.new(0.3), {Size = UDim2.new(1, -20, 0, math.min(height, 150))}):Play()
		isDropdownOpen = true
	end
end

dropdownFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		toggleDropdown()
	end
end)

-- Buttons
local startBtn = createButton("Start Auto Farm", 180, function()
	autoFarm = true
	statusLabel.Text = "Status: Running"
end)

local stopBtn = createButton("Stop Auto Farm", 230, function()
	autoFarm = false
	statusLabel.Text = "Status: Stopped"
end)

local teleportBtn = createButton("Toggle Teleport", 280, function()
	teleportToEnemy = not teleportToEnemy
	teleportLabel.Text = "Teleport: " .. (teleportToEnemy and "ON
