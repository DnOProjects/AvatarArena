map = {}

function map.load()

	grasses = {fire={image=fireGrass,diff=50},air={image=airGrass,diff=15},earth={image=earthGrass,diff=30},water={image=waterGrass,diff=10},sokka={image=normalGrass,diff=10}}

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