local ChapterConfig = {
	{
		Id = "ForgottenMeadows",
		DisplayName = "Forgotten Meadows",

		MinStage = 1,
		MaxStage = 10,

		Theme = {
			Biome = "Abbys",
			Mood = "Monotone",
			AccentColor = "DarkGray",
			Skybox = "MoonStarySky",
			Music = "none",
		},

		EnemyPool = {
			"LostSoul",
			"AshWisp",
			"AbyssWanderer",
		},

		BossStage = 10,
		Boss = "The Forgotten One",

		ScallingMultiplier = 1,
		ChapterExpMultiplier = 1.05,

		Rules = {
			AllowCorruption = false,
			AllowConstelationEvents = true,
			AllowEliteEnemies = true,
		},
	},
	{
		Id = "AstralObservatory",
		Name = "Astral Observatory",

		MinStage = 11,
		MaxStage = 20,

		Theme = {
			Biome = "Cosmic",
			Mood = "Mysterious",
			AccentColor = "PurpleBlue",
			Skybox = "DeepSpace",
			Music = "",
		},

		EnemyPool = {
			"Researcher",
			"StarWritter",
			"RobotAssistants",
		},

		BossStage = 20,
		Boss = "Head Researcher",

		Rules = {
			AllowCorruption = true,
			AllowConstelationEvents = true,
			AllowEliteEnemies = true,
		},
	},
}

function ChapterConfig.GetChapter(stage: number)
	if not stage then
		return nil
	end

	for _, x in ipairs(ChapterConfig) do
		if x.MinStage <= stage and x.MaxStage >= stage then
			return x
		end
	end
	return
end

return ChapterConfig
