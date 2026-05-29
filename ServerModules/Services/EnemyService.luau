local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ChapterConfig = require(ServerScriptService.ServerModules.Shared.ChapterConfig)
local EnemyData = require(ReplicatedStorage.ReplicatedModules.Configs.EnemyData)

-- Takes care of enemy system most work is self explanatory
local EnemyService = {}

local PlayerEnemies = {}

function EnemyService.GetEnemy(player: Player)
	return PlayerEnemies[player]
end

function EnemyService.SpawnEnemy(player: Player, SpawnContext)
	local EnemyPool = ChapterConfig.GetChapter(SpawnContext.Stage).EnemyPool
	local totalWeight = 0
	local EliteChance = 20
	local validEnemies = {}
	local count = 1

	if SpawnContext.Stage == 5 or SpawnContext.Stage == 7 then
		EliteChance = math.random(70, 90)
	end

	for name, enemy in pairs(EnemyData) do
		if
			(SpawnContext.Stage >= enemy.MinStage and (not enemy.MaxStage or SpawnContext.Stage <= enemy.MaxStage))
			and EnemyPool[count] ~= nil
		then
			table.insert(validEnemies, { Name = name, Data = enemy })
			count += 1
		end
	end

	if #validEnemies == 0 then
		warn("No enemies for stage:", SpawnContext.Stage)
		return nil
	end

	for _, enemy in ipairs(validEnemies) do
		totalWeight += enemy.Data.Weight
	end

	if totalWeight <= 0 then
		warn("Total enemy weight is 0")
		return nil
	end

	local roll = math.random(1, totalWeight)
	local enemyType = math.random(1, 100)

	if enemyType <= EliteChance then
		enemyType = "Elite"
	else
		enemyType = "Basic"
	end

	local randomFactor = math.random(90, 110) / 100
	local current = 0

	for _, enemy in ipairs(validEnemies) do
		current += enemy.Data.Weight

		if roll <= current then
			local MaxHealth = math.round(
				SpawnContext.PlayerHealth
					* enemy.Data.HealthScaling
					* (enemy.Data.StageScaling ^ SpawnContext.Stage)
					* randomFactor
			)
			local finalEnemy = {
				Name = enemy.Data.Name,
				MaxHealth = MaxHealth,
				Health = MaxHealth,
				Damage = math.round(
					SpawnContext.PlayerHealth * enemy.Data.DamageScaling * (1 + SpawnContext.Stage * 0.05)
				),
				EnemyType = enemyType,
				EnemySubType = enemy.Data.EnemySubType,
				EnemyAttributes = enemy.Data.Attributes,
				EnemyAbilities = enemy.Data.Abilities,
			}
			PlayerEnemies[player] = finalEnemy
			return finalEnemy
		end
	end
	return
end

function EnemyService.DamageEnemy(player: Player, damage: number)
	if not player then
		return nil
	end

	local enemy = PlayerEnemies[player]
	if not enemy then
		return nil
	end

	if enemy.Health <= damage then
		enemy.Health = 0
	else
		enemy.Health = math.max(enemy.Health - damage, 0)
	end
	return enemy
end

function EnemyService.ClearEnemies(player: Player)
	PlayerEnemies[player] = nil
	return PlayerEnemies
end

return EnemyService
