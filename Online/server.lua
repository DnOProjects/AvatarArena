lovernetlib = require('Online/lovernet')
server = lovernetlib.new{type=lovernetlib.mode.server}

function server.load()
	server:addOp('q') --query (send gameState to client)
	server:addOp('p') --point (recieve keyPresses)
	print("loaded")
	if onlineGame then
		server:addProcessOnServer('q',function(self,peer,arg,storage)
			print("here")
			return canvas:newImageData():getString()
		end)
	end

	server:addValidateOnServer('p',{key='string'})

	server:addProcessOnServer('p',function(self,peer,arg,storage)
	  	user = self:getUser(peer)
	  	server.keyInput(arg.key)
	end)

end

function server.keyInput(key,source)

	if gameState == "game" then
		if key=="escape" then
			gameState="paused"
			pausedSelection=3
		end
		if players[1].controller=="human" or source=="ai" then
			if(moveSet[1] == 0)then
				if key=="r" then players.move(1,0) end
				if key=="f" then players.move(1,2) end
				if key=="d" then players.move(1,3) end
				if key=="g" then players.move(1,1) end

				if key=="2" then moves.cast(3,players[1].power,1) end
				if key=="1" then moves.cast(2,players[1].attack,1) end
				if key=="`" then moves.cast(1,players[1].utility,1) end
			elseif(moveSet[1] == 1)then
				if key=="w" then players.move(1,0) end
				if key=="s" then players.move(1,2) end
				if key=="a" then players.move(1,3) end
				if key=="d" then players.move(1,1) end

				if key=="6" then moves.cast(3,players[1].power,1) end
				if key=="5" then moves.cast(2,players[1].attack,1) end
				if key=="4" then moves.cast(1,players[1].utility,1) end
			end
		end

		if players[2].controller=="human" or source=="ai" then
			if(moveSet[2] == 0)then
				if key=="up" then players.move(2,0) end
				if key=="down" then players.move(2,2) end
				if key=="left" then players.move(2,3) end
				if key=="right" then players.move(2,1) end

				if key=="/" then moves.cast(3,players[2].power,2) end
				if key=="." then moves.cast(2,players[2].attack,2) end
				if key=="," then moves.cast(1,players[2].utility,2) end
			end
		end
	end

	if gameState=="characterSelection" or gameState=="menu" or gameState=="paused" or gameState=="winScreen" then
		if key=="escape" and (gameState=="menu" or gameState=="characterSelection") then 
			gameState="menu"
		end
		if(moveSet[1] == 0)then
			if key=="r" then ui[1].y=ui[1].y-1 end
			if key=="f" then ui[1].y=ui[1].y+1 end
			if key=="d" then ui.switch(-1,1) end
			if key=="g" then ui.switch(1,1) end
			if key=="r" or key=="f" or key=="d" or key=="g" then showDescription = 1 end
		elseif(moveSet[1] == 1)then
			if key=="w" then ui[1].y=ui[1].y-1 end
			if key=="s" then ui[1].y=ui[1].y+1 end
			if key=="a" then ui.switch(-1,1) end
			if key=="d" then ui.switch(1,1) end
			if key=="w" or key=="s" or key=="a" or key=="d" then showDescription = 1 end
		end

		if(moveSet[2] == 0)then
			if key=="up" then ui[2].y=ui[2].y-1 end
			if key=="down" then ui[2].y=ui[2].y+1 end
			if key=="left" then ui.switch(-1,2) end
			if key=="right" then ui.switch(1,2) end
			if key=="up" or key=="down" or key=="left" or key=="right" then showDescription = 2 end
		end

		if key=="return" then ui.start() 
		end
	end

	if key=="escape" and gameState=="winScreen"then
		gameState="menu"
	end

end
