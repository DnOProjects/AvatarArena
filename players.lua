players = {}

local basePlayer={controller="human",beenBlown=false,char=2,x=1,y=1,d=0,timer=0,invulnerability=0,hp=100,maxHp=100,chiRegen=4,chi=0,maxChi=100,utility=1,attack=1,power=1}
for i=1,2 do
	players[i]=logic.copyTable(basePlayer)
end
players[2].x,players[2].y=16,8

function players.load()

	players.world = "physical"
	players.shiftTimer = 0
	
	lineOfSightWidth = 5

	elements = {"air","water","earth","fire"}

	characters = {
{name="Aang",chiRegen=4,img=aangImg,portrait=aangPortrait,moveTimer=0.1,hp=64,bends={"air","earth","fire","water","energy","normal"}},
{name="Katara",chiRegen=4,img=kataraImg,portrait=kataraPortrait,moveTimer=0.15,hp=120,bends={"water","normal"}},
{name="Iroh",chiRegen=8,img=irohImg,portrait=irohPortrait,moveTimer=0.15,hp=80,bends={"fire","normal"}},
{name="Toph",chiRegen=4,img=tophImg,portrait=tophPortrait,moveTimer=0.15,hp=140,bends={"earth","normal"}},
{name="Gyatso",chiRegen=6,img=gyatsoImg,portrait=gyatsoPortrait,moveTimer=0,hp=90,bends={"air","normal"}},
{name="Sokka",chiRegen=4,img=sokkaImg,portrait=sokkaPortrait,moveTimer=0.15,hp=130,bends={"sokka","normal"}}
}

	p1 = players[1]
	p2 = players[2]
	players[1] = {blinking=false,machineGunning=false,flameTrail=false,flying=false,controller="human",lineOfSight={},deflecting=false,beenBlown=false,char=p1.char,x=1,y=1,d=0,vd=false,timer=0,slideTimer=0,invulnerability=0,hp=100,maxHp=100,chiRegen=4,chi=0,maxChi=100,utility=p1.utility,attack=p1.attack,power=p1.power}
	players[2] = {blinking=false,machineGunning=false,flameTrail=false,flying=false,controller="human",lineOfSight={},deflecting=false,beenBlown=false,char=p2.char,x=16,y=8,d=0,vd=false,timer=0,slideTimer=0,invulnerability=0,hp=100,maxHp=100,chiRegen=4,chi=0,maxChi=100,utility=p2.utility,attack=p2.attack,power=p2.power}
	
	players.loadParicles()

end

function players.loadParicles()

	particleImg=love.graphics.newImage("images/abilities/particle.png")

	fireParticles = love.graphics.newParticleSystem(particleImg, 10000)
	fireParticles:setParticleLifetime(1, 1.5)
	fireParticles:setEmissionRate(1000)
	fireParticles:setSizeVariation(1)
	fireParticles:setLinearAcceleration(-30, 6, 30, 120)
	fireParticles:setColors(0, 0.34, 0.85, 255, 0, 0.018, 0.065, 100)
	fireParticles:setSpread(2)
	fireParticles:setSizes(4,2,1)
	fireParticles:setSpin(10)

	fireBreathParticles = love.graphics.newParticleSystem(particleImg, 10000)
	fireBreathParticles:setParticleLifetime(1, 1.5)
	fireBreathParticles:setEmissionRate(1000)
	fireBreathParticles:setSizeVariation(1)
	fireBreathParticles:setLinearAcceleration(-30, 6, 30, 400)
	fireBreathParticles:setColors(0.73, 0.14, 0, 255, 0, 0, 0, 100)
	fireBreathParticles:setSpread(2)
	fireBreathParticles:setSizes(4,2,1)
	fireBreathParticles:setSpin(10)

	blinkParticles = love.graphics.newParticleSystem(particleImg, 10000)
	blinkParticles:setParticleLifetime(1, 0.1)
	blinkParticles:setEmissionRate(100)
	blinkParticles:setSizeVariation(1)
	blinkParticles:setLinearAcceleration(-30, 6, 30, 400)
	blinkParticles:setColors(1, 1, 1, 255, 0.47, 0.47, 0.47, 100)
	blinkParticles:setSpread(2)
	blinkParticles:setSizes(1,4,8)
	blinkParticles:setSpin(10)
	
end

function players.update(dt)
	if debugMode then for i=1,2 do players[i].chi=100 end end
	players.updateGameEvents(dt)
	players.updateTimer(dt)
	players.checkForBlock()
	if gameEndFade==false then players.checkForHits() end --So you can't take damage during the fade out
	players.checkForLineOfSight()
	players.poolChi(dt)
	players.fall()
	players.machineGun(dt)
	players.die()
	fireParticles:update(dt)
	fireBreathParticles:update(dt)
	blinkParticles:update(dt)
end

	function players.machineGun(dt)
		for i=1,2 do
			local p=players[i]
			if p.machineGunning~= false and math.random(1,7)==1 then
				projectiles[#projectiles+1] = {meltable=true,name=name,damage=20,image=bulletImg,x=p.x,y=p.y,d=p.d,speed = 15,rx=0,ry=0}
				projectiles[#projectiles] = moves.moveProj(#projectiles,1)
			end
		end
	end

	function players.fall()
		for i=1,2 do
			local p=players[i]
			local walkOver = false
			for i=1,#projectiles do
				local pr=projectiles[i]
				if p.x == pr.rx and p.y == pr.ry and pr.walkOver == true then walkOver = true end
			end
			if map[p.x][p.y]==0 and p.flying==false and walkOver==false then
				p.hp=0
			end
		end
	end

	function players.updateGameEvents(dt)
		if gameEvent=="sea of chi" then
			for i=1,2 do
				players[i].chiRegen = characters[players[i].char].chiRegen*((eventTimer+25)/50)
			end
		end
		if gameEvent=="power cycle" then
			if eventTimer>=79 then
				eventTimer=0
			end
			local e = math.floor(eventTimer/20)+1
			for i=1,2 do
				local p = players[i]
				if logic.inList(characters[p.char].bends,elements[e]) then players[i].chiRegen = characters[players[i].char].chiRegen*3 else  players[i].chiRegen = characters[players[i].char].chiRegen end
			end
		end
		if gameEvent=="body swap" then
			if eventTimer > bodySwapLength then 
				eventTimer = 0
				local temp = {char=players[1].char,utility=players[1].utility,attack=players[1].attack,power=players[1].power}
				players[1].char = players[2].char
				players[1].utility = players[2].utility
				players[1].attack = players[2].attack
				players[1].power = players[2].power
				players[2].char = temp.char
				players[2].utility = temp.utility
				players[2].attack = temp.attack
				players[2].power = temp.power
			end
		end
		if gameEvent=="time warp" then
			if eventTimer>100 then eventTimer=100 end
			dtMultiplier=eventTimer/10
		end
		if gameEvent=="instablitiy" then
			if eventTimer > 1 then
				eventTimer=0
				local numTiles=0
				for x=1,16 do
					for y=1,8 do
						if map[x][y]==1 then numTiles=numTiles+1 end
					end
				end
				local tileRemoved=false
				if numTiles>10 then
					while not tileRemoved do
						local x = math.random(1,16)
						local y = math.random(1,8)
						if map[x][y]==1 then
							local isOnTornado=false
							for i=1,#projectiles do
								pr=projectiles[i]
								if pr.x==x and pr.y==y and pr.name=="tornadoCentre" then
									isOnTornado=true
								end
							end
							if (not players.playerOnTile(x,y)) and (not isOnTornado) then
								map[x][y]=0
								tileRemoved=true
							end
						end
					end
				end
			end
		end
	end

	function players.playerOnTile(x,y)
		for i=1,2 do
			local p=players[i]
			if p.x==x and p.y==y then return true end
		end
		return false
	end

	function players.poolChi(dt)
		for i=1,2 do
			p=players[i]
			p.chi=p.chi+p.chiRegen*dt
			if p.chi>p.maxChi then p.chi=p.maxChi end
		end
	end

	function players.updateTimer(dt)
		eventTimer=eventTimer+dt
		players.shiftTimer = players.shiftTimer - dt
		if players.shiftTimer < 0 then players.shiftTimer = 0 end
		if players.shiftTimer==0 then players.world="physical" else players.world="spiritual" end

		for i=1,2 do
			p = players[i]
			local onIce = false
			for i=1,#projectiles do
				local pr = projectiles[i]
				if pr.x==p.x and pr.y==p.y and pr.name=="ice" then
					onIce = true
				end
			end
			if onIce then
				p.timer = p.timer - (dt*10000)
			else
				p.timer = p.timer - dt
			end
			if p.machineGunning~= false then p.machineGunning = p.machineGunning - dt end
			if p.machineGunning~= false and p.machineGunning<0 then p.machineGunning=false end
			if p.blinking~= false then p.blinking = p.blinking - dt end
			if p.blinking~= false and p.blinking<0 then p.blinking=false end
			p.slideTimer = p.slideTimer - dt
			p.invulnerability = p.invulnerability - dt*10
			if p.flying~=false then p.flying=p.flying-dt end
			if p.flying~=false and p.flying<0 then p.flying,p.fireJet=false,false end
			if p.flameTrail~=false then p.flameTrail=p.flameTrail-dt end
			if p.flameTrail~=false and p.flameTrail<0 then p.flameTrail=false end
			if p.timer < 0 then p.timer = 0 end
			if p.slideTimer < 0 then p.slideTimer = 0 end
			if p.invulnerability < 0 then p.invulnerability = 0 end
		end
	end

	function players.checkForLineOfSight()
		for pn=1,2 do
			p = players[pn]
			for widthMod=-(lineOfSightWidth-1)/2,(lineOfSightWidth-1)/2 do
				if p.d == 0 then
					for lengthMod=1,p.y do
						table.insert(p.lineOfSight,{x=p.x+widthMod,y=lengthMod})
					end
				elseif p.d == 1 then
					for lengthMod=p.x,16 do
						table.insert(p.lineOfSight,{x=lengthMod,y=p.y+widthMod})
					end
				elseif p.d == 2 then
					for lengthMod=p.y,8 do
						table.insert(p.lineOfSight,{x=p.x+widthMod,y=lengthMod})
					end
				elseif p.d == 3 then
					for lengthMod=1,p.x do
						table.insert(p.lineOfSight,{x=lengthMod,y=p.y+widthMod})
					end
				end
			end
		end
	end

	function players.checkForBlock()
		for i=1,2 do
			p=players[i]
			p.deflecting = false
			for j=1,#projectiles do
				proj=projectiles[j]
				if proj.deflector == true and proj.caster == i then
					p.deflecting = true
				end
			end
		end
	end

	function players.removeOnHit(pr,n1,n2)
		if pr.removesOnHit == nil or pr.removesOnHit==true then
			if pr.removesOnHitCaster == nil or (pr.removesOnHitCaster == false and pr.caster ~= n2) or (pr.removesOnHitCaster == true and pr.caster == n2) then
				projectilesToRemove[#projectilesToRemove+1] = n1
			end
		end
	end

	function players.checkForHits()
		for i=1,2 do
			local p=players[i]
			local op=players[1]
			if i==1 then op=players[2] end
			if p.x==op.x and p.y==op.y and op.fireJet and players[i].invulnerability==0 and players[i].deflecting == false and players[i].hp > 0 then --jetpack burning
				players[i].hp=players[i].hp-4
				players[i].invulnerability = 10
			end

			for j=1,#projectiles do
				if not(logic.inList(projectilesToRemove,i) or players[i].flying~=false) then
					if projectiles[j].damage>0 and projectiles[j].rx==players[i].x and projectiles[j].ry==players[i].y and players[i].invulnerability==0 and players[i].deflecting == false and players[i].hp > 0 then
						if not(projectiles[j].name=="sprout" and projectiles[j].caster==i) and not(projectiles[j].damagesCaster == false and projectiles[j].caster==i) then
							players[i].hp=players[i].hp-projectiles[j].damage
							players[i].invulnerability = 10
						end
						players.removeOnHit(projectiles[j],j,i)
					elseif projectiles[j].damage < 0 and projectiles[j].rx==players[i].x and projectiles[j].ry==players[i].y and players[i].hp < players[i].maxHp then
						players[i].hp=players[i].hp-projectiles[j].damage
						if players[i].hp > players[i].maxHp then players[i].hp = players[i].maxHp end
						players.removeOnHit(projectiles[j],j,i)
					end

				end
			end
			if players[i].hp < 0 then
				players[i].hp=0
			end
		end
	end

	function players.die()
		if gameEndFade==false then
			for i=1,2 do
				local op=players[1]
				local p=players[i]
				if i==1 then op=players[2] end

				if p.hp <= 0 and op.hp>0 then
				    gameEndFade=4
				    loser = i
				    if loser==1 then winner=2 else winner=1 end
				    if gameMode=="Competitive" then
				    	gameResults = {winxp=2,losexp=1}
				    	local w = battlingAccounts[winner]
				    	local l = battlingAccounts[loser]
				    	if w.trophies<=l.trophies then 
				    		gameResults.wintrophies = 20 + math.random(-3,3) 
				    		gameResults.losetrophies = - 16 + math.random(-3,3)
				    	else
				    		gameResults.wintrophies = 10 + math.random(-3,3)
				    		gameResults.losetrophies = - 8 + math.random(-3,3)
				    	end

				    	local movesUsed={moves[1][players[winner].utility].name,moves[2][players[winner].attack].name,moves[3][players[winner].power].name}
				    	local questUnlocked = false
				    	for j=1,3 do
				    		if not questUnlocked then
					    		if logic.inList(movesUsed,w.quests[j]) then
					    			questUnlocked = true
					    			gameResults.questCompleted=w.quests[j]
					    			gameResults.winxp=gameResults.winxp+7+math.random(-1,1)
					    			local questFound=false
					    			while not questFound do
					    				local n= math.random(1,3)
					    				local m= math.random(1,#moves[n])
					    				if not(w.quests[j]==moves[n][m].name) then
						    				if w.unlocks[n][m]==true then 
						    					questFound = true 
						    					SAVED.accounts[w.index].quests[j]=moves[n][m].name
						    				end
						    			end
					    			end
					    		end
					    	end
				    	end

				    	SAVED.accounts[w.index].trophies=SAVED.accounts[w.index].trophies+gameResults.wintrophies
				    	SAVED.accounts[l.index].trophies=SAVED.accounts[l.index].trophies+gameResults.losetrophies
				    	SAVED.accounts[w.index].xp=SAVED.accounts[w.index].xp+gameResults.winxp
				    	SAVED.accounts[l.index].xp=SAVED.accounts[l.index].xp+1			    	

				    	if l.trophies<0 then l.trophies=0 end
				    end
				end

				if p.hp <= 0 and op.hp <= 0 then
					gameEndFade=4
					loser="draw"
					if gameMode=="Competitive" then
						gameResults = {xp=1,trophies=0}
						for i=1,2 do
							battlingAccounts[i].xp=battlingAccounts[i].xp+1--draw condition for competitive is WIP
						end
					end
				end
			end
		end
	end

function players.draw()

	local drawOrder={1,1}--so the player not flying goes under the other
	if players[2].flying~=false then drawOrder[2]=2 else drawOrder[1]=2 end

	for i=1,2 do
		local p = players[drawOrder[i]]
		love.graphics.setColor(255,255,255)
		if p.invulnerability>0 then
			rgb(255,255,255,(math.sin(p.invulnerability)+1)*100)
		end
		local yOffset=0
		if p.flying ~= false then 
			yOffset=-50
			local flameYOffset=0 --so when iroh is looking down it doesn't look like he is breathing fire
			if p.d==2 then flameYOffset=-10 end 
			if p.fireJet then love.graphics.draw(fireParticles, p.x*120-60,p.y*120+60+yOffset+flameYOffset) end
		end

		breathingFire=false
		for j=1,#projectiles do if projectiles[j].name == "fire breath" and projectiles[j].caster==drawOrder[i] then breathingFire=true end end
		if breathingFire then love.graphics.draw(fireBreathParticles, p.x*120-60,p.y*120+60+yOffset,(p.d+2)*0.5*math.pi) end
		if players[drawOrder[i]].blinking ~= false then love.graphics.draw(blinkParticles, p.x*120-60,p.y*120+60+yOffset,(p.d)*0.5*math.pi) end
		
		if p.vd == false or p.vd == nil then
			love.graphics.draw(characters[p.char].img,p.x*120-60,p.y*120+60+yOffset,math.pi*p.d/2,1,1,60,60)
		else
			love.graphics.draw(characters[p.char].img,p.x*120-60,p.y*120+60+yOffset,math.pi*p.vd/2,1,1,60,60)
		end
		love.graphics.setColor(255,255,255)
	end

end

function players.move(p,d,unconditional)
	local tilesPerPress = 1
	if players[p].blinking ~= false then tilesPerPress = 2 end
	ox,oy = players[p].x,players[p].y
	for i=1,#projectiles do
		pr = projectiles[i]
		if pr.movesWithCaster == true and pr.caster == p then
			pr.ox,pr.oy=pr.x,pr.y
		end
	end
	if (players[p].timer==0 or unconditional or players[p].flameTrail~=false) then
		if not unconditional then
			players[p].timer = characters[players[p].char].moveTimer 
		end
		players[p].d = d
		players[p].lineOfSight = {}
		if players[p].deflecting == true then
			for i=1,#projectiles do
				pr = projectiles[i]
				if pr.movesWithCaster == false and pr.caster == p then
					players[p].deflecting = false
				end
			end
		end
		for i=1,#projectiles do
			pr = projectiles[i]
			if pr.movesWithCaster == true and pr.caster == p then
				if d==0 then pr.y=pr.y-tilesPerPress end
				if d==1 then pr.x=pr.x+tilesPerPress end
				if d==2 then pr.y=pr.y+tilesPerPress end
				if d==3 then pr.x=pr.x-tilesPerPress end
			end
		end
		if d==0 then players[p].y=players[p].y-tilesPerPress end
		if d==1 then players[p].x=players[p].x+tilesPerPress end
		if d==2 then players[p].y=players[p].y+tilesPerPress end
		if d==3 then players[p].x=players[p].x-tilesPerPress end
	end

	--[[sliding
	willSlide=false
	for i=1,#projectiles do
		local pr = projectiles[i]
		if pr.name=="ice" then 
			if players[p].x==pr.x and players[p].y==pr.y then
				willSlide=true
			end
		end
	end
	if willSlide then
		players.move(p,d,true)
	end]]

	if not(players.canBeHere(p)) then 
		players[p].x = ox
		players[p].y = oy
		for i=1,#projectiles do
			pr = projectiles[i]
			if pr.movesWithCaster == true and pr.caster == p then
				pr.x = pr.ox
				pr.y = pr.oy
			end
		end
	end

	if players[p].x~=ox or players[p].y~=oy then --if they moved
		if players[p].flameTrail~=false then
			projectiles[#projectiles+1] = {despawn=4,percent=0,spriteLength=4,aSpeed=4,name="burningGround",damage=20,image=stillFlameImg,x=ox,y=oy,d=0,speed = 0,rx=0,ry=0}
		end
	end

end	

	function players.canBeHere(n)
		p=players[n]
		on=n+1
		if on==3 then on=1 end
		op=players[on]

		if p.x<1 or p.x>16 or p.y<1 or p.y>8
		or (p.x==op.x and p.y==op.y and ((p.flying==false and op.flying==false)or(p.flying~=false and op.flying~=false))) then return false end

		local walkOver = false
		for i=1,#projectiles do
			local pr=projectiles[i]
			if p.x == pr.rx and p.y == pr.ry and pr.walkOver == true then walkOver = true end
		end

		if map[p.x][p.y]==0 and p.flying==false and walkOver==false then return false end

		for i=1,#projectiles do
			local pr=projectiles[i]
			if pr.blocker and p.x==pr.rx and p.y==pr.ry and not(pr.blocker=="forceField" or pr.blocker=="fragileForceField" or pr.blocker=="fragileField") then return false  end
		end

		return true
	end

	function players.canCast(p)
		for i=1,#projectiles do
			local pr=projectiles[i]
			if pr.rx==p.x and pr.ry==p.y then
				if pr.name == "aurora borealis" then return false end
			end
		end
		return true
	end