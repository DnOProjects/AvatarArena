map = {}

function map.load()

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
			if (x+y)%2==0 then love.graphics.setColor(155,155,155) else love.graphics.setColor(100,100,100) end
			love.graphics.rectangle("fill",x*120-120,y*120,120,120)
		end
	end

end