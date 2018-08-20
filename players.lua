players = {}

local basePlayer={controller="human",beenBlown=false,char=1,x=1,y=1,d=0,timer=0,invulnerability=0,hp=100,maxHp=100,chiRegen=4,chi=0,maxChi=100,utility=1,attack=1,power=1}
for i=1,2 do
	players[i]=logic.copyTable(basePlayer)
end
players[2].x,players[2].y=16,8

function players.load()

	players.world = "physical"
	players.shiftTimer = 0
	players.timeSlowTimer = 0
	
	lineOfSightWidth = 5

	elements = {"air","water","earth","fire"}

	characters = {
{name="Aang",chiRegen=4,img=aangImg,portrait=aangPortrait,moveTimer=0.1,hp=64,bends={"air","earth","fire","water","energy","normal"}},
{name="Katara",chiRegen=4,img=kataraImg,portrait=kataraPortrait,moveTimer=0.15,hp=120,bends={"water","normal"}},
{name="Iroh",chiRegen=8,img=irohImg,portrait=irohPortrait,moveTimer=0.15,hp=80,bends={"fire","normal"}},
{name="Toph",chiRegen=4,img=tophImg,portrait=tophPortrait,moveTimer=0.15,hp=130,bends={"earth","normal"}},
{name="Gyatso",chiRegen=6,img=gyatsoImg,portrait=gyatsoPortrait,moveTimer=0,hp=80,bends={"air","normal"}},
{name="Sokka",chiRegen=4,img=sokkaImg,portrait=sokkaPortrait,moveTimer=0.15,hp=130,bends={"sokka","normal"}}
}

	p1 = players[1]
	p2 = players[2]
	players[1] = {flameTrail=false,flying=false,controller="human",lineOfSight={},deflecting=false,beenBlown=false,char=p1.char,x=1,y=1,d=0,vd=0,timer=0,slideTimer=0,invulnerability=0,hp=100,maxHp=100,chiRegen=4,chi=0,maxChi=100,utility=p1.utility,attack=p1.attack,power=p1.power}
	players[2] = {flameTrail=false,flying=false,controller="human",lineOfSight={},deflecting=false,beenBlown=false,char=p2.char,x=16,y=8,d=0,vd=0,timer=0,slideTimer=0,invulnerability=0,hp=100,maxHp=100,chiRegen=4,chi=0,maxChi=100,utility=p2.utility,attack=p2.attack,power=p2.power}
	
	img=love.graphics.newImage("images/abilities/particle.png")
	fireParicles = love.graphics.newParticleSystem(img, 10000)
	fireParicles:setParticleLifetime(1, 1.5)
	fireParicles:setEmissionRate(1000)
	fireParicles:setSizeVariation(1)
	fireParicles:setLinearAcceleration(-30, 6, 30, 120)
	fireParicles:setColors(0, 0.34, 0.85, 255, 0, 0.018, 0.065, 100)
	fireParicles:setSpread(2)
	fireParicles:setSizes(4,2,1)
	fireParicles:setSpin(10)

end

function players.update(dt)
	if debugMode then for i=1,2 do players[i].chi=100 end end
	players.updateGameEvents(dt)
	players.updateTimer(dt)
	players.checkForBlock()
	players.checkForHits()
	players.checkForLineOfSight()
	players.poolChi(dt)
	players.fall()
	players.die()
	fireParicles:update(dt)
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
		
		players.timeSlowTimer = players.timeSlowTimer - dt
		if players.timeSlowTimer < 0 then players.timeSlowTimer = 0 end

		for i=1,2 do
			p = players[i]
			p.timer = p.timer - dt
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
						if not(projectiles[j].name=="seed" and projectiles[j].caster==i) and not(projectiles[j].damagesCaster == false and projectiles[j].caster==i) then
							players[i].hp=players[i].hp-projectiles[j].damage
							players[i].invulnerability = 10
						end
						if projectiles[j].removesOnHit == nil or projectiles[j].removesOnHit==true then
							if projectiles[j].removesOnHitCaster == nil or (projectiles[j].removesOnHitCaster == true and projectiles[j].caster == i) then
								projectilesToRemove[#projectilesToRemove+1] = j
							end
						end
					elseif projectiles[j].damage < 0 and projectiles[j].rx==players[i].x and projectiles[j].ry==players[i].y and players[i].hp < players[i].maxHp then
						players[i].hp=players[i].hp-projectiles[j].damage
						if players[i].hp > players[i].maxHp then players[i].hp = players[i].maxHp end
						if projectiles[j].removesOnHit == nil or projectiles[j].removesOnHit==true then
							if projectiles[j].removesOnHitCaster == nil or (projectiles[j].removesOnHitCaster == false and projectiles[j].caster == i) then
								projectilesToRemove[#projectilesToRemove+1] = j
							end
						end
					end

				end
			end
			if players[i].hp < 0 then
				players[i].hp=0
			end
		end
	end

	function players.die()
		for i=1,2 do
			if(players[i].hp <= 0)then
			    players[i].hp=1
			    gameState = "winScreen"
			    pausedSelection=2
			    projectilesToRemove = {}
			    loser = i
			end
		end
	end

function players.draw()

	local drawOrder={1,1}--so the player not flying goes under the other
	if players[2].flying~=false then drawOrder[2]=2 else drawOrder[1]=2 end

	for i=1,2 do
		p = players[drawOrder[i]]
		love.graphics.setColor(255,255,255)
		if p.invulnerability>0 then
			rgb(255,255,255,(math.sin(p.invulnerability)+1)*100)
		end
		local yOffset=0
		if p.flying ~= false then 
			yOffset=-50
			local flameYOffset=0 --so when iroh is looking down it doesn't look like he is breathing fire
			if p.d==2 then flameYOffset=-10 end 
			if p.fireJet then love.graphics.draw(fireParicles, p.x*120-60,p.y*120+60+yOffset+flameYOffset) end
		end
		if logic.round(players[i].vd) == 0 then
			love.graphics.draw(characters[p.char].img,p.x*120-60,p.y*120+60+yOffset,math.pi*p.d/2,1,1,60,60)
		else
			love.graphics.draw(characters[p.char].img,p.x*120-60,p.y*120+60+yOffset,math.pi*p.vd/2,1,1,60,60)
		end
		love.graphics.setColor(255,255,255)
	end

end

function players.move(p,d,unconditional)
	ox,oy = players[p].x,players[p].y
	for i=1,#projectiles do
		pr = projectiles[i]
		if pr.movesWithCaster == true and pr.caster == p then
			pr.ox,pr.oy=pr.x,pr.y
		end
	end
	if (players[p].timer==0 or unconditional) then
		if not unconditional then players[p].timer = characters[players[p].char].moveTimer end
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
				if d==0 then pr.y=pr.y-1 end
				if d==1 then pr.x=pr.x+1 end
				if d==2 then pr.y=pr.y+1 end
				if d==3 then pr.x=pr.x-1 end
			end
		end
		if d==0 then players[p].y=players[p].y-1 end
		if d==1 then players[p].x=players[p].x+1 end
		if d==2 then players[p].y=players[p].y+1 end
		if d==3 then players[p].x=players[p].x-1 end
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