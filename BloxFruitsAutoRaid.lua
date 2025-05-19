
--[[ Auto Raid GUI Script | Blox Fruits Clone Educational Use Only ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local enemyFolder = workspace:WaitForChild("Enemies")

-- RemoteEvents
local StartRaid = ReplicatedStorage:WaitForChild("StartRaid")
local DealDamage = ReplicatedStorage:WaitForChild("DealDamage")

-- State
local autoRaid = false
local autoAttack = false
local teleport = false

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "RaidGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 200)
frame.Position = UDim2.new(0, 20, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local function makeBtn(text, y, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, -20, 0, 40)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 16
	btn.Text = text
	btn.MouseButton1Click:Connect(callback)
	return btn
end

makeBtn("Start Auto Raid", 10, function()
	autoRaid = true
	StartRaid:FireServer()
end)

makeBtn("Stop Auto Raid", 60, function()
	autoRaid = false
end)

makeBtn("Toggle Auto Attack", 110, function()
	autoAttack = not autoAttack
end)

makeBtn("Toggle Teleport", 160, function()
	teleport = not teleport
end)

-- Auto Attack Loop
spawn(function()
	while true do
		if autoRaid and autoAttack then
			for _, enemy in pairs(enemyFolder:GetChildren()) do
				if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
					if teleport and char and char:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("HumanoidRootPart") then
						char.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
					end
					DealDamage:FireServer(enemy)
					wait(0.25)
				end
			end
		end
		RunService.RenderStepped:Wait()
	end
end)
