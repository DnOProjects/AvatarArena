map = {}

function map.load()
	fireGrass = love.graphics.newImage("fireGrass.png")
	waterGrass = love.graphics.newImage("waterGrass.png")
	airGrass = love.graphics.newImage("airGrass.png")
	earthGrass = love.graphics.newImage("earthGrass.png")

	grasses = {fire={image=fireGrass,diff=50},air={image=airGrass,diff=10},earth={image=earthGrass,diff=30},water={image=waterGrass,diff=10}}

	for x=1,16 do
		map[#map+1] = {}
		for y=1,8 do
			map[#map+1] = 0
		end
	end
end

function map.draw()
	for x=1,16 do
		for y=1,8 do
			local tileDiff = grasses[arenaType].diff
			if (x+y)%2==0 then love.graphics.setColor(128-tileDiff,128-tileDiff,128-tileDiff) else love.graphics.setColor(128+tileDiff,128+tileDiff,128+tileDiff) end
			love.graphics.draw(grasses[arenaType].image,x*120-120,y*120)
		end
	end
end