local ComboEvaluator = {}

local COMBO_MULTIPLIERS = {
	HighRoll = 1,
	Pair = 1.5,
	ThreeKind = 2.5,
	FourKind = 3.5,
	FiveKind = 10,
}

local function CountValues(Values: { number })
	local counts = {}

	for _, value in ipairs(Values) do
		counts[value] = (counts[value] or 0) + 1
	end
	return counts
end

function ComboEvaluator.GetBestCombo(Values: {})
	local counts = CountValues(Values)
	local bestComboName = "HighRoll"
	local multiplier = COMBO_MULTIPLIERS.HighRoll

	for _, amount in pairs(counts) do
		local comboName = nil

		if amount == 5 then
			comboName = "FiveKind"
		elseif amount == 4 then
			comboName = "FourKind"
		elseif amount == 3 then
			comboName = "ThreeKind"
		elseif amount == 2 then
			comboName = "Pair"
		else
			comboName = "HighRoll"
		end
		if comboName then
			local rank = COMBO_MULTIPLIERS[comboName]

			if rank > multiplier then
				multiplier = rank
				bestComboName = comboName
			end
		end
	end
	return { Name = bestComboName, Multiplier = multiplier }
end

return ComboEvaluator
