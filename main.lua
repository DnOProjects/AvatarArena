require "logic"
require "keyPress"
require "map"
require "players"
require "moves"
require "ui"
require "ai"
require "animate"
require "Images/images"
require "Sounds/sound"

function love.load()

	startServer = true

	debugMode = false

	math.randomseed(os.time())
	if not(onlineGame) then
		love.window.setFullscreen(true)
		love.window.setMode(love.graphics.getWidth(), love.graphics.getHeight(), {borderless=true,display=1})
	end

	love.mouse.setVisible(false)
    love.graphics.setDefaultFilter("nearest","linear", 100 )

    map.load()
    moves.load()
    players.load()
    ui.load()
    sound.load()

    gameState = "menu"
    projectilesToRemove = {}
    showDescription = 1

    moveSet = {0,0}

end

function love.update(dt)

	if onlineClient == false then
		if gameEvent=="time warp" then dt=dt*dtMultiplier end

		if onlineGame and startServer then
			startServer = false
			love.window.setMode(1000, 700, {resizable=true,borderless=false,minwidth=650,minheight=400})
			require "Online/server"
			server.load()
		end

		if onlineGame then server:update(dt) end

		if gameState=="game" then
			if players[2].controller=="ai" then ai.update(dt) end
			players.update(dt)
			moves.update(dt)
			animate.update(dt)
		end
		ui.update(dt)
		sound.update(dt)

		removeProjectiles()
	else
		client.update(dt)
	end

end

	function removeProjectiles()
		table.sort(projectilesToRemove)
		for i=#projectilesToRemove,1,-1 do
			table.remove(projectiles,projectilesToRemove[i])
			table.remove(projectilesToRemove,i)
		end
	end

function love.draw()

	if onlineClient == false then
		if onlineGame then
			love.graphics.print("Running server..")
		else
			if gameState=="game" then
				map.draw()
				moves.draw()
				players.draw()
			end

			ui.draw()

			if debugMode then
				love.graphics.setColor(0,1,0)
				love.graphics.print("Debug Mode:",0,0,0,0.6,0.6)
				love.graphics.print("FPS:  "..love.timer.getFPS(),0,50,0,0.4,0.4)
				love.graphics.print("# Projectiles:  "..#projectiles,0,80,0,0.4,0.4)
				love.graphics.setColor(1,1,1)
			end
		end
	else
		client.draw(dt)
	end

end

function startGame()
	dtMultiplier=1
	players.load()
	map.load()
	projectiles = {}
	gameEvent = menu[5].options[menu[5].selected]
	gameState = "game" 
	eventTimer=0
	if gameEvent=="time warp" then eventTimer=1 end
	for i=1,2 do
		players[i].utility = ui[i][1]
		players[i].attack = ui[i][2]
		players[i].power = ui[i][3]
	end

	players[1].hp = characters[players[1].char].hp
	players[2].hp = characters[players[2].char].hp

	players[1].maxHp = characters[players[1].char].hp
	players[2].maxHp = characters[players[2].char].hp

	players[1].chiRegen = characters[players[1].char].chiRegen
	players[2].chiRegen = characters[players[2].char].chiRegen

	arenaType = characters[players[1].char].bends[1]
	sound.play("roundIntro")
	if menu[2].options[menu[2].selected]=="ai" then 
		ai.load(1,menu[3].options[menu[3].selected]) 
		players[1].controller = "human"  
		players[2].controller = "ai"
	else
		players[1].controller = "human"  
		players[2].controller = "human" 
	end
end

function love.keypressed(key)
	if onlineClient == false then
		if key=="9" then 
			if debugMode then ambientMusic:play() else ambientMusic:pause() end
			debugMode=not debugMode 
		end
		if not onlineGame then keyPress.keyInput(key) end
	else
		client.keyInput(key)
	end
end