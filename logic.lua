logic = {}

function logic.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function rgb(r,b,g,a) 
  local a=a or 255
  love.graphics.setColor(r/255,b/255,g/255,a/255) 
end

function logic.inList(list,item)
	for i=1,#list do
		if list[i]==item then return true end
	end
	return false
end

function logic.inBorders(p,addOnX,addOnY)
  if addOnX == nil then addOnX = 0 end
  if addOnY == nil then addOnY = 0 end
  if p.x + addOnX > 0 and p.x + addOnX < 16 and p.y + addOnY > 0 and p.y + addOnY < 8 then return true
  else return false end
end

function logic.copyTable(obj)
  if type(obj) ~= 'table' then return obj end
  local s = {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[logic.copyTable(k, s)] = logic.copyTable(v, s) end
  return res
end

function logic.getNumXP(level)
    local b = -0.1297212*level
    local c = 0.01508714*(level^2)
    return logic.round(10.0575+b+c,0)
end