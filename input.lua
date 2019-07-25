local utf8 = require("utf8")
input = {}

function input.keyInput(inputSource,key,source)

	if popup==0 then
		if gameState == "game" and gameEndFade==false then
			if key=="escape" then
				gameState="paused"
				pausedSelection=3
			end
			if players[1].controller=="human" or source=="ai" then
				if(moveSet[1] == 1)then
					if inputSource == "keyboard" then
						if key=="r" then players.move(1,0) end
						if key=="f" then players.move(1,2) end
						if key=="d" then players.move(1,3) end
						if key=="g" then players.move(1,1) end

						if key=="2" then moves.cast(3,players[1].power,1) end
						if key=="1" then moves.cast(2,players[1].attack,1) end
						if key=="`" then moves.cast(1,players[1].utility,1) end
					end
				elseif(moveSet[1] == 2)then
					if inputSource == "keyboard" then
						if key=="w" then players.move(1,0) end
						if key=="s" then players.move(1,2) end
						if key=="a" then players.move(1,3) end
						if key=="d" then players.move(1,1) end

						if key=="6" then moves.cast(3,players[1].power,1) end
						if key=="5" then moves.cast(2,players[1].attack,1) end
						if key=="4" then moves.cast(1,players[1].utility,1) end
					end
				elseif(moveSet[1] == 3)then
					if inputSource == "keyboard" then
						if key=="w" then players.move(1,0) end
						if key=="s" then players.move(1,2) end
						if key=="a" then players.move(1,3) end
						if key=="d" then players.move(1,1) end
					elseif inputSource == "mouse" then
						if key==3 then moves.cast(3,players[1].power,1) end
						if key==1 then moves.cast(2,players[1].attack,1) end
						if key==2 then moves.cast(1,players[1].utility,1) end
					end
				end
			end

			if players[2].controller=="human" or source=="ai" then
				if(moveSet[2] == 1)then
					if inputSource == "keyboard" then
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
		end

		if gameState=="loadAccount" or gameMode=="unset" or gameState=="characterSelection" or gameState=="menu" or gameState=="controllerSelection" or gameState=="paused" or gameState=="winScreen" then
			if key=="escape" and (gameState=="controllerSelection" or gameState=="characterSelection") then 
				gameState="menu"
			end
			if not (typingName and gameState=="loadAccount") then
				if(moveSet[1] == 1)then
					if key=="r" then ui.switch(0,1,-1) end
					if key=="f" then ui.switch(0,1,1) end
					if key=="d" then ui.switch(-1,1) end
					if key=="g" then ui.switch(1,1) end
					if key=="r" or key=="f" or key=="d" or key=="g" then showDescription = 1 end
				elseif(moveSet[1] == 2 or moveSet[1] == 3)then
					if key=="w" then ui.switch(0,1,-1) end
					if key=="s" then ui.switch(0,1,1) end
					if key=="a" then ui.switch(-1,1) end
					if key=="d" then ui.switch(1,1) end
					if key=="w" or key=="s" or key=="a" or key=="d" then showDescription = 1 end
				end

				if(moveSet[2] == 1)then
					if key=="up" then ui.switch(0,2,-1) end
					if key=="down" then ui.switch(0,2,1) end
					if key=="left" then ui.switch(-1,2) end
					if key=="right" then ui.switch(1,2) end
					if key=="up" or key=="down" or key=="left" or key=="right" then showDescription = 2 end
				end
			end

			if gameState=="characterSelection" and key=="return" then
				if ui[showDescription].y > 0 and ui[showDescription].y < 4 then
					tipDisplaying = love.graphics.newVideo("Videos/"..moves[ui[showDescription].y][ui[showDescription][ui[showDescription].y]].name..".ogv",{audio=false})
					tipDisplaying:rewind()
					tipDisplaying:play()
				end
			end

			if key=="return" then ui.start() end
		end

		if key=="escape" and (gameState=="menu" or gameState=="loadAccount") then
			gameMode="unset"
			gameState="unset"
		end

		if key=="escape" and gameState=="winScreen" then
			if gameMode~="Competitive" then gameState="menu"
			else 
				gameState="loadAccount" 
				battlingAccounts={}
			end
		end

		if key==";" and (gameState=="menu" or gameState=="controllerSelection") then love.system.openURL("https://github.com/DnOProjects/AvatarArena/wiki") end

	    if key == "backspace" and gameState=="loadAccount" and typingName then
	        local byteoffset = utf8.offset(newAccountName, -1)
	        if byteoffset then
	            newAccountName = string.sub(newAccountName, 1, byteoffset - 1)
	        end
	    end
	end
end