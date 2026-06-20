local DiceService = require(script.Parent.DiceService)
local UpgradeData = require(script.Parent.Parent.Shared.UpgradeData)

local UpgradeService = {}

local lastUpgradesGenerated = {}

function UpgradeService.GetLastGeneratedUpgrades(player: Player)
	print(lastUpgradesGenerated)
	return lastUpgradesGenerated[player]
end

function UpgradeService.GetAllPlayerUpgrades(player: Player)
	if not player then
		return nil
	end

	local Dice = DiceService.GetPlayerState(player)
	if not Dice then
		return nil
	end
	local upgrades = {}
	for _, dice in ipairs(Dice) do
		table.insert(upgrades, dice.Upgrade)
	end

	return upgrades
end

local function CanApplyUpgrade(player: Player, upgradeId, diceId)
	if not player then
		return nil, "PlayerNotFound"
	end

	local dice = DiceService.GetPlayerState(player)

	if not dice then
		return false, "Dices Dosent Exist"
	end

	if not dice.Dice[diceId] then
		return false, "Dice Dosent Exist"
	end

	if dice.Dice[diceId].Unlocked ~= true then
		return false, "Dice Isnt Unlocked"
	end

	local upgradeChoices = UpgradeService.GetLastGeneratedUpgrades(player)

	if not upgradeChoices then
		return false, "No Generated Upgrades"
	end

	if table.find(upgradeChoices, upgradeId) == nil then
		return false, "Upgrade Dosent Exist"
	end

	if dice.Dice[diceId].Upgrade.Id ~= nil and dice.Dice[diceId].Upgrade.Id ~= upgradeId then
		return false, "Dice Already Has a Different Upgrade"
	end

	--  Places upgradesInside a table without categories
	local upgradeLookup = {}

	for _, category in pairs(UpgradeData) do
		for UpgradeId, data in pairs(category) do
			upgradeLookup[UpgradeId] = data
		end
	end

	if dice.Dice[diceId].Upgrade.Level >= upgradeLookup[upgradeId].MaxLevel then
		return false, "Upgrade Is already max level"
	end

	return true
end

function UpgradeService.ApplyUpgrades(player: Player, choosenUpgradeData)
	if not player then
		return nil
	end

	if not choosenUpgradeData then
		return nil
	end

	local diceUpgrades = {}
	local dices = DiceService.GetPlayerState(player)
	local CanUpgrade, error = CanApplyUpgrade(player, choosenUpgradeData.UpgradeId, choosenUpgradeData.DiceId)

	if CanUpgrade == false then
		print(error)
		return nil
	end

	if dices.Dice[choosenUpgradeData.DiceId].Upgrade.Id == choosenUpgradeData.UpgradeId then
		dices.Dice[choosenUpgradeData.DiceId].Upgrade.Level += 1
	else
		dices.Dice[choosenUpgradeData.DiceId].Upgrade.Id = choosenUpgradeData.UpgradeId
		print(dices.Dice[choosenUpgradeData.DiceId].Upgrade.Id)
		dices.Dice[choosenUpgradeData.DiceId].Upgrade.Level = 1
	end

	for _, die in ipairs(dices.Dice) do
		print(die)
		table.insert(diceUpgrades, { DiceId = die.Id, Upgrade = die.Upgrade })
	end

	return diceUpgrades
end

function UpgradeService.GenerateUpgrades(player: Player)
	if not player then
		return nil
	end
	local playerUpgrades = UpgradeService.GetAllPlayerUpgrades(player)
	if not playerUpgrades then
		return nil
	end
	local ValidUpgrades = {}
	local ChoosenUpgrades = {}

	for _, category in UpgradeData do
		for upgradeId, upgrade in category do
			table.insert(ValidUpgrades, {
				Category = upgrade.Category,
				Id = upgradeId,
				Data = {
					Rarity = upgrade.Rarity,
					Value = upgrade.Value,
					MaxLevel = upgrade.MaxLevel,
					Name = upgrade.Name,
					Description = upgrade.Description,
				},
			})
		end
	end
	local availableUpgrades = table.clone(ValidUpgrades)
	local count = 3
	for _ = 1, math.min(count, #availableUpgrades) do
		local canApear = true
		local index = math.random(1, #availableUpgrades)
		local upgrade = table.remove(availableUpgrades, index)
		for _, ownedUpgrade in playerUpgrades do
			if ownedUpgrade.Id == upgrade.Id then
				if ownedUpgrade.Level >= upgrade.Data.MaxLevel then
					print("Player already owns: " .. upgrade.Id)
					canApear = false
					break
				end
			end
		end
		if canApear then
			table.insert(ChoosenUpgrades, upgrade)
			local upgradeIds = {}
			for i, value in ChoosenUpgrades do
				table.insert(upgradeIds, value.Id)
			end
			lastUpgradesGenerated[player] = upgradeIds
		end
	end
	print("These are the generated upgrades", ChoosenUpgrades)
	return ChoosenUpgrades
end

function UpgradeService.GetDamageModifiers(context)
	if not context then
		return nil
	end

	local modifiers = {}
	local die = context[1][1]

	if die and die.RerollCount == -1 then
		table.insert(modifiers, {
			Stat = "BaseDamage",
			Type = "DmgMultiplier",
			Value = 1.5,
			Source = "BlessedDie",
		})
	end
	return modifiers
end

return UpgradeService
