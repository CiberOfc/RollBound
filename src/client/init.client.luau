local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packet = require(ReplicatedStorage.Packages.packet)

--[[Remotes]]
local BeginRunRemote = Packet("BeginRunRemote", Packet.Any):Response(Packet.Any, Packet.Any, Packet.Any, Packet.Any)
local RerollDiceRemote = Packet("RerollDiceRemote", Packet.Any):Response(Packet.Any)
local UpdateClientGuiRemote = Packet("UpdateClientGui", Packet.NumberU8)
local ResolveTurnRemote = Packet("ResolveTurnRemote"):Response(Packet.Any, Packet.Any)
local FireUpgradeChoice = Packet("FireUpgradeChoice", Packet.Any)

--[[Elements]]
local player = Players.LocalPlayer
task.wait(1)
local ScreenGui = player.PlayerGui:WaitForChild("ScreenGui")
local StartButton: TextButton = ScreenGui.BeginButton
local dicesFrame: Frame = ScreenGui.DiceFrames
local AttackButton: TextButton = ScreenGui.AttackButton
local informationFrame: Frame = ScreenGui.InformationFrame
local upgradeButtonFrame: Frame = ScreenGui.UpgradeChoiceFrame
local upgradeDiceFrame: Frame = ScreenGui:WaitForChild("UpgradeChoiceFrame")

--[[Variables]]
local playerState = player:FindFirstChild("PlayerState")
local upgradeChoices = nil
local selectedUpgradeId = nil
local selectedUpgradeButton = nil
local selectedDiceButton = nil
local selectedDiceId = nil
local indexOfChoosenButton = nil
local choosingUpgrade = true

--Upgrade buttons

for id = 1, 5 do
	local diceButton = dicesFrame:FindFirstChild("Dice" .. id)
	diceButton.MouseButton1Click:Connect(function()
		if playerState.Value ~= "Upgrading" then
			return
		end
		if not choosingUpgrade then
			return
		end
		if not selectedUpgradeId then
			print("Choose an Upgrade First")
			return
		end
		if not selectedDiceButton then
			selectedDiceButton = diceButton
			diceButton.BackgroundColor3 = Color3.new(0, 1, 0)
		end
		if selectedDiceButton ~= diceButton then
			selectedDiceButton.BackgroundColor3 = Color3.new(1, 1, 1)
			diceButton.BackgroundColor3 = Color3.new(0, 1, 0)
		end
		selectedDiceId = id
		print("Selected die: " .. id)
	end)
end

for i = 1, 3 do
	local upgradeButton = upgradeButtonFrame:FindFirstChild("UpgradeOption" .. i)
	upgradeButton.MouseButton1Click:Connect(function()
		if not selectedUpgradeButton then
			selectedUpgradeButton = upgradeButton
			upgradeButton.BackgroundColor3 = Color3.new(0, 1, 0)
		end

		if selectedUpgradeButton ~= upgradeButton then
			selectedUpgradeButton.BackgroundColor3 = Color3.new(1, 1, 1)
			upgradeButton.BackgroundColor3 = Color3.new(0, 1, 0)
		end

		selectedUpgradeButton = upgradeButton
		selectedUpgradeId = upgradeChoices[i].Id
		indexOfChoosenButton = i
		print(selectedUpgradeId)
	end)
end

FireUpgradeChoice.OnClientEvent:Connect(function(UpgradeChoices)
	if not UpgradeChoices then
		return
	end
	upgradeChoices = {}
	for i = 1, 3 do
		table.insert(upgradeChoices, UpgradeChoices[i])
	end
	task.wait(1.5)
	choosingUpgrade = true

	for i = 1, 3 do
		local upgradeNameLabel = upgradeButtonFrame:FindFirstChild("UpgradeName" .. i)
		local upgradeButton = upgradeButtonFrame:FindFirstChild("UpgradeOption" .. i)

		upgradeButton.Text = upgradeChoices[i].Data.Description
		upgradeNameLabel.Text = upgradeChoices[i].Id
	end
	upgradeDiceFrame.Visible = true
end)

local confirmChoiceButton = upgradeButtonFrame:FindFirstChild("ConfirmUpgradeButton")

confirmChoiceButton.MouseButton1Click:Connect(function()
	if not selectedDiceId or not selectedUpgradeId or choosingUpgrade == false then
		return
	end
	print(selectedDiceId, selectedUpgradeId)
	FireUpgradeChoice:Fire({
		DiceId = selectedDiceId,
		UpgradeId = selectedUpgradeId,
		ButtonIndex = indexOfChoosenButton,
	})
	choosingUpgrade = false
	upgradeDiceFrame.Visible = false
	local diceButton = dicesFrame:FindFirstChild("Dice" .. selectedDiceId)
	diceButton.BackgroundColor3 = Color3.new(1, 1, 1)
	selectedUpgradeId = nil
	selectedUpgradeButton = nil
	selectedDiceButton = nil
	selectedDiceId = nil
	upgradeChoices = nil
end)

local function UpdateRunInfoGui(run, enemy, damage: number, typeinfo: string)
	if not informationFrame then
		return nil
	end

	local StageLabel = informationFrame:FindFirstChild("StageLabel")
	local ChapterLabel = informationFrame:FindFirstChild("ChapterNameLabel")

	local PlayerUserLabel = informationFrame:FindFirstChild("PlayerUserLabel")
	local PlayerHealthLabel = informationFrame:FindFirstChild("PlayerHealthLabel")
	local PlayerDamageLabel = informationFrame:FindFirstChild("PlayerTotalDamageLabel")

	local EnemyNameLabel = informationFrame:FindFirstChild("EnemyNameLabel")
	local EnemyHealthLabel = informationFrame:FindFirstChild("EnemyHealthLabel")
	local EnemyDamageLabel = informationFrame:FindFirstChild("EnemyDamageLabel")

	if not typeinfo or typeinfo == "" then
		ChapterLabel.Text = run.Chapter
		PlayerUserLabel.Text = player.Name
		PlayerHealthLabel.Text = tostring(run.PlayerMaxHealth .. "/" .. run.PlayerHealth)
		PlayerDamageLabel.Text = tostring(damage)

		EnemyNameLabel.Text = enemy.Name
		EnemyHealthLabel.Text = tostring(enemy.MaxHealth .. "/" .. enemy.Health)
		EnemyDamageLabel.Text = tostring(enemy.Damage)
	end
	if typeinfo == "DamageOnly" then
		PlayerDamageLabel.Text = damage
	elseif typeinfo == "EndTurn" then
		print(run, enemy, damage, typeinfo)
		if enemy.EnemyDied == true then
			EnemyHealthLabel.BackgroundColor3 = Color3.new(1, 0, 0)
			task.wait(1.5)
			EnemyHealthLabel.BackgroundColor3 = Color3.new(1, 1, 1)
		end

		StageLabel.Text = tostring("Stage: " .. run.Stage) --even tho its not in "enemy" the function's 1st argument will be a table with {Stage = number, playerHealth = number, PlayerMaxHealth = number} wheras if there is no type info it will contain actual enemy info
		PlayerHealthLabel.Text = tostring(run.PlayerHealth .. "/" .. run.PlayerMaxHealth)
		EnemyNameLabel.Text = tostring(enemy.Name)
		EnemyHealthLabel.Text = tostring(enemy.Health .. "/" .. enemy.MaxHealth)
		PlayerDamageLabel.Text = tostring(run.PlayerFinalDamage)
	end
	return
end

local function UpdateDiceGui(Dices)
	if not Dices then
		return nil
	end
	for index, dice in ipairs(Dices.Dice) do
		local button = dicesFrame:FindFirstChild("Dice" .. index)

		if button:IsA("TextButton") then
			button.Text = tostring(dice.Value)
		end
	end
	return nil
end

for _, dice in dicesFrame:GetChildren() do
	if playerState.Value ~= "Battling" then
		continue
	end
	if dice:IsA("TextButton") then
		dice.MouseButton1Click:Connect(function()
			local newDice = RerollDiceRemote:Fire(tonumber(string.split(dice.Name, "Dice")[2]))
			if not newDice then
				print("uhhhmmmm")
				return
			end
			UpdateDiceGui(newDice)
		end)
	end
end

UpdateClientGuiRemote.OnClientEvent:Connect(function(damage: number)
	UpdateRunInfoGui(nil, nil, damage, "DamageOnly")
end)

AttackButton.MouseButton1Click:Connect(function()
	local playerData, enemyData = ResolveTurnRemote:Fire()
	if not playerData or not enemyData then
		print("No Data Found...")
		return
	end
	UpdateRunInfoGui(playerData, enemyData, 0, "EndTurn")
	UpdateDiceGui({ Dice = playerData.NewDice })
end)

StartButton.MouseButton1Click:Connect(function()
	print("hello")
	StartButton.Visible = false
	local dices, run, enemy, enemyDamage = BeginRunRemote:Fire()
	print(dices, run, enemy, enemyDamage)
	if not dices or not enemy or not run or not enemyDamage then
		print("No Data found...")
		return
	end
	UpdateDiceGui(dices)
	UpdateRunInfoGui(run, enemy, enemyDamage, "")
	AttackButton.Visible = true
end)
