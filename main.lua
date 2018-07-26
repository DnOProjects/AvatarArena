require "map"
require "players"
require "moves"
require "ui"

function love.load()

	love.window.setFullscreen(true)
	love.mouse.setVisible(false)
    love.graphics.setDefaultFilter("nearest","linear", 100 )

    map.load()
    moves.load()
    players.load()
    ui.load()

    gameState = "characterSelection"

end

function love.update(dt)

	players.update(dt)
	moves.update(dt)
	ui.update()

end

function love.draw()

	if gameState=="game" then
		map.draw()
		moves.draw()
		players.draw()
	end
		ui.draw()

	love.graphics.print(love.timer.getFPS())

end

function love.keypressed(key)

	if gameState == "game" then
		if key=="up" then players.move(1,0) end
		if key=="down" then players.move(1,2) end
		if key=="left" then players.move(1,3) end
		if key=="right" then players.move(1,1) end

		if key=="/" then moves.cast(3,players[1].power,1) end
		if key=="." then moves.cast(2,players[1].attack,1) end
		if key=="," then moves.cast(1,players[1].utility,1) end


		if key=="r" then players.move(2,0) end
		if key=="f" then players.move(2,2) end
		if key=="d" then players.move(2,3) end
		if key=="g" then players.move(2,1) end

		if key=="3" then moves.cast(3,players[2].power,2) end
		if key=="2" then moves.cast(2,players[2].attack,2) end
		if key=="1" then moves.cast(1,players[2].utility,2) end
	end

	if gameState=="characterSelection" then
		if key=="up" then ui.y=ui.y-1 end
		if key=="down" then ui.y=ui.y+1 end
		if key=="left" then ui.switch(-1) end
		if key=="right" then ui.switch(1) end
	end

end