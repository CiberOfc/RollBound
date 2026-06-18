--[[Globals]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--[[Modules]]
local CombatService = require(ServerScriptService.ServerModules.Services.CombatService)
local DiceService = require(ServerScriptService.ServerModules.Services.DiceService)
local EnemyService = require(ServerScriptService.ServerModules.Services.EnemyService)
local ProgressionService = require(ServerScriptService.ServerModules.Services.ProgressionService)
local RunService = require(ServerScriptService.ServerModules.Services.RunService)
local UpgradeService = require(ServerScriptService.ServerModules.Services.UpgradeService)
local ChapterConfig = require(ServerScriptService.ServerModules.Shared.ChapterConfig)
local Packet = require(ReplicatedStorage.Packages.packet)

--[[Remotes]]
local BeginRunRemote = Packet("BeginRunRemote", Packet.Any):Response(Packet.Any, Packet.Any, Packet.Any, Packet.Any)
local RerollDiceRemote = Packet("RerollDiceRemote", Packet.Any):Response(Packet.Any)
local UpdateClientGuiRemote = Packet("UpdateClientGui", Packet.NumberU8)
local ResolveTurnRemote = Packet("ResolveTurnRemote"):Response(Packet.Any, Packet.Any)
local FireUpgradeChoice = Packet("FireUpgradeChoice", Packet.Any)

local ready = {}

local function SetupPlayer(player: Player)
	local playerState = player:FindFirstChild("PlayerState")
	if not playerState then
		playerState = Instance.new("StringValue")
		playerState.Parent = player
		playerState.Value = "Idle"
	end
	return playerState
end

BeginRunRemote.OnServerInvoke = function(player: Player)
	if not player then
		return nil
	end

	if ready[player].Ready == true then
		local playerState = player:FindFirstChild("PlayerState")
		ready[player].Ready = false

		local CurrentRun = RunService.GetRun(player)
		if not CurrentRun then
			print("[[No run found starting a new one...]]")
			task.wait(0.5)

			local run = RunService.StartRun(player) --Also rolls dice once

			playerState.Value = "Battling"

			local dice = DiceService.GetPlayerState(player)
			local enemy = EnemyService.GetEnemy(player)
			local diceResult = CombatService.ResolveTurn(player)

			ready[player].Ready = true

			return dice, run, enemy, diceResult.FinalDamage
		end
		ready[player].Ready = true
	end
	return
end

ResolveTurnRemote.OnServerInvoke = function(player: Player)
	if ready[player].Ready == true then
		local run = RunService.GetRun(player)
		if not run then
			return nil
		end

		local _playerState = player:FindFirstChild("PlayerState")
		if not _playerState then
			_playerState = SetupPlayer(player)
		end
		local enemyDied = false

		ready[player].Ready = false

		local enemyAfterTurn = RunService.ResolvePlayerTurn(player)
		task.wait(0.5)
		RunService.ResolveEnemyTurn(player)
		task.wait(0.5)

		if enemyAfterTurn.Health == 0 then
			enemyDied = true
			local levelUp = ProgressionService.IncrementPlayerExp(
				player,
				enemyAfterTurn.EnemyType,
				ChapterConfig.GetChapter(run.Stage).ChapterExpMultiplier
			)
			if levelUp == true then
				local UpgradeChoices = UpgradeService.GenerateUpgrades(player)
				if not UpgradeChoices then
					return nil
				end
				print(UpgradeChoices)
				_playerState.Value = "Upgrading"
				FireUpgradeChoice:FireClient(player, UpgradeChoices)
			end
		end

		local enemy = EnemyService.GetEnemy(player)

		if not enemy then
			return nil
		end
		local newDice = DiceService.GetPlayerState(player)
		local PlayerTotalDamage = CombatService.ResolveTurn(player)

		ready[player].Ready = true

		return {
			Chapter = run.Chapter,
			Stage = run.Stage,
			NewDice = newDice.Dice,
			PlayerHealth = run.PlayerHealth,
			PlayerMaxHealth = run.PlayerMaxHealth,
			PlayerFinalDamage = PlayerTotalDamage.FinalDamage,
		}, {
			EnemyDied = enemyDied,
			Name = enemy.Name,
			Health = enemy.Health,
			MaxHealth = enemy.MaxHealth,
		}
	end
	return
end

FireUpgradeChoice.OnServerEvent:Connect(function(player: Player, choosenUpgradeData)
	if not player or not choosenUpgradeData then
		return nil
	end
	local _playerState = player:FindFirstChild("PlayerState")
	if _playerState.Value ~= "Upgrading" then
		return
	end
	local upgradeIds = {}
	local dice = DiceService.GetPlayerState(player)
	print(dice)
	local upgradeOptions = UpgradeService.GetLastGeneratedUpgrades(player)

	for i = 1, 3 do
		table.insert(upgradeIds, upgradeOptions[i].Id)
	end
	if table.find(upgradeIds, choosenUpgradeData.UpgradeId) == nil then
		print("Upgrade: " .. choosenUpgradeData.UpgradeId .. " never existed...")
		choosenUpgradeData.UpgradeId = upgradeOptions[choosenUpgradeData.ButtonIndex].Id
	end
	print(dice, choosenUpgradeData)
	if dice.Dice[choosenUpgradeData.DiceId].Upgrade.Id == choosenUpgradeData.UpgradeId then
		dice.Dice[choosenUpgradeData.DiceId].Upgrade.Level += 1
	else
		dice.Dice[choosenUpgradeData.DiceId].Upgrade.Id = choosenUpgradeData.UpgradeId
		print(dice.Dice[choosenUpgradeData.DiceId].Upgrade.Id)
		dice.Dice[choosenUpgradeData.DiceId].Upgrade.Level = 1
	end
	print(dice)
	_playerState.Value = "Battling"
	return
end)

--[[Reroll Dice function]]
local Debounce = false

RerollDiceRemote.OnServerInvoke = function(player: Player, DiceId: number)
	local playerState = player:FindFirstChild("PlayerState")
	if playerState.Value ~= "Battling" then
		return
	end
	if Debounce == false then
		Debounce = true
		local newDice = DiceService.RerollDice(player, DiceId)
		if not newDice then
			print("No rerolls left or no run has begun")
			return nil
		end
		Debounce = false
		local diceResult = CombatService.ResolveTurn(player)
		UpdateClientGuiRemote:FireClient(player, diceResult.FinalDamage)
		return newDice
	end
	return
end

--[[Initiate/Remove]]

Players.PlayerAdded:Connect(function(player: Player)
	local playerState = Instance.new("StringValue")
	playerState.Name = "PlayerState"
	playerState.Parent = player
	playerState.Value = "Idle"

	local promptTable = {
		Ready = true,
	}
	ready[player] = promptTable
end)

Players.PlayerRemoving:Connect(function(player: Player)
	RunService.EndRun(player)
	ready[player] = nil
end)
