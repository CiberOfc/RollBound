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
		return false, "DicesDosentExist"
	end
	if dice.Dice[diceId].Unlocked ~= true then
		return false, "DiceIsntUnlocked"
	end
	if dice.Dice[diceId].Upgrade.Id ~= upgradeId then
		return false, "DiceAlreadyHasaDifferentUpgrade"
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
	local upgradeOptions = UpgradeService.GetLastGeneratedUpgrades(player)
	if upgradeOptions == nil then
		return nil
	end

	local upgradeIds = {}
	local diceUpgrades = {}

	local dices = DiceService.GetPlayerState(player)

	local CanUpgrade, error = CanApplyUpgrade(player, choosenUpgradeData.UpgradeId, choosenUpgradeData.DiceId)

	if CanUpgrade == false then
		print(error)
		return nil
	end

	for i = 1, 3 do
		table.insert(upgradeIds, upgradeOptions[i].Id)
	end

	if table.find(upgradeIds, choosenUpgradeData.UpgradeId) == nil then
		print("Upgrade: " .. choosenUpgradeData.UpgradeId .. " never existed...")
		choosenUpgradeData.UpgradeId = upgradeOptions[choosenUpgradeData.ButtonIndex].Id
	end

	if dices.Dice[choosenUpgradeData.DiceId].Upgrade.Id == choosenUpgradeData.UpgradeId then
		dices.Dice[choosenUpgradeData.DiceId].Upgrade.Level += 1
	else
		dices.Dice[choosenUpgradeData.DiceId].Upgrade.Id = choosenUpgradeData.UpgradeId
		print(dices.Dice[choosenUpgradeData.DiceId].Upgrade.Id)
		dices.Dice[choosenUpgradeData.DiceId].Upgrade.Level = 1
	end

	for _, dice in pairs(dices) do
		table.insert(diceUpgrades, { DiceId = dice.Id, Upgrade = dice.Upgrade })
	end

	return
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
