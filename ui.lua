require "logic"
ui = {{y=0},{y=0}}

function ui.load()

	selectionMethod = "choice"
	ui.randomised=false
	
	--onlineGame, opponentType, numOpponents, selectionMethod,gameEvents
	menu = {{name="Connection",selected=1,options={"local","online"}},
	{name="Oppenent",selected=1,options={"human","ai"}},
	{name="Opponent Count",selected=1,options={1,2,3}},
	{name="Selection",selected=1,options={"choice","blind duel","random","blind"}},
	{name="Events",selected=1,options={"none"}}}
	menuStage=1

	impactFont = love.graphics.newFont("fonts/font.ttf",72)
	descriptionFont = love.graphics.newFont("fonts/descriptionFont.ttf",72)
	menuFont = love.graphics.newFont("fonts/menuFont.ttf",72)

	elementSymbols={water=waterSymbolImg,earth=earthSymbolImg,air=airSymbolImg,fire=fireSymbolImg}

	for i=1,2 do
		ui[#ui+1] = {}
		for j=1,3 do
			ui[i][#ui[i]+1] = 1
		end
	end

end

function ui.randomMove(type,player)
	c=characters[players[player].char]
	validMoves={}
	for i=1,#moves[type] do
		if logic.inList(c.bends,moves[type][i].type) then validMoves[#validMoves+1] = i end
	end
	return validMoves[math.random(1,#validMoves)]
end

function ui.choose()
	if selectionMethod == "blind" or (selectionMethod == "random" and not ui.randomised)then
		for i=1,2 do 
			players[i].char=math.random(1,#characters)
			for j=1,3 do
				ui[i][j]=ui.randomMove(j,i)
			end
		end
		ui.randomised=true
	end
	if selectionMethod == "blind duel" then
		c=math.random(1,#characters)
		for i=1,2 do players[i].char=c end
		m={}
		for i=1,3 do
			m[#m+1]=ui.randomMove(i,1)
		end
		for i=1,2 do
			for j=1,3 do
				ui[i][j]= m[j]
			end
		end
	end
end

function ui.update()
	if gameState == "characterSelection" then ui.choose() end
	for playerSelecting=1,2 do
		if ui[playerSelecting].y<0 then ui[playerSelecting].y=0 end
		if ui[playerSelecting].y>4 then ui[playerSelecting].y=4 end
	end
end

function ui.switch(d,playerSelecting)
	if gameState=="menu" then
		menu[menuStage].selected = menu[menuStage].selected+1
		if menu[menuStage].selected > #menu[menuStage].options then menu[menuStage].selected = 1 end
		if menu[menuStage].selected < 1 then menu[menuStage].selected = #menu[menuStage].options end
	elseif selectionMethod=="choice" then
		if ui[playerSelecting].y==0 then
			players[playerSelecting].char = players[playerSelecting].char + d
			if players[playerSelecting].char > #characters then players[playerSelecting].char = 1 end
			if players[playerSelecting].char < 1 then players[playerSelecting].char = #characters end
			for i=1,3 do ui[playerSelecting][i] = 1 end
		elseif not(ui[playerSelecting].y==4) then
			canWield=false
			while not canWield do
				ui[playerSelecting][ui[playerSelecting].y]=ui[playerSelecting][ui[playerSelecting].y]+d
				if ui[playerSelecting][ui[playerSelecting].y]==0 then ui[playerSelecting][ui[playerSelecting].y] = #moves[ui[playerSelecting].y] end
				if ui[playerSelecting][ui[playerSelecting].y]>#moves[ui[playerSelecting].y] then ui[playerSelecting][ui[playerSelecting].y] = 1 end
				char=characters[players[playerSelecting].char]
				for i=1,#char.bends do
					if char.bends[i]==moves[ui[playerSelecting].y][ui[playerSelecting][ui[playerSelecting].y]].type then canWield = true end
				end
			end
		end
	end
end

function ui.start()
	if gameState=="menu" then
		menuStage=menuStage+1
		if menuStage==3 and menu[2].options[menu[2].selected]=="human" then menuStage=4 end
		if menuStage>5 or menu[1].options[menu[1].selected]=="online" then 
			gameState = "characterSelection"
			selectionMethod = menu[4].options[menu[4].selected]
		end
		if menu[1].options[menu[1].selected]=="online" then onlineGame = true end
	else
		if ui[1].y == 4 and ui[2].y == 4 then
			startGame()
		end
	end
end

function ui.draw()

	if gameState == "menu" then
		love.graphics.setFont(menuFont)
		love.graphics.draw(menuScreen,0,0,0,love.graphics.getWidth()/menuScreen:getWidth(),love.graphics.getHeight()/menuScreen:getHeight())
		love.graphics.setColor(150,150,150)
		love.graphics.printf(menu[menuStage].name,-10,200,700,"center",0,2.8,2.8)
		love.graphics.setColor(255,255,255)
		love.graphics.printf(menu[menuStage].options[menu[menuStage].selected],500,800,500,"center",0,2,2)
	end

	if gameState == "characterSelection" then
		love.graphics.setFont(impactFont)
		for i=1,2 do
			p=players[i]
			char=characters[p.char]

			love.graphics.setLineWidth(2)
			love.graphics.setColor(255,255,255)
			love.graphics.print(i,120+(1255*(i-1)),10)
			if ui[i].y<4 then
				love.graphics.rectangle("line",700,40,500,1000)
				if showDescription == i then
					if ui[i].y==0 then -- Char description
						c=characters[players[i].char]
						love.graphics.print("Character:",780,70)
						love.graphics.print("Hp: "..c.hp,720,200,0,0.8,0.8) 
						love.graphics.print("Chi: "..c.chiRegen,720,300,0,0.8,0.8) 
						if not(c.name=="Sokka") then love.graphics.print("Bends:",840,400) end
						for j=1,#c.bends do
							e=c.bends[j]
							if not(e=="normal" or e=="energy" or e=="sokka") then
								local y=0
								if j>2 then y=1 end
								love.graphics.draw(elementSymbols[e],j*230+490-(y*460),500+y*230)
							end
						end
					else -- Moves description
						move = moves[ui[i].y][ui[i][ui[i].y]]
						love.graphics.printf(move.name..":",720,70,600,"center",0,0.8,0.8)
						local textYOffset=0
						if not(move.type=="normal" or move.type=="energy" or move.type=="sokka") then
							love.graphics.draw(elementSymbols[move.type],840,200)
							textYOffset=300 
						end
						love.graphics.print("Chi Cost: "..move.cost,720,135+textYOffset,0,0.8,0.8) 
						love.graphics.setFont(descriptionFont)
						love.graphics.printf(move.desc,710,200+textYOffset,990,"left",0,0.5,0.5)
						love.graphics.setFont(impactFont)
					end
				end
			end

			if i == 1 then
				love.graphics.draw(char.portrait,10,100)
				love.graphics.draw(char.img,410,215.6,0,2,2)
				if ui[1].y==0 then love.graphics.rectangle("line",410,215.6,240,240) end
				love.graphics.printf(char.name,410,100,240,"center")
			elseif i == 2 then
				love.graphics.setColor(255,255,255)
				love.graphics.draw(char.portrait,1270,100)
				love.graphics.draw(char.img,1670,215.6,0,2,2)
				if ui[2].y==0 then love.graphics.rectangle("line",1670,215.6,240,240) end
				love.graphics.printf(char.name,1670,100,240,"center")
			end

			for j=1,3 do
				if ui[i].y==j then love.graphics.setLineWidth(20) end
				box=ui[i][j]
				move = moves[j][box]
				love.graphics.rectangle("line",(i-1)*1260+10,j*130+400,500,100,5,5)
				love.graphics.printf(move.name,(i-1)*1260-60,j*130+413,800,"center",0,0.8)
				love.graphics.setLineWidth(2)
			end
			if ui[i].y==4 then love.graphics.setLineWidth(20) end
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
		love.graphics.print("Winner: Player "..winner,690,125)
		love.graphics.print("Loser: Player "..loser,770,745,0,0.7)
		love.graphics.setLineWidth(20)
		love.graphics.circle("line",930,660,50)
		love.graphics.setColor(255,255,255)
	end

end

