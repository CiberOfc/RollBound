local DiceService = require(script.Parent.DiceService)
local UpgradeData = require(script.Parent.Parent.Shared.UpgradeData)

local UpgradeService = {}

local lastUpgradesGenerated = {}

local function UpgradeLookUp(UpgradeName)
	if not UpgradeName then
		return nil
	end
	for categoryName, Category in UpgradeData do
		print(Category[UpgradeName])
	end
end

UpgradeLookUp("BlessedDie")

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
	for _, dice in ipairs(Dice.Dice) do
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
			for _, value in ChoosenUpgrades do
				table.insert(upgradeIds, value.Id)
			end
			lastUpgradesGenerated[player] = upgradeIds
		end
	end
	print("These are the generated upgrades", ChoosenUpgrades)
	return ChoosenUpgrades
end

local DamageModifierHandler = {

	--[[

Templates:

Context = {
	Player = player,
	Dice = diceState.Dice,
	DiceTotal = 21,
	WeaponDamage = 4,
	ComboName = "Pair",
	ComboMultiplier = 1.5,
}

UpgradeData = {
	Name = "Blessed Die",
	MaxLevel = 3,

	Values = {
		[1] = 1.25,
		[2] = 1.5,
		[3] = 1.75,
	}
}

Die = {
	Id = 2,
	Value = 5,
	RerollCount = 0,
	Unlocked = true,

	Upgrade = {
		Id = "BlessedDie",
		Level = 2,
	}
}
]]

	BlessedDie = function(die, upgradeData, _Context)
		if die.RerollCount > 0 then
			return nil
		end
		local level = die.Upgrade.Level
		local value = upgradeData.Values[level]

		if not value then
			return nil
		end

		return {
			Stat = "TotalDamage",
			Type = "Multiplier",
			Value = value,
			Source = "BlessedDie",
			DieId = die.Id,
		}
	end,
	--[[
	CelestialEcho = function(die, upgradeData, _Context)
		local level = die.Upgrade.Level
		local value = upgradeData.Values[level]

		if not value then
			return nil
		end

		return {
			Stat = "TotalDamage",
			Type = "Multiplier",
			Value = value,
			Source = "CelestialEcho",
			DieId = die.Id,
		}
	end,

	AngelShield = function(die, upgradeData, _Context)
		local level = die.Upgrade.Level
		local value = upgradeData.Values[level]

		if not value then
			return nil
		end

		return {
			Stat = "TotalDamage",
			Type = "Multiplier",
			Value = value,
			Source = "AngelShield",
			DieId = die.Id,
		}
	end,

	ToxicPop = function(die, upgradeData, _Context)
		local level = die.Upgrade.Level
		local stacks = upgradeData.Values[level]

		if not stacks then
			return nil
		end

		return {
			Stat = "TotalDamage",
			Type = "Multiplier",
			Value = stacks,
			Source = "ToxicPop",
			DieId = die.Id,
		}
	end,

	LingeringPoison = function(die, upgradeData, _Context)
		local level = die.Upgrade.Level
		local stacks = upgradeData.Values[level]

		if not stacks then
			return nil
		end

		return {
			Stat = "TotalDamage",
			Type = "Multiplier",
			Value = stacks,
			Source = "LingeringPoison",
			DieId = die.Id,
		}
	end,

	BloodBlade = function(die, upgradeData, _Context)
		local level = die.Upgrade.Level
		local value = upgradeData.Values[level]

		if not value then
			return nil
		end

		return {
			Stat = "TotalDamage",
			Type = "Multiplier",
			Value = value,
			Source = "BloodBlade",
			DieId = die.Id,
		}
	end,

	SelfSacrifice = function(die, upgradeData, _Context)
		local level = die.Upgrade.Level
		local value = upgradeData.Values[level]

		if not value then
			return nil
		end
		return {
			Stat = "TotalDamage",
			Type = "Multiplier",
			Value = value,
			Source = "SelfSacrifice",
			DieId = die.Id,
		}
	end,
	]]
}

function UpgradeService.GetEffects(context)
	local modifiers = {}

	if not context or not context.Dice then
		return modifiers
	end

	for _, die in ipairs(context.Dice) do
		local ownedUpgrade = die.Upgrade

		if not ownedUpgrade or not ownedUpgrade.Id then
			continue
		end
	end
	return modifiers
end

return UpgradeService
