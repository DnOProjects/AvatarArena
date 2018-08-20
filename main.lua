require "logic"
require "map"
require "players"
require "moves"
require "ui"
require "ai"
require "animate"
require "Images/images"
require "Sounds/sound"
require "Server/server"

function love.load()

	debugMode=false

	math.randomseed(os.time())
	if not(onlineGame) then
		love.window.setFullscreen(true)
	end

	love.mouse.setVisible(false)
    love.graphics.setDefaultFilter("nearest","linear", 100 )

    map.load()
    moves.load()
    players.load()
    ui.load()
    sound.load()

    server.load()

    gameState = "menu"
    projectilesToRemove = {}
    showDescription = 1

    moveSet = {0,0}

end

function love.update(dt)

	if players.timeSlowTimer>0 then dt=dt/5 end

	server:update(dt)

	if gameState=="game" then
		if players[2].controller=="ai" then ai.update(dt) end
		players.update(dt)
		moves.update(dt)
		animate.update(dt)
	end
	ui.update()
	sound.update(dt)

	removeProjectiles()

end

	function removeProjectiles()
		table.sort(projectilesToRemove)
		for i=#projectilesToRemove,1,-1 do
			table.remove(projectiles,projectilesToRemove[i])
			table.remove(projectilesToRemove,i)
		end
	end

function love.draw()

	if onlineGame then
		canvas = love.graphics.newCanvas(1920,1080)
		love.graphics.setCanvas(canvas)
	end

	if gameState=="game" then
		map.draw()
		moves.draw()
		players.draw()
	end

	ui.draw()

	if onlineGame then
		love.graphics.setCanvas()
		love.graphics.print("Running server..")
	end

	if debugMode then
		love.graphics.setColor(0,1,0)
		love.graphics.print("Debug Mode:",0,0,0,0.6,0.6)
		love.graphics.print("FPS:  "..love.timer.getFPS(),0,50,0,0.4,0.4)
		love.graphics.print("# Projectiles:  "..#projectiles,0,80,0,0.4,0.4)
		love.graphics.setColor(1,1,1)
	end

end

function startGame()
	players.load()
	map.load()
	projectiles = {}
	gameEvent = menu[5].options[menu[5].selected]
	gameState = "game" 
	eventTimer=0
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
	if key=="9" then 
		if debugMode then ambientMusic:play() else ambientMusic:pause() end
		debugMode=not debugMode 
	end
	if not onlineGame then server.keyInput(key) end
end