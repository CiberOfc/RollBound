local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DiceService = require(script.Parent.DiceService)
local UpgradeService = require(script.Parent.UpgradeService)
local ComboEvaluator = require(ReplicatedStorage.ReplicatedModules.Shared.ComboEvaluator)

local CombatService = {}

local function GetDiceValues(Dices)
	local values = {}

	for _, die in ipairs(Dices.Dice) do
		table.insert(values, die.Value)
	end
	return values
end

function CombatService.ResolveTurn(player: Player)
	if not player then
		return nil
	end

	local baseDamage = 10

	local state = DiceService.GetPlayerState(player)
	if not state then
		return nil
	end
	if not baseDamage then
		return nil
	end

	local finalDamage = 0
	local totalDice = 0
	local comboMultiplier, comboName = ComboEvaluator.GetBestCombo(GetDiceValues(state))

	for _, dice in ipairs(state.Dice) do
		totalDice += dice.Value
	end

	local context = {
		Player = player,
		Dice = state.Dice,
		DiceTotal = totalDice,
		ComboName = comboName,
		ComboMultiplier = comboMultiplier,
		WeaponDamage = baseDamage,
	}

	local modifiers = UpgradeService.GetDamageModifiers(context) or {}
	local totalDamage = baseDamage + totalDice

	for _, modifier in ipairs(modifiers) do
		if modifier.Type == "DmgMultiplier" then
			totalDamage *= modifier.Value
		elseif modifier.Type == "Flat" then
			totalDamage += modifier.Value
		end
	end
	finalDamage = math.round(totalDamage * comboMultiplier.Multiplier)

	local result = {
		FinalDamage = finalDamage,
		ComboName = comboName,
		DiceTotal = totalDice,
		WeaponDamage = baseDamage,
		Modifiers = modifiers,
		DamageBeforeCombo = totalDamage,
	}

	return result
end

return CombatService
