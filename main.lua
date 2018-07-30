require "map"
require "players"
require "moves"
require "ui"
require "images"
require "sound"
require "server"
require "client"

function love.load()

	onlineGame = false

	math.randomseed(os.time())
	love.window.setFullscreen(true)
	love.mouse.setVisible(false)
    love.graphics.setDefaultFilter("nearest","linear", 100 )

    map.load()
    moves.load()
    players.load()
    ui.load()
    sound.load()

    server.load()

    gameState = "characterSelection"
    projectilesToRemove = {}

    moveSet = {0,0}

end

function love.update(dt)

	server:update(dt)
	client.updateData(dt)

	if gameState=="game" then
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
		canvas = love.graphics.newCanvas()
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
		client.draw()
	end

end

function startGame()
	gameState = "game" 
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
end