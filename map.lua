map = {}

function map.load()

	grasses = {fire={image=fireGrass,diff=50,edge=fireEdge},air={image=airGrass,diff=15,edge=airEdge},earth={image=earthGrass,diff=30,edge=earthEdge},water={image=waterGrass,diff=10,edge=waterEdge},sokka={image=normalGrass,diff=10,edge=normalEdge}}

	for x=1,16 do
		map[x] = {}
		for y=1,8 do
			map[x][y] = 1
		end
	end
end

function map.draw()
	for x=1,16 do
		for y=1,8 do
			local tileDiff = grasses[arenaType].diff
			rgb(128-tileDiff,128-tileDiff,128-tileDiff)
			if ((x+y)%2~=0) and map[x][y]==1 then rgb(128+tileDiff,128+tileDiff,128+tileDiff) end
			if players.world == "spiritual" then rgb(155,255,155) end
			local tile = grasses[arenaType].image
			if map[x][y]==0 then
				if map[x][y-1]==1 then
					tile = grasses[arenaType].edge
				else
					tile = void
				end
			end
			love.graphics.draw(tile,x*120-120,y*120)
		end
	end
end