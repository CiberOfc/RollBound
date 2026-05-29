local ServerScriptService = game:GetService("ServerScriptService")
local ChapterConfig = require(ServerScriptService.ServerModules.Shared.ChapterConfig)
local CombatService = require(script.Parent.CombatService)
local DiceService = require(script.Parent.DiceService)
local EnemyService = require(script.Parent.EnemyService)

local RunService = {}

local PlayerRuns = {}

function RunService.GetRun(player: Player)
	if not player then
		return nil
	end
	return PlayerRuns[player]
end

function RunService.EndRun(player: Player)
	if not player then
		return nil
	end

	PlayerRuns[player] = nil
	DiceService.ClearState(player)
	return "Cleared"
end

function RunService.ResolveEnemyTurn(player: Player)
	local run = RunService.GetRun(player)
	if not run then
		return nil
	end
	if run.Turn ~= "Enemy" then
		return nil
	end

	local enemy = EnemyService.GetEnemy(player)
	if not enemy then
		return nil
	end

	run.PlayerHealth -= enemy.Damage
	run.PlayerHealth = math.max(run.PlayerHealth, 0)

	if run.PlayerHealth <= 0 then
		RunService.EndRun(player)

		return {
			Type = "EnemyAttack",
			Damage = enemy.Damagem,
			PlayerHealth = 0,
			Dead = true,
		}
	else
		DiceService.StartTurn(player)
		run.Turn = "Player"

		return {
			Type = "EnemyAttack",
			Damage = enemy.Damage,
			PlayerHealth = run.PlayerHealth,
			Dead = false,
		}
	end
end

function RunService.ResolvePlayerTurn(player: Player)
	local run = RunService.GetRun(player)
	if not run then
		return nil
	end

	if run.Turn ~= "Player" then
		return nil
	end

	DiceService.ConfirmDice(player)
	local dice = DiceService.GetPlayerState(player)
	print(dice)

	if not dice or not dice.Confirmed then
		return nil
	end

	local result = CombatService.ResolveTurn(player)
	local enemy = EnemyService.DamageEnemy(player, result.FinalDamage)

	if enemy.Health <= 0 then
		run.Stage += 1
		EnemyService.SpawnEnemy(
			player,
			{ Stage = run.Stage, PlayerMaxHealth = run.PlayerMaxHealth, PlayerHealth = run.PlayerHealth }
		)
		DiceService.StartTurn(player)
		run.Turn = "Player"
		return enemy
	else
		run.Turn = "Enemy"
	end
	return result
end

function RunService.StartRun(player: Player)
	if not player then
		return nil
	end
	local playerState = player:FindFirstChild("PlayerState")
	if playerState.Value ~= "Idle" then
		return nil
	end
	local run = {
		Chapter = "Forgotten Meadows",
		Stage = 1,

		PlayerHealth = 100,
		PlayerMaxHealth = 100,

		Level = 1,
		PlayerExp = 0,
		ExpToNext = 20,

		InRun = true,
		Turn = "Player",
	}
	PlayerRuns[player] = run
	DiceService.StartTurn(player)
	EnemyService.SpawnEnemy(
		player,
		{ Stage = run.Stage, PlayerMaxHealth = run.PlayerMaxHealth, PlayerHealth = run.PlayerHealth }
	)

	return run
end

return RunService
