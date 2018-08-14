logic = {}

function logic.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function WHY(r,b,g,a) 
  local a=a or 255
  love.graphics.setColor(r/255,b/255,g/255,a/255) 
end

function logic.inList(list,item)
	for i=1,#list do
		if list[i]==item then return true end
	end
	return false
end

function logic.copyTable(obj)
  if type(obj) ~= 'table' then return obj end
  local s = {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[logic.copyTable(k, s)] = logic.copyTable(v, s) end
  return res
end