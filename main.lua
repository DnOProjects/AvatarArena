
require "map"
require "players"
require "moves"
require "ui"
require "sound"

function love.load()

	love.window.setFullscreen(true)
	love.mouse.setVisible(false)
    love.graphics.setDefaultFilter("nearest","linear", 100 )

    map.load()
    moves.load()
    players.load()
    ui.load()
    sound.load()

    gameState = "characterSelection"
    projectilesToRemove = {}

    moveSet = {0,0}

end

function love.update(dt)

	players.update(dt)
	moves.update(dt)
	ui.update()
	sound.update(dt)
	animate.update(dt)

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

	if gameState=="game" then
		map.draw()
		moves.draw()
		players.draw()
	end
	ui.draw()

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

	arenaType = characters[players[1].char].bends[1]
	sound.play("roundIntro")
end

function love.keypressed(key)

	if gameState == "game" then
		if(moveSet[1] == 0)then
			if key=="up" then players.move(1,0) end
			if key=="down" then players.move(1,2) end
			if key=="left" then players.move(1,3) end
			if key=="right" then players.move(1,1) end

			if key=="/" then moves.cast(3,players[1].power,1) end
			if key=="." then moves.cast(2,players[1].attack,1) end
			if key=="," then moves.cast(1,players[1].utility,1) end
		end

		if(moveSet[2] == 0)then
			if key=="r" then players.move(2,0) end
			if key=="f" then players.move(2,2) end
			if key=="d" then players.move(2,3) end
			if key=="g" then players.move(2,1) end

			if key=="3" then moves.cast(3,players[2].power,2) end
			if key=="2" then moves.cast(2,players[2].attack,2) end
			if key=="1" then moves.cast(1,players[2].utility,2) end
		elseif(moveSet[2] == 1)then
			if key=="w" then players.move(2,0) end
			if key=="s" then players.move(2,2) end
			if key=="a" then players.move(2,3) end
			if key=="d" then players.move(2,1) end

			if key=="6" then moves.cast(3,players[2].power,2) end
			if key=="5" then moves.cast(2,players[2].attack,2) end
			if key=="4" then moves.cast(1,players[2].utility,2) end
		end
	end

	if gameState=="characterSelection" then
		if key=="up" then ui.y=ui.y-1 end
		if key=="down" then ui.y=ui.y+1 end
		if key=="left" then ui.switch(-1) end
		if key=="right" then ui.switch(1) end
	end

end