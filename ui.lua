require "Online/client"
local utf8 = require("utf8")

ui = {{y=0},{y=0}}

function ui.load()

	selectedAccount=1
	battlingAccounts={}

	gameMode="unset"

	gameEvent = "unset"

	selectionMethod = "choice"
	ui.randomised=false

	pausedSelection=1

	onlineGame = false
	onlineClient = false

	flashingAlpha = 1
	flashDirection = "falling"

	gameModes={"Classic","Competitive","Campaign"}
	
	--onlineGame, opponentType, numOpponents, selectionMethod,gameEvents
	menu = {{name="Connection",selected=1,options={"local","online"}},
	{name="Oppenent",selected=1,options={"human","ai"}},
	{name="Difficulty",selected=2,options={"easy","medium","hard","expert"}},
	{name="Selection",selected=1,options={"choice","random","random duel","blind","blind duel"}},
	{name="Events",selected=1,options={"none","night","sea of chi","power cycle","instablitiy","time warp"}}}
	menu2Options = {{name="Oppenent",selected=1,options={"human","ai"}},{name="Role",selected=1,options={"client","server"}}}

	controller = {{name="Input Device",selected=1,options={"keys/mouse","controller"}},
	{name="Player",selected=1,options={"1 (left)","2 (right)"}},
	{name="Move Set 1",selected=1,options={"RDFG+` 1 2","WASD+4 5 6","WASD+Mouse"}},
	{name="Move Set 2",selected=1,options={"Arrow+, . /"}}}

	menuStage=1

	impactFont = love.graphics.newFont("Fonts/font.ttf",72)
	descriptionFont = love.graphics.newFont("Fonts/descriptionFont.ttf",72)
	menuFont = love.graphics.newFont("Fonts/menuFont.ttf",72)

	elementSymbols={water=waterSymbolImg,earth=earthSymbolImg,air=airSymbolImg,fire=fireSymbolImg}

	for i=1,2 do
		ui[#ui+1] = {}
		for j=1,3 do
			ui[i][#ui[i]+1] = 1
		end
	end

	ui.gameStartCountdown=3

end

function ui.randomMove(type,player)
	picked = false
	while not picked do
		c=characters[players[player].char]
		validMoves={}
		for i=1,#moves[type] do
			if logic.inList(c.bends,moves[type][i].type) then validMoves[#validMoves+1] = i end
		end
		mq = validMoves[math.random(1,#validMoves)]
		picked = true
		if moves[type][mq].type=="normal" and math.random(1,4)>1 then picked = false end
	end
	return mq --I am very sorry for using 2 meaningles letters - have an apology semicolon - (;) - there, much better
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
	if selectionMethod == "blind duel" or (selectionMethod == "random duel" and not ui.randomised) then
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
		ui.randomised=true
	end
end

function ui.menuY()
	local oy = menuStage
	local changer = 1
	for i=1,2 do
		local ny = ui[i].y+1
		if ny ~= oy then
			changer = i
			local other = 1
			if changer == 1 then other = 2 end
			ui[other].y = ui[changer].y
			break
		end
	end
	menuStage = ui[changer].y+1
	if gameState == "menu" then
		if menuStage==3 and menu[2].options[menu[2].selected]=="human" then
			if oy == 2 then ui[changer].y = 4-1 end
			if oy == 4 then ui[changer].y = 2-1 end
		end
		if menu[1].options[menu[1].selected]=="online" then
			if ui[changer].y > 1 then ui[changer].y = 1 end
			menu[2] = menu2Options[2]
		else
			menu[2] = menu2Options[1]
		end
	elseif gameState == "controllerSelection" then
		if ui[changer].y > 3 then ui[changer].y = 3 end
		if menuStage==2 and menu[2].options[menu[2].selected]=="human" then
			if oy == 1 then ui[changer].y = 3-1 end
			if oy == 3 then ui[changer].y = 1-1 end
		end
	end
end

function ui.flashAlpha(dt)
	if flashingAlpha <= 0 then flashingAlpha = 0; flashDirection = "rising" end
	if flashingAlpha >= 1 then flashingAlpha = 1; flashDirection = "falling" end
	if flashDirection == "falling" then flashingAlpha = flashingAlpha - dt end
	if flashDirection == "rising" then flashingAlpha = flashingAlpha + dt end
end

function ui.update(dt)

	ui.flashAlpha(dt/1.2)
	if gameState == "characterSelection" then 
		dtMultiplier = 1
		if ui[1].y == 4 and ui[2].y == 4 and gearIsUnlocked(1,players[1].char) and gearIsUnlocked(2,players[2].char) then
			ui.gameStartCountdown=ui.gameStartCountdown-dt
		else
			ui.gameStartCountdown=3
		end
		ui.choose() 
		if ui.gameStartCountdown<0.5 then startGame() end
	end
	if gameState == "menu" or gameState == "controllerSelection" then ui.menuY(); dtMultiplier = 1 end
	for playerSelecting=1,2 do
		if ui[playerSelecting].y<0 then ui[playerSelecting].y=0 end
		if ui[playerSelecting].y>4 then ui[playerSelecting].y=4 end
	end
	moveSet = {controller[3].selected,controller[4].selected}
	if aiPlayer ~= nil then moveSet[aiPlayer] = 1 end
end

function ui.switch(x,playerSelecting,y)
	if y then
		selectedAccount=selectedAccount+y
		if selectedAccount<1 then selectedAccount=9 end
		if selectedAccount>9 then selectedAccount=1 end
		ui[playerSelecting].y=ui[playerSelecting].y+y
		if ui[playerSelecting].y<0 then ui[playerSelecting].y=4 end
		if ui[playerSelecting].y>4 then ui[playerSelecting].y=0 end
	end
	if gameState=="loadAccount" and x==1 then
		love.system.setClipboardText(love.data.encode("string","base64",bitser.dumps(SAVED.accounts[selectedAccount-2])))
	end
	if gameMode=="unset" then
		selectedGameMode=selectedGameMode+x
		if selectedGameMode>#gameModes then selectedGameMode=1 end
		if selectedGameMode<1 then selectedGameMode = #gameModes end
	end
	if gameState=="paused" or gameState=="winScreen" then
		local maxOpt=3
		if gameState=="winScreen" then maxOpt=2 end
		pausedSelection = pausedSelection + x
		if pausedSelection<1 then pausedSelection = maxOpt end
		if pausedSelection>maxOpt then pausedSelection=1 end
	end
	if gameState=="menu" then
		menu[menuStage].selected = menu[menuStage].selected+x
		if menu[menuStage].selected > #menu[menuStage].options then menu[menuStage].selected = 1 end
		if menu[menuStage].selected < 1 then menu[menuStage].selected = #menu[menuStage].options end
	elseif gameState=="controllerSelection" then
		controller[menuStage].selected = controller[menuStage].selected+x
		if controller[menuStage].selected > #controller[menuStage].options then controller[menuStage].selected = 1 end
		if controller[menuStage].selected < 1 then controller[menuStage].selected = #controller[menuStage].options end
	elseif gameState=="characterSelection" and selectionMethod=="choice" and x~=0 then
		if ui[playerSelecting].y==0 then
			players[playerSelecting].char = players[playerSelecting].char + x
			if players[playerSelecting].char > #characters then players[playerSelecting].char = 1 end
			if players[playerSelecting].char < 1 then players[playerSelecting].char = #characters end
			for i=1,3 do
				j=1
				moveTypeIsValid = false
				while not moveTypeIsValid do
					ui[playerSelecting][i] = j
					if logic.inList(characters[players[playerSelecting].char].bends,moves[i][j].type) then moveTypeIsValid = true end
					j=j+1
				end
			end
		elseif not(ui[playerSelecting].y==4) then
			canWield=false
			while not canWield do
				ui[playerSelecting][ui[playerSelecting].y]=ui[playerSelecting][ui[playerSelecting].y]+x
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
		if menu[1].options[menu[1].selected]=="online" then
			if menu[2].options[menu[2].selected]=="server" then 
				onlineGame = true
				startGame()
			else 
				onlineClient = true 
			end
		else
			gameState = "controllerSelection"
			selectionMethod = menu[4].options[menu[4].selected]
			ui[1].y = 0
			ui[2].y = 0
		end
	elseif gameState=="controllerSelection" then
		if menu[2].options[menu[2].selected]=="ai" then
			humanPlayer = controller[2].selected
			if humanPlayer == 1 then aiPlayer = 2 else aiPlayer = 1 end
			moveSet[aiPlayer] = 1
		end
		gameState = "characterSelection"
		ui[1].y = 0
		ui[2].y = 0
	elseif gameState=="characterSelection" then
		if ui[1].y == 4 and ui[2].y == 4 and gameMode~="Competitive" then
			startGame()
		end
	elseif (gameState=="winScreen" or gameState=="paused") then 
		if pausedSelection==2 then
			gameState="characterSelection" 
			map.load()
			players.load()
			ui[1].y = 0
			ui[2].y = 0
			projectiles	= {}
		end
		if pausedSelection==1 then
			ui.load()
			gameState="menu"
		end
		if pausedSelection==3 then
			gameState="game"
		end
	end
	if gameState=="loadAccount" then
		if selectedAccount==1 then ui.addAccount("new")
		elseif selectedAccount==2 then ui.addAccount(love.system.getClipboardText())
		else
			if #battlingAccounts<2 and (not logic.inList(battlingAccounts,SAVED.accounts[selectedAccount-2])) then 
				battlingAccounts[#battlingAccounts+1] = SAVED.accounts[selectedAccount-2]  
			end
			if #battlingAccounts==2 then
				gameState="characterSelection"
			end
		end
	end
	if gameMode == "unset" then 
		gameMode = gameModes[selectedGameMode] 
		if gameMode=="Classic" then gameState="menu" end
		if gameMode=="Competitive" then
			typingName=false 
			gameState="loadAccount" 
			battlingAccounts={}
		end
	end
end

function ui.draw()
	if gameState == "winScreen" or gameState == "paused" then
		maxOpt=3
		love.graphics.draw(winScreen, 0, 0, 0, 1920/winScreen:getWidth(), 1080/winScreen:getHeight())
		if gameState == "winScreen" then
			maxOpt=2
			if loser~="draw" then
				love.graphics.draw(characters[players[winner].char].portrait,810,200)
				love.graphics.draw(characters[players[loser].char].portrait,865,800,0,0.5,0.5)
				love.graphics.setColor(0,0,0)
				love.graphics.setLineWidth(4)
				love.graphics.rectangle("line",809,199,252,358,5,5)
				love.graphics.rectangle("line",864,799,126,179,5,5)
				love.graphics.print("Winner: Player "..winner,690,125)
				love.graphics.print("Loser: Player "..loser,770,745,0,0.7)
			else
				love.graphics.setColor(0,0,0)
				love.graphics.print("It's a draw!",600,300,0,2,2)
			end
		end
		love.graphics.setColor(0,0,0)
		if gameState=="paused" then 
			love.graphics.print("Paused",700,300,0,2,2) 
		end
		local offset=0
		if gameState=="paused" then offset=-100 end
		for i=1,maxOpt do
			if pausedSelection==i then love.graphics.setColor(0,0,0) else rgb(100,100,100) end
			local symbol=backSymbolImg
			if i==2 then symbol=restartSymbolImg end
			if i==3 then symbol=playSymbolImg end
			love.graphics.draw(symbol,offset+540+i*200,580,0,0.7,0.7)
		end
		love.graphics.setColor(255,255,255)
	end

	if gameState=="loadAccount" then
		rgb(255,255,255)
		love.graphics.draw(winScreen, 0, 0, 0, 1920/winScreen:getWidth(), 1080/winScreen:getHeight())
		if typingName then
			love.graphics.setColor(flashingAlpha,flashingAlpha,flashingAlpha,flashingAlpha)
			love.graphics.print("What is your name?",700,330,0,0.5,0.5)
			rgb(50,50,50,200)
			love.graphics.rectangle("fill",450,420,960,200)
			rgb(255,255,255)
			love.graphics.printf(newAccountName,450,420,533,"center",0,1.8,1.8)
		end
		for i=1,9 do
			rgb(50,50,50,100)
			if logic.inList(battlingAccounts,SAVED.accounts[i-2]) then rgb(132, 75, 0, 200) end
			if i==selectedAccount then rgb(200,200,200,200) end
			if i==selectedAccount and logic.inList(battlingAccounts,SAVED.accounts[i-2]) then rgb(166,137.5,100,200) end
			love.graphics.rectangle("fill",50,i*120-115,800,110)
			rgb(0,0,0)
			if i>2 then
				local toPrint="UNSET"
				if SAVED.accounts[i-2] ~= nil then toPrint = SAVED.accounts[i-2].name end
				love.graphics.printf(toPrint,50,(i-2)*120+130,800,"center",0,1,1)
				rgb(20, 82, 206,200)
				if SAVED.accounts[i-2] ~= nil then
					love.graphics.print(SAVED.accounts[i-2].trophies,80,(i-2)*120+130)
				end
			end
		end
		rgb(132, 75, 0)
		love.graphics.printf("Create new",50,10,800,"center",0,1,1)
		love.graphics.printf("Load from string",50,130,800,"center",0,1,1)
		rgb(0,0,0)

		if selectedAccount>2 and SAVED.accounts[selectedAccount-2] ~= nil then
			local a =  SAVED.accounts[selectedAccount-2]
			love.graphics.print("Name: "..a.name,1000,50,0,1,1)
			love.graphics.print("Trophies: "..a.trophies,1000,150,0,1,1)
			love.graphics.print("Level: "..a.level.."/42",1000,250,0,1,1)
			love.graphics.print("Xp: "..a.xp.."/"..logic.getNumXP(a.level),1000,350,0,1,1)
			love.graphics.rectangle("fill",1000,500,800,75,20,20)
			local segmentWidth = 800/((logic.getNumXP(a.level)*3)+1)
			for i=1,logic.getNumXP(a.level)*3 do
				if i%3~=0 then
					if math.ceil(i/3) <= a.xp then rgb(0,0,255) else rgb(255,255,255) end
					love.graphics.rectangle("fill",1000+(segmentWidth*i),512.5,segmentWidth,50)
				end
			end
			rgb(20, 82, 206,200)
			love.graphics.print(a.level+1,1810,482)
			rgb(50,50,50,200)
			love.graphics.rectangle("fill",1000,600,800,460)
			rgb(109, 84, 0, 200)
			for i=1,3 do
				love.graphics.rectangle("fill",1035+((i-1)*250),630,225,400)
			end
		end
		rgb(255,255,255)
	end

	if gameState == "menu" or gameMode=="unset" then
		love.graphics.setFont(menuFont)
		love.graphics.draw(menuScreen,0,0,0,love.graphics.getWidth()/menuScreen:getWidth(),love.graphics.getHeight()/menuScreen:getHeight())
		love.graphics.printf("Avatar Arena",0,20,700,"center",0,2.7,2.7)
		if gameState == "menu" then
			rgb(200,200,200,flashingAlpha*255)
			love.graphics.print("Press ENTER to continue",1260,1000,0,0.7,0.7)
			love.graphics.print("Press ; to read the wiki",1410,25,0,0.58,0.58)
			for i=1,#menu do
				if not(i == 3 and menu[2].options[menu[2].selected] == "human") and not(i ~= 1 and i ~= 2 and menu[1].options[menu[1].selected] == "online") then
					if menuStage == i then rgb(209, 63, 37) else rgb(150,150,150) end
					love.graphics.printf(menu[i].name,55,150*i+100,500,"right",0,1.8,1.8)
					love.graphics.setColor(255,255,255)
					love.graphics.printf(menu[i].options[menu[i].selected],1000,150*i+100,500,"left",0,1.8,1.8)
				end
			end
		end
	end

	if gameMode=="unset" then
		love.graphics.printf(gameModes[selectedGameMode],200,550,800,"center",0,2,2)
	end

	if gameState == "controllerSelection" then
		love.graphics.setFont(menuFont)
		love.graphics.draw(menuScreen,0,0,0,love.graphics.getWidth()/menuScreen:getWidth(),love.graphics.getHeight()/menuScreen:getHeight())
		love.graphics.printf("Select Controller",10,20,700,"center",0,2.7,2.7)
		rgb(200,200,200,flashingAlpha*255)
		love.graphics.print("Press ENTER to start",1360,1000,0,0.7,0.7)
		love.graphics.print("Press ; to read the wiki",1410,25,0,0.58,0.58)
		for i=1,#controller do
			if not(i == 2 and menu[2].options[menu[2].selected] == "human") then
				if menuStage == i then rgb(209, 63, 37) else rgb(150,150,150) end
				love.graphics.printf(controller[i].name,55,150*i+100,500,"right",0,1.8,1.8)
				love.graphics.setColor(255,255,255)
				love.graphics.printf(controller[i].options[controller[i].selected],1000,150*i+100,500,"left",0,1.8,1.8)
			end
		end
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
						if not(gameMode=="Competitive" and not logic.inList(battlingAccounts[i].chars,p.char)) then
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
						else
							love.graphics.draw(lockedSymbolImg,700,290)
						end
					else -- Moves description
						if not(gameMode=="Competitive" and battlingAccounts[i].unlocks[ui[i].y][ui[i][ui[i].y]]==false) then
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
						else
							love.graphics.draw(lockedSymbolImg,700,290)
						end
					end
				end
			end
			if not(gameMode=="Competitive" and not logic.inList(battlingAccounts[i].chars,p.char)) then
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
			else
				love.graphics.draw(lockedSymbolImg,150+(i*1300)-1300,50,0,0.5,0.5)
			end

			for j=1,3 do
				box=ui[i][j]
				move = moves[j][box]
				if ui[i].y==j then love.graphics.setLineWidth(20) end
				love.graphics.rectangle("line",(i-1)*1260+10,j*130+400,500,100,5,5)
				if not(gameMode=="Competitive" and battlingAccounts[i].unlocks[j][box]==false) then
					love.graphics.printf(move.name,(i-1)*1260-60,j*130+413,800,"center",0,0.8)
				else
					love.graphics.printf("LOCKED",(i-1)*1260-60,j*130+413,800,"center",0,0.8)
				end
				love.graphics.setLineWidth(2)
			end
			if ui[i].y==4 then love.graphics.setLineWidth(20) end
			if gearIsUnlocked(i,p.char) then rgb(255,255,255) else rgb(255,0,0) end
			love.graphics.circle("line",(i-1)*1260+260,1000,50)
			rgb(255,255,255)
			love.graphics.setLineWidth(2)
		end

		if ui[1].y == 4 and ui[2].y == 4 and gearIsUnlocked(1,players[1].char) and gearIsUnlocked(2,players[2].char) then
			love.graphics.setColor(1,0,0)
			love.graphics.print(logic.round(ui.gameStartCountdown,0),850,350,0,4,4)
			love.graphics.setColor(1,1,1)
		end
	end

	if gameState == "game" then

		love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),120)

		love.graphics.setColor(0,0,0)
		love.graphics.print(players[1].hp,200,5)
		love.graphics.print(players[2].hp,love.graphics.getWidth()-295,5)
		love.graphics.printf(logic.round(players[1].chi,0),253,80,100,"right",0,0.4,0.4)
		love.graphics.print(logic.round(players[2].chi,0),love.graphics.getWidth()-295,80,0,0.4,0.4)

		rgb(143,145,147,100)
		love.graphics.rectangle("fill",300,15,600,70)
		love.graphics.rectangle("fill",300,95,600,10)
		love.graphics.rectangle("fill",1620,15,-600,70)
		love.graphics.rectangle("fill",1620,95,-600,10)

		rgb(255,0,0)
		love.graphics.rectangle("fill",300,15,600*(players[1].hp/players[1].maxHp),70)
		love.graphics.rectangle("fill",1620,15,-600*(players[2].hp/players[2].maxHp),70)

		rgb(163,198,255)
		love.graphics.rectangle("fill",300,95,600*(players[1].chi/players[1].maxChi),10)
		love.graphics.rectangle("fill",1620,95,-600*(players[2].chi/players[2].maxChi),10)

		for i=1,2 do
			local p=players[i]
			for j=1,3 do
				local c=moves[1][p.utility].cost
				if j==2 then c = moves[2][p.attack].cost end
				if j==3 then c = moves[3][p.power].cost end
				if players[i].chi>=c then 
					rgb(242,187,38)
					love.graphics.setLineWidth(4) 
				else 
					love.graphics.setColor(0,0,0)
					love.graphics.setLineWidth(1) 
				end
				c=600*c/players[i].maxChi
				if i==2 then c=-c end
				local baseX = 1320*i-1020
				love.graphics.line(baseX+c,96,baseX+c,104)
			end
		end

		rgb(163,120,4)
		if gameEvent == "sea of chi" then love.graphics.print("X"..logic.round(((eventTimer+25)/50),1),900,10,0,0.9,0.9) end
		if gameEvent == "time warp" then love.graphics.print("X"..logic.round(((eventTimer)/10),1),900,10,0,0.9,0.9) end		
		love.graphics.setColor(255,255,255)
		if gameEvent == "power cycle" then love.graphics.draw(elementSymbols[tostring(elements[math.floor(eventTimer/20)+1])],916,15,0,0.4,0.4)end

		love.graphics.setColor(255,255,255)
	end
end

function ui.addAccount(string)
	if string=="new" then
		if not typingName then
			typingName=true
			newAccountName=""
		else
			if not (ui.accountAlreadyExists(newAccountName)) then
				local unlocks={}
				for i=1,3 do
					unlocks[i]={}
					for j=1,#moves[i] do
						unlocks[i][j]=false
					end
				end
				unlocks[1][1]=true
				unlocks[2][1]=true
				unlocks[3][1]=true
				SAVED.accounts[#SAVED.accounts+1] = {name=newAccountName,trophies=0,level=1,xp=0,quests={},unlocks=unlocks,chars={2,3,4,5}}
			end
			typingName=false
		end
	else
		local newAccount = bitser.loads(love.data.decode("string","base64",string))
		if not (ui.accountAlreadyExists(newAccount.name)) then
			SAVED.accounts[#SAVED.accounts+1] =  newAccount
		else
			for i=1,#SAVED.accounts do
				local a = SAVED.accounts[i]
				if a.name==newAccount.name then SAVED.accounts[i]=newAccount end
			end			
		end
	end
end

function ui.accountAlreadyExists(name)
	for i=1,#SAVED.accounts do
		local a = SAVED.accounts[i]
		if a.name==name then return true end
	end
	return false
end

function love.textinput(t)
	if gameState=="loadAccount" then
		if newAccountName:len()<11 then
	    	newAccountName = newAccountName .. t
	    end
	end
end

function gearIsUnlocked(i,char)
	if gameMode=="Competitive" then
		local account = battlingAccounts[i]
		if not logic.inList(account.chars,char) then return false end
		for j=1,3 do
			if battlingAccounts[i].unlocks[j][ui[i][j]]==false then return false end
		end
	end
	return true
end