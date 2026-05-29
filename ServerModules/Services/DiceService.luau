local DiceService = {}

local DICE_AMMOUT = 5
local DICE_SIDES = 6
local BASE_REROLLS = 20

local PlayerStates = {}
local playerUpgrades = nil

local function RollDice(upgrades)
	local dice = {}

	if upgrades ~= nil then
		print(upgrades)
		for i = 1, DICE_AMMOUT do
			dice[i] = {
				Id = i,
				Value = math.random(1, DICE_SIDES),
				Upgrade = {
					Id = upgrades[i].Id or nil,
					Level = upgrades[i].Level or nil,
				},
				RerollCount = 0,
			}
		end
		return dice
	end

	for i = 1, DICE_AMMOUT do
		dice[i] = {
			Id = i,
			Value = math.random(1, DICE_SIDES),
			Upgrade = {
				UpgradeId = nil,
				Level = nil,
			},
			RerollCount = 0,
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
		for i = 1, DICE_AMMOUT do
			table.insert(playerUpgrades, previousDice.Dice[i].Upgrade)
		end
		print(previousDice, playerUpgrades)
	end
	local state = {
		Dice = RollDice(playerUpgrades),
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

	die.Value = math.random(1, DICE_SIDES)
	die.RerollCount += 1
	state.RerollsLeft -= 1
	return state
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
