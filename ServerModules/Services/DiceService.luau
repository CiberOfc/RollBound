local DiceService = {}

local DICE_AMMOUT = 1
local DICE_SIDES = 6
local BASE_REROLLS = 20

local PlayerStates = {}

local function RollDice(preservedUpgrades)
	local dice = {}

	for i = 1, DICE_AMMOUT do
		if preservedUpgrades[i] and preservedUpgrades[i].Id then
			dice[i] = {
				Id = i,
				Value = math.random(1, DICE_SIDES),
				Upgrade = {
					Id = preservedUpgrades[i].Id,
					Level = preservedUpgrades[i].Level,
				},
				RerollCount = 0,
			}
		else
			dice[i] = {
				Id = i,
				Value = math.random(1, DICE_SIDES),
				Upgrade = {
					Id = nil,
					Level = 0,
				},
				RerollCount = 0,
			}
		end
	end
	return dice
end

function DiceService.ClearState(player: Player)
	if not player then
		return nil
	end
	PlayerStates[player] = nil
	return nil
end

function DiceService.StartTurn(player: Player)
	local preservedUpgrades = {}
	local previousDice = DiceService.GetPlayerState(player)
	if previousDice then
		for i = 1, DICE_AMMOUT do
			table.insert(preservedUpgrades[i], previousDice.Dice[i].Upgrade)
		end
	end
	local state = {
		Dice = RollDice(preservedUpgrades),
		RerollsLeft = BASE_REROLLS,
		Confirmed = false,
	}
	PlayerStates[player] = state
end

function DiceService.GetPlayerState(player: Player)
	print(PlayerStates[player])
	if not player then
		return nil
	end
	return PlayerStates[player]
end

function DiceService.RerollDice(player: Player, DiceId: number)
	local state = PlayerStates[player]

	if not state then
		return nil
	end

	if state.Confirmed then
		return nil
	end

	if state.RerollsLeft <= 0 then
		return nil
	end

	local die = state.Dice[DiceId]
	if not die then
		return nil
	end
	if die.Unlocked == true then
		die.Value = math.random(1, DICE_SIDES)
		die.RerollCount += 1
		state.RerollsLeft -= 1
		return state
	end
	return nil
end

function DiceService.ConfirmDice(player: Player)
	if not player then
		return nil
	end

	local state = DiceService.GetPlayerState(player)
	if not state or state.Confirmed == true then
		return nil
	end

	state.Confirmed = true

	return state
end

return DiceService
