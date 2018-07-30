logic = {}

function logic.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function logic.inList(list,item)
	for i=1,#list do
		if list[i]==item then return true end
	end
	return false
end