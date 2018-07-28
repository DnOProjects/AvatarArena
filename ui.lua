require "logic"
ui = {y=0}

function ui.load()
	font = love.graphics.newFont("fonts/font.ttf",72)
	descriptionFont = love.graphics.newFont("fonts/descriptionFont.ttf",72)
	love.graphics.setFont(font)

	winScreen = love.graphics.newImage("Images/winScreenBackground.png")

	waterSymbolImg = love.graphics.newImage("images/symbols/waterSymbol.png")
	earthSymbolImg = love.graphics.newImage("images/symbols/earthSymbol.png")
	airSymbolImg = love.graphics.newImage("images/symbols/airSymbol.png")
	fireSymbolImg = love.graphics.newImage("images/symbols/fireSymbol.png")

	elementSymbols={water=waterSymbolImg,earth=earthSymbolImg,air=airSymbolImg,fire=fireSymbolImg}

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

		if ui.y<4 then
			love.graphics.rectangle("line",700,40,500,1000)
			if ui.y==0 then 
				c=characters[players[playerSelecting].char]
				love.graphics.print("Character:",780,70)
				love.graphics.print("Hp: "..c.hp,720,200,0,0.8,0.8) 
				love.graphics.print("Chi: "..c.chiRegen,720,300,0,0.8,0.8) 
				if not(c.name=="Sokka") then love.graphics.print("Bends:",840,400) end
				for i=1,#c.bends do
					e=c.bends[i]
					if not(e=="normal" or e=="energy" or e=="sokka") then
						local y=0
						if i>2 then y=1 end
						love.graphics.draw(elementSymbols[e],i*230+490-(y*460),500+y*230)
					end
				end
			else 
				move = moves[ui.y][ui[playerSelecting][ui.y]]
				love.graphics.printf(move.name..":",720,70,600,"center",0,0.8,0.8)
				local textYOffset=0
				if not(move.type=="normal" or move.type=="energy" or move.type=="sokka") then
					love.graphics.draw(elementSymbols[move.type],840,200)
					textYOffset=300 
				end
				love.graphics.setFont(descriptionFont)
				love.graphics.printf(move.desc,710,200+textYOffset,990,"left",0,0.5,0.5)
				love.graphics.setFont(font)
			end
		end

		love.graphics.draw(char1.portrait,10,100)
		love.graphics.draw(char1.img,410,215.6,0,2,2)
		if ui.y==0 and playerSelecting==1 then love.graphics.rectangle("line",410,215.6,240,240) end
		love.graphics.printf(char1.name,410,100,240,"center")
		love.graphics.printf("Hp:100         water..air",10,450,1280,"center",0,0.5)

		love.graphics.setColor(255,255,255)
		love.graphics.draw(char2.portrait,1270,100)
		love.graphics.draw(char2.img,1670,215.6,0,2,2)
		if ui.y==0 and playerSelecting==2 then love.graphics.rectangle("line",1670,215.6,240,240) end
		love.graphics.printf(char2.name,1670,100,240,"center")
		love.graphics.printf("Hp:100         water..air",1270,450,1280,"center",0,0.5)

		for i=1,2 do
			for j=1,3 do
				if ui.y==j and playerSelecting==i then love.graphics.setLineWidth(20) end
				box=ui[i][j]
				move = moves[j][box]
				love.graphics.rectangle("line",(i-1)*1260+10,j*130+400,500,100,5,5)
				love.graphics.printf(move.name,(i-1)*1260-60,j*130+413,800,"center",0,0.8)
				love.graphics.setLineWidth(2)
			end
			if playerSelecting==i and ui.y==4 then love.graphics.setLineWidth(20) end
			love.graphics.circle("line",(i-1)*1260+260,1000,50)
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