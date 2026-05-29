local ServerScriptService = game:GetService("ServerScriptService")
local RunService = require(ServerScriptService.ServerModules.Services.RunService)

local ProgressionService = {}

function ProgressionService.IncrementPlayerExp(player, enemyType, chapterExpMultiplier)
	if not player then
		return nil
	end
	local LevelUp = false
	local run = RunService.GetRun(player)
	print(run)
	if not run then
		return nil
	end
	local baseExp = 20
	local enemyExpMultiplier = 1

	if enemyType == "Basic" then
		enemyExpMultiplier = 1.1
	elseif enemyType == "Elite" then
		enemyExpMultiplier = 1.5
	end

	local finalExp = math.floor((baseExp * enemyExpMultiplier * chapterExpMultiplier) + 0.5)
	if finalExp + run.PlayerExp >= run.ExpToNext then
		run.PlayerExp += finalExp
		LevelUp = true
		run.Level += 1
		run.PlayerExp -= run.ExpToNext
		if run.Level >= 5 then
			run.ExpToNext *= 2
		else
			run.ExpToNext *= 1.5
		end
		return LevelUp
	end
	LevelUp = false
	run.PlayerExp += finalExp
	return LevelUp
end

return ProgressionService
