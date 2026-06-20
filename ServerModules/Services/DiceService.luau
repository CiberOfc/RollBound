local DiceService = {}

local DICE_AMMOUT = 1
local DICE_SIDES = 6
local BASE_REROLLS = 20

local PlayerStates = {}
local playerUpgrades = {}

local function RollDice(upgrades)
	local dice = {}

	if #upgrades ~= 0 then
		print(upgrades)
		for i = 1, DICE_AMMOUT do
			dice[i] = {
				Id = i,
				Value = math.random(1, DICE_SIDES),
				Upgrade = {
					Id = upgrades[i].Id or nil,
					Level = upgrades[i].Level or 0,
				},
				RerollCount = 0,
				Unlocked = true,
			}
		end
		return dice
	end

	for i = 1, DICE_AMMOUT do
		dice[i] = {
			Id = i,
			Value = math.random(1, DICE_SIDES),
			Upgrade = {
				Id = nil,
				Level = 0,
			},
			RerollCount = 0,
			Unlocked = false,
		}
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
	local previousDice = DiceService.GetPlayerState(player)
	if previousDice then
		playerUpgrades = {}
		playerUpgrades[player] = playerUpgrades
		for i = 1, DICE_AMMOUT do
			table.insert(playerUpgrades[player], previousDice.Dice[i].Upgrade)
		end
		print(previousDice, playerUpgrades[player])
	end
	local state = {
		Dice = RollDice(playerUpgrades),
		RerollsLeft = BASE_REROLLS,
		Confirmed = false,
	}
	PlayerStates[player] = state
	state.Dice[1].Unlocked = true
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
