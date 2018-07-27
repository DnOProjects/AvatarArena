require "logic"
ui = {y=0}

function ui.load()
	font = love.graphics.newFont("font.ttf",72)
	love.graphics.setFont(font)

	winScreen = love.graphics.newImage("winScreenBackground.png")

	playerSelecting=1

	for i=1,2 do
		ui[#ui+1] = {}
		for j=1,3 do
			ui[i][#ui[i]+1] = 1
		end
	end

end

function ui.update()
	if ui.y<0 then ui.y=0 end
	if ui.y>4 then ui.y=4 end
end

function ui.switch(d)
	if ui.y==0 then
		players[playerSelecting].char = players[playerSelecting].char + d
		if players[playerSelecting].char > #characters then players[playerSelecting].char = 1 end
		if players[playerSelecting].char < 1 then players[playerSelecting].char = #characters end
		for i=1,3 do ui[playerSelecting][i] = 1 end
	elseif ui.y==4 then
		playerSelecting = playerSelecting+d
		if playerSelecting==0 then playerSelecting=1 end
		if playerSelecting==3 then
			startGame() 
		end
	else
		canWield=false
		while not canWield do
			ui[playerSelecting][ui.y]=ui[playerSelecting][ui.y]+d
			if ui[playerSelecting][ui.y]==0 then ui[playerSelecting][ui.y] = #moves[ui.y] end
			if ui[playerSelecting][ui.y]>#moves[ui.y] then ui[playerSelecting][ui.y] = 1 end
			char=characters[players[playerSelecting].char]
			for i=1,#char.bends do
				if char.bends[i]==moves[ui.y][ui[playerSelecting][ui.y]].type then canWield = true end
			end
		end
	end
end

function ui.draw()

	p1=players[1]
	char1=characters[p1.char]

	p2=players[2]
	char2=characters[p2.char]

	if gameState == "characterSelection" then
		love.graphics.setLineWidth(2)
		love.graphics.setColor(255,255,255)
		love.graphics.draw(char1.portrait,100,100)
		love.graphics.draw(char1.img,500,215.6,0,2,2)
		if ui.y==0 and playerSelecting==1 then love.graphics.rectangle("line",500,215.6,240,240) end
		love.graphics.printf(char1.name,500,100,240,"center")
		love.graphics.printf("Hp:100         water..air",100,450,1280,"center",0,0.5)

		love.graphics.setColor(255,255,255)
		love.graphics.draw(char2.portrait,1180,100)
		love.graphics.draw(char2.img,1580,215.6,0,2,2)
		if ui.y==0 and playerSelecting==2 then love.graphics.rectangle("line",1580,215.6,240,240) end
		love.graphics.printf(char2.name,1580,100,240,"center")
		love.graphics.printf("Hp:100         water..air",1180,450,1280,"center",0,0.5)

		for i=1,2 do
			for j=1,3 do
				if ui.y==j and playerSelecting==i then love.graphics.setLineWidth(20) end
				box=ui[i][j]
				move = moves[j][box]
				love.graphics.rectangle("line",(i-1)*1080+100,j*130+400,500,100,5,5)
				love.graphics.printf(move.name,(i-1)*1080+30,j*130+413,800,"center",0,0.8)
				love.graphics.setLineWidth(2)
			end
			if playerSelecting==i and ui.y==4 then love.graphics.setLineWidth(20) end
			love.graphics.circle("line",(i-1)*1080+350,1000,50)
			love.graphics.setLineWidth(2)
		end

	end

	if gameState == "game" then
		love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),120)

		love.graphics.setColor(0,0,0)
		love.graphics.print(players[1].hp,200,5)
		love.graphics.print(players[2].hp,love.graphics.getWidth()-295,5)
		love.graphics.printf(logic.round(players[1].chi,0),253,80,100,"right",0,0.4,0.4)
		love.graphics.print(logic.round(players[2].chi,0),love.graphics.getWidth()-295,80,0,0.4,0.4)

		love.graphics.setColor(143,145,147,100)
		love.graphics.rectangle("fill",300,15,600,70)
		love.graphics.rectangle("fill",300,95,600,10)
		love.graphics.rectangle("fill",1620,15,-600,70)
		love.graphics.rectangle("fill",1620,95,-600,10)

		love.graphics.setColor(255,0,0)
		love.graphics.rectangle("fill",300,15,600*(players[1].hp/players[1].maxHp),70)
		love.graphics.rectangle("fill",1620,15,-600*(players[2].hp/players[2].maxHp),70)

		love.graphics.setColor(163,198,255)
		love.graphics.rectangle("fill",300,95,600*(players[1].chi/players[1].maxChi),10)
		love.graphics.rectangle("fill",1620,95,-600*(players[2].chi/players[2].maxChi),10)
	end

	if gameState == "winScreen" then
		if loser==1 then winner=2 else winner=1 end
		love.graphics.draw(winScreen, 0, 0, 0, 1920/winScreen:getWidth(), 1080/winScreen:getHeight())
		love.graphics.draw(characters[players[winner].char].portrait,810,200)
		love.graphics.draw(characters[players[loser].char].portrait,865,800,0,0.5,0.5)
		love.graphics.setColor(0,0,0)
		love.graphics.setLineWidth(4)
		love.graphics.rectangle("line",809,199,252,358,5,5)
		love.graphics.rectangle("line",864,799,126,179,5,5)
		love.graphics.print("Winner",820,130)
		love.graphics.print("Loser",866,750,0,0.7)
		love.graphics.setLineWidth(20)
		love.graphics.circle("line",930,660,50)
		love.graphics.setColor(255,255,255)
	end

end