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
			lastUpgradesGenerated[player] = ChoosenUpgrades
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
