moves = { --first moves must all be normal, then air, water, earth, fire, sokka

--Utility
{{defensive,name="shield",type="normal",cost=5,desc="Equip a shield to block any attack!"},
{name="blow",type="air",cost=8,desc="A funnel of air to propel you forwards or push your opponent back!"},
{defensive,name="fly",type="air",cost=25,desc="You use the air currents around you to hover just above the ground!"},
{name="shift",type="air",cost=18,desc="You shift the battle into the spirit-world, rendering all bending ineffective!"},
{name="freeze",type="water",cost=1,desc="All water in the arena turns to solid ice!"},
{defensive,name="aurora borealis",type="water",cost=8,desc="Using spirit-bending, you summon the spirits of the aurora borealis to defend you."},
{name="heal",type="water",cost=24,desc="Healing is a special ability possessed by some waterbenders that enables them to heal those who have been wounded, including themselves."},
{name="earth wave",type="earth",cost=10,desc="You charge forwards on rolling earth!"},
{name="seismic sense",type="earth",cost=5,desc="Use seismic waves to sense your opponent's position."},
{name="terraform",type="earth",cost=7,desc="Shape the world to your will!"},
{defensive,name="flame wall",type="fire",cost=5,desc="Flames rise up to shield you from harm."},
{defensive,name="redirect",type="fire",cost=8,desc="\"If you let the energy in your own body flow, the lightning will follow through it...\"\n\n\"You must not let the lightning pass through your heart, or the damage could be deadly!\""},
{defensive,name="fire jet",type="fire",cost=12,desc="You use sizzling blue flame to propell yourself above the arena, singeing those who pass under you!"},
{defensive,name="sword block",type="sokka",cost=5,desc="You deflect an enemy's attack, sending it flying away to the side.\n\n"}},

--Attack
{{name="arrow",type="normal",cost=5,desc="A well-placed arrow can be as effective as any pillar of fire or column of rock!"},
{name="gust",type="air",cost=4,desc="A ball of whirling air."},
{name="air ball",type="air",cost=8,desc="A compressed sphere of air that bounces from wall to wall."},
{name="air flurry",type="air",cost=15,desc="Release strands of air to trap your opponent!"},
{name="spurt",type="water",cost=16,desc="A writhing spray of water, ready to force itself down your enemy's throat and drown their very lungs!"},
{name="spout",type="water",cost=9,desc="Shoot a line of well-placed water out in front of you, blocking your enemy's path."},
{name="ice shard",type="water",cost=8,desc="Send a shard of ice at your opponent that splits on contact with projectiles."},
{name="boulder",type="earth",cost=5,desc="A giant rolling boulder - it's a little slow but deals a lot of damage."},
{name="spike",type="earth",cost=10,desc="Huge spikes of earth emerge from the ground in a line."},
{name="bullet",type="earth",cost=15,desc="You bend the metal in the bullet to propell it to very high speeds."},
{name="blast",type="fire",cost=10,desc="Two glowing embers shoot sideways from each hand."},
{name="sear",type="fire",cost=13,desc="Four balls of fire radiate inaccurately from your body."},
{name="fire breath",type="fire",cost=20,desc="Breath out fire, searing any enemies in front of you!"},
{name="boomerang",type="sokka",cost=11,desc="The boomerang whirls around the edge of the arena before returning to your hand."}},

--Power
{{name="blink",type="normal",cost=20,desc="Move at 2 tiles/second to jump gaps and travel quickly!"},
{name="hurricane",type="air",cost=30,desc="A devestating, unpredictable flurry of wind!"},
{name="gale",type="air",cost=30,desc="Blow away incoming projectiles!"},
{name="tornado",type="air",cost=30,desc="Pull your enemies to the centre of a tornado and attack them while they cannot move!"},
{name="flood",type="water",cost=60,desc="The waters rise up to drown your enemies!"},
{name="sprout",type="water",cost=40,desc="A huge thorny plant begins to grow with you, unharmed at its center."},
{name="crystalise",type="water",cost=35,desc="A snowflake of razor sharp ice spikes"},
{name="shockwave",type="earth",cost=30,desc="You send seismic waves rippling through the earth, letting it rise up around you!"},
{name="melt",type="earth",cost=30,desc="Melt all rocks on the map into flowing lava!"},
{name="machine gun",type="earth",cost=30,desc="Use metalbending to launch a spray of bullets into your opponent!"},
{name="lightning",type="fire",cost=60,desc="\"The energy is both yin and yang, you can separate these energies, creating an imbalance. The energy wants to restore balance and in a moment the positive and negative energy come crashing back together. You provide release and guidance, creating lightning.\""},
{name="combustion",type="fire",cost=40,desc="SPARKY SPARKY BOOM"},
{name="flame trail",type="fire",cost=70,desc="Don't touch your tail!"},
{name="sword flurry",type="sokka",cost=60,desc="Swing your sword around you to impale nearby enemies!"}}

}

projectiles = {}

function moves.load()
	-- Nothing here, so sad :(
end

function moves.update(dt)
	moves.moveProjectiles(dt)
	moves.rotateProjectiles(dt)
	moves.roundPositions()
	moves.removeReduntantProjectiles()
	moves.despawn(dt)
	for i=1,#projectiles do moves.updateProjectile(projectiles[i],dt,i) end
	for i=1,2 do 
		if not(players[i].beenBlown==false) then
			if players[i].beenBlown-dt > 0 then players[i].beenBlown = players[i].beenBlown-dt else players[i].beenBlown = false end
		end
	end
end

	function moves.rotateProjectiles(dt)
		for i=1,#projectiles do
			p=projectiles[i]
			if p.vd then
				p.vd=p.vd+10*dt
			end
		end
	end

	function moves.updateProjectile(p,dt,pn)
		if p.name == "fire breath" then
			p.rx=players[p.caster].x
			p.ry=players[p.caster].y
			local playerDirection=players[p.caster].d
			if playerDirection==0 then p.ry=p.ry-p.posNum end
			if playerDirection==1 then p.rx=p.rx+p.posNum end
			if playerDirection==2 then p.ry=p.ry+p.posNum end
			if playerDirection==3 then p.rx=p.rx-p.posNum end
		end
		if p.name == "boomerang" then
			if p.rx==1 and p.d==3 then p.d,p.bounces=0,p.bounces+1 end
			if p.ry==1 and p.d==0 then p.d,p.bounces=1,p.bounces+1 end
			if p.rx==16 and p.d==1 then p.d,p.bounces=2,p.bounces+1 end
			if p.ry==8 and p.d==2 then p.d,p.bounces=3,p.bounces+1 end
			if p.bounces > 4 then
				if p.rx==players[p.caster].x then
					if p.ry>players[p.caster].y then p.d=0 else p.d=2 end
				end
				if p.ry==players[p.caster].y then
					if p.rx>players[p.caster].x then p.d=3 else p.d=1 end
				end
			end
		end
		if p.name == "sprout" then
			if math.random(1,150) == 1 then
				projectiles[#projectiles+1] = {despawn=10,blocker="fragileField",caster=p.caster,rotate=false,name=p.name,damage=10,image=thornsImg,x=p.x,y=p.y,d=p.d+math.random(-1,1),speed = 0,rx=0,ry=0}
				projectiles[#projectiles] = moves.moveProj(#projectiles,1)
				shouldRemove = (projectiles[#projectiles].x == players[p.caster].x) and (projectiles[#projectiles].y == players[p.caster].y)
				for i=1,#projectiles-1 do
					op = projectiles[i]
					if op.name=="sprout" and op.x==projectiles[#projectiles].x and op.y==projectiles[#projectiles].y then shouldRemove = true end
				end
				if shouldRemove then
					projectilesToRemove[#projectilesToRemove+1]=#projectiles
				end
			end
		end
		if p.name == "blow" then
			for i=1,2 do
				pl=players[i]
				if pl.x==p.rx and pl.y==p.ry and not(pl.beenBlown) then
					players.move(i,p.d,true)
					pl.beenBlown=0.1
				end
			end
		end
		if p.name == "ice spike" and p.despawn < 1.7 and p.spawned==false then
			p.spawned=true
			projectiles[#projectiles+1] = {spawned=false,rotate=false,name="ice spike",despawn=2,damage=14,image=iceSpikeImg,x=p.x,y=p.y,d=p.d,speed = 0,rx=0,ry=0}			
			projectiles[#projectiles] = moves.moveProj(#projectiles,1)
		end
		if p.name == "spike" and p.despawn < 1.44 and p.spawned==false then
			p.spawned=true
			projectiles[#projectiles+1] = {meltable=true,spawned=false,rotate=false,despawn=1.5,name=p.name,damage=8,image=earthSpikeImg,x=p.x,y=p.y,d=p.d,speed = 0,rx=0,ry=0}
			projectiles[#projectiles] = moves.moveProj(#projectiles,1)
		end
		if p.name == "earth wave" and p.despawn < 0.02 and p.moved == false then
			p.moved = true
			local rider = nil
			for i=1,2 do
				if p.x == players[i].x and p.y == players[i].y then
					rider = i
				end
			end
			projectiles[#projectiles+1] = {rider=rider,meltable=true,removeOnHit=false,moved=false,despawn=0.11,name=p.name,damage=0,image=earthOrbImg,x=p.x,y=p.y,d=p.d,speed = 0,rx=0,ry=0}
			projectiles[#projectiles] = moves.moveProj(#projectiles,1)
			if rider then players.move(projectiles[#projectiles].rider,projectiles[#projectiles].d,true) end
		end
		if p.name == "lava" then
			if p.hasSpread == false and p.despawn < 6 then
				p.hasSpread = true
				for x=-1,1 do
					for y=-1,1 do
						shouldPlace=true
						for j=1,#projectiles do
							local op=projectiles[j]
							if op.x==p.x+x and op.y==p.y+y and op.name=="lava" then shouldPlace = false end
						end
						if shouldPlace then projectiles[#projectiles+1] = {meltable=true,removesOnHit=false,hasSpread=true,rotate=false,despawn=5,name="lava",damage=20,image=lavaImg,x=p.rx+x,y=p.ry+y,d=p.d,speed = 0,rx=0,ry=0} end
					end
				end
			end
		end
		if p.name == "redirect" then
			for i=1,#projectiles do
				op = projectiles[i]
				if not(op==p) and op.rx==p.rx and op.ry==p.ry then
					op.d=p.d
					if op.caster~=nil then op.caster=p.caster end
				end
			end
		end
		if p.name == "flood" then
			if p.layer > 3 and p.despawn<1.3^p.layer-0.1 then
				if p.willSpawn then
					p.willSpawn=false
					p.image=floodImg
					for x=1,16 do
						local willSpawn = false
						if x==1 then willSpawn = true end
						projectiles[#projectiles+1]={removesOnHit=false,freezes=true,rotate=false,willSpawn=willSpawn,layer=p.layer-1,despawn=1.3^p.layer-1,name=p.name,damage=50,image=floodTopImg,x=x,y=p.layer-1,d=p.d,speed = 0,rx=0,ry=0}
					end
				else
					p.image=floodImg
				end
			end
		end
		if p.name == "lightning" then
			if p.branched==false and p.despawn<0.47 then
				local multi = math.random(1,7)
				if not (multi==2) then multi=1 end
				if p.turns>2 then multi=1 end
				if multi==2 then p.turns=p.turns+1 end
				p.branched = true
				local x=p.rx
				local y=p.ry
				if p.d==0 then y=y-1 end
				if p.d==1 then x=x+1 end
				if p.d==2 then y=y+1 end
				if p.d==3 then x=x-1 end
				for i=1,multi do
					local d=p.d-1+i
					if d==4 then d=0 end
					projectiles[#projectiles+1] = {turns=p.turns,branched = false,despawn=0.5,name=p.name,damage=50,image=lightningImg,x=x,y=y,d=d,speed = 0,rx=0,ry=0}
				end
			end
		end
		if p.name == "combustion" then
			if p.expanded==false and p.despawn<0.47 then
				p.expanded=true
				local explode = false
				for i=1,2 do if p.rx==players[i].x and p.ry==players[i].y then explode = true end end
				for j=1,#projectiles do if p.rx==projectiles[j].rx and p.ry==projectiles[j].ry and projectiles[j].name ~= "combustion" and projectiles[j].name ~= "combustionExplosion" then
					explode = true
					projectilesToRemove[#projectilesToRemove+1]=j
				end end
				if p.rx==1 and p.d==3 then explode = true end
				if p.rx==16 and p.d==1 then explode = true end
				if p.ry==1 and p.d==0 then explode = true end
				if p.ry==8 and p.d==2 then explode = true end
				if explode == true then
					if p.name == "combustion" then
						projectiles[#projectiles+1] = {expanded=false,rotate=false,despawn=1,name="combustionExplosion",damage=20,image=explosion,x=p.x,y=p.y,d=0,speed = 0,rx=0,ry=0}
					end
					projectilesToRemove[#projectilesToRemove+1]=i
				else
					local x=p.rx
					local y=p.ry
					if p.d==0 then y=y-1 end
					if p.d==1 then x=x+1 end
					if p.d==2 then y=y+1 end
					if p.d==3 then x=x-1 end
					projectiles[#projectiles+1] = {expanded=false,despawn=0.5,name=p.name,damage=0,image=combustionBlastImg,x=x,y=y,d=p.d,speed = 0,rx=0,ry=0}
				end
			end
		end
		if p.name == "combustionExplosion" and p.expanded==false then
			p.expanded = true
			for x=-2,2 do
				for y=-2,2 do
					if not((x==2 and y==2) or (x==2 and y==-2) or (x==-2 and y==2) or (x==-2 and y==-2)) then
						projectiles[#projectiles+1] = {expanded=true,despawn=1,name="combustionExplosion",damage=20,image=explosionImg,x=p.x+x,y=p.y+y,d=p.d,speed = 0,rx=0,ry=0}
					end
				end
			end
		end
		if p.name == "tornadoCentre" then
			local enemy = 1
			if p.caster == 1 then enemy = 2 end
			pl = players[enemy]
			if pl.x == p.rx and pl.y == p.ry then
				pl.slideTimer = 0
			end
		end
		if p.name == "tornado" then
			local enemy = 1
			if p.caster == 1 then enemy = 2 end
			pl = players[enemy]
			local cen=nil
			for i=1,#projectiles do --finding the corresponding center
				if projectiles[i].id==p.centreID then 
					cen=projectiles[i]
				end
			end
			if cen~=nil and pl.x == p.rx and pl.y == p.ry and pl.slideTimer == 0 and pl.flying == false then
				pl.slideTimer = 0.22
				if pl.x > cen.rx then pl.x = pl.x - 1 end
				if pl.y > cen.ry then pl.y = pl.y - 1 end
				if pl.x < cen.rx then pl.x = pl.x + 1 end
				if pl.y < cen.ry then pl.y = pl.y + 1 end 
			end
		end
		if p.name == "sword flurry" or p.name == "swinging sword" then
			p.d = players[p.caster].d
			local swingSword = true
			for i=1,#projectilesToRemove do if pn == projectilesToRemove[i] then swingSword = false end end
			if p.name == "swinging sword" and swingSword == true then
				p.vd=p.vd+10*dt
				players[p.caster].vd=p.vd
			end
		end
		if p.name == "ice shard" then
			if p.spawnedThisTick~=true then
				local collidingShards = 0
				for i=1,#projectiles do
					if projectiles[i].rx == p.rx and projectiles[i].ry == p.ry and projectiles[i].blocker==nil and projectiles[i].name ~= "ice shard" and projectiles[i].damage ~= 0 then
						if p.splits <= 5 then
							for j=-1,1,2 do
								if p.d == 0 or p.d == 2 then projectiles[#projectiles+1] = {spawnedThisTick=true,splits=p.splits+1,name=p.name,damage=logic.round(10/(p.splits+2)),image=iceShardImg,x=p.x+j,y=p.y,d=p.d,speed = 5,rx=0,ry=0}
								else projectiles[#projectiles+1] = {spawnedThisTick=true,splits=p.splits+1,name=p.name,damage=logic.round(10/(p.splits+2)),image=iceShardImg,x=p.x,y=p.y+j,d=p.d,speed = 5,rx=0,ry=0} end
							end
							projectilesToRemove[#projectilesToRemove+1] = pn
						end
					end
					if projectiles[i].rx == p.rx and projectiles[i].ry == p.ry and projectiles[i].name == "ice shard" then collidingShards = collidingShards + 1 end
				end
				if collidingShards >= 3 then projectilesToRemove[#projectilesToRemove+1] = pn end
			else
				p.spawnedThisTick=false
			end
		end
	end

	function moves.despawn(dt)
		for i=1,#projectiles do
			p=projectiles[i]
			if p.despawn then
				p.despawn = p.despawn - dt
				if p.despawn < 0 then
					projectilesToRemove[#projectilesToRemove+1]=i
					if p.name == "swinging sword" then players[p.caster].vd = false	end
				end
			end
		end
	end
	
	function moves.removeReduntantProjectiles()
		for i=1,#projectiles do
			p=projectiles[i]
			if not(p.name == "sword flurry") then
				if p.rx<1 or p.rx>16 or p.ry<1 or p.ry > 8 then
					projectilesToRemove[#projectilesToRemove+1]=i
				end
			end

			for j=1,#projectiles do
				if not(i==j) then --a blocker cannot block itself
					op=projectiles[j]
					if op.blocker and op.rx==p.rx and op.ry==p.ry and p.blocker==nil and not(logic.inList(projectilesToRemove,i)) and not(logic.inList(projectilesToRemove,j)) then --blockers cannot be blocked and projectiles about to be removed cannot be blocked
						if op.blocker=="shield" then
							if p.d == op.d+2 or p.d == op.d-2 then
								projectilesToRemove[#projectilesToRemove+1]=i
								projectilesToRemove[#projectilesToRemove+1]=j
							else op.blocker = "fragileField" end
						end
						if (not(op.blocker=="diagonal" or op.blocker=="fragileField")) then projectilesToRemove[#projectilesToRemove+1]=i end
						if (op.blocker=="fragile" or op.blocker=="fragileField" or op.blocker=="fragileForceField") then projectilesToRemove[#projectilesToRemove+1]=j end
						if op.blocker=="diagonal" and (p.deflectable == nil or p.deflectable == true) then
							if p.caster	~= nil and op.caster~=nil then p.caster = op.caster end
							p.d=op.d+5
							p.despawn=0.7
							p.rotateAmount=0.785398*(2*p.d-9)
							if p.d==8 then p.d=4 end
						end

					end
				end
			end
		end
	end

	function moves.moveProjectiles(dt)
		--speed is in tiles/sec
		for i=1,#projectiles do
			p=projectiles[i]
			p=moves.moveProj(i,p.speed*dt)
		end
	end

	function moves.roundPositions()
		for i=1,#projectiles do
			p=projectiles[i]
			p.rx = logic.round(p.x,0)
			p.ry = logic.round(p.y,0)
		end
	end

function moves.draw()

	for i=1,2 do --draw player shadows
		p = players[i]
		if p.flying~=false then
			rgb(0,0,0,100)
			love.graphics.circle("fill",p.x*120-60,p.y*120+60,50,50)
		end
	end

	for i=1,#projectiles do
		p=projectiles[i]

		if (not p.despawn) or p.despawn > 0.5 then 
			love.graphics.setColor(255,255,255)
		else 
			love.graphics.setColor(255,255,255,p.despawn/0.5*255) 
		end

		local splits = 1
		if p.splits ~= nil and p.splits ~= 0 then splits = (p.splits+1)/1.5 end

		if not(p.image == nil)then

			if p.percent then
				local r = math.pi*p.d/2
				if not(p.vd==nil) then r=math.pi*p.vd/2 end
				animate.draw(p.image,p.rx*120-60,p.ry*120+60,p.percent,r,p.spriteLength,p.continuous,p.horisontal)
			else
				if p.rotate==false then
						love.graphics.draw(p.image,p.rx*120-60,p.ry*120+60,0,1/splits,1/splits,60,60)
				else
				if p.rotateAmount == nil then
					if p.vd == nil then --vd=visual direction
						love.graphics.draw(p.image,p.rx*120-60,p.ry*120+60,math.pi*p.d/2,1/splits,1/splits,60,60)
					else
						love.graphics.draw(p.image,p.rx*120-60,p.ry*120+60,math.pi*p.vd/2,1/splits,1/splits,60,60)
					end
				else
					love.graphics.draw(p.image,p.rx*120-60,p.ry*120+60,p.rotateAmount,1/splits,1/splits,60,60)
				end
			end

			if (not p.despawn) or p.despawn > 0.5 then 
				love.graphics.setColor(255,255,255)
			else 
				love.graphics.setColor(255,255,255,p.despawn/0.5*255) 
			end

			if not(p.image == nil)then
				if p.percent then
					local r = math.pi*p.d/2
					if not(p.vd==nil) then r=math.pi*p.vd/2 end
						animate.draw(p.image,p.rx*120-60,p.ry*120+60,p.percent,r,p.spriteLength,p.continuous,p.horisontal)
					else
						if p.rotate==false then
							love.graphics.draw(p.image,p.rx*120-60,p.ry*120+60,0,1/splits,1/splits,60,60)
						else
							if p.rotateAmount == nil then
								if p.vd == nil then --vd=visual direction
									love.graphics.draw(p.image,p.rx*120-60,p.ry*120+60,math.pi*p.d/2,1/splits,1/splits,60,60)
								else
									love.graphics.draw(p.image,p.rx*120-60,p.ry*120+60,math.pi*p.vd/2,1/splits,1/splits,60,60)
								end
							else
								love.graphics.draw(p.image,p.rx*120-60,p.ry*120+60,p.rotateAmount,1/splits,1/splits,60,60)
							end
						end
					end
					love.graphics.setColor(255,255,255)
				end
			end
		end
	end
end

function moves.cast(typeNum,num,pn)
	if players[pn].flying==false and (players.world == "physical" or moves[typeNum][num].type == "normal" or moves[typeNum][num].type == "sokka") then
		p=players[pn]
		if p.chi >= moves[typeNum][num].cost and players.canCast(p) then
			local refund=false
			p.chi=p.chi-moves[typeNum][num].cost
			local name = moves[typeNum][num].name

			if name == "blink" then
				p.blinking = 3
			end

			if name == "seismic sense" then
				local op=players[1]
				if pn==1 then op=players[2] end
				local newD = nil
				local xDiff=math.abs(p.x-op.x)
				local yDiff=math.abs(p.y-op.y)
				if xDiff>=yDiff then
					if p.x>op.x then newD=3 else newD=1 end
				else
					if p.y>op.y then newD=0 else newD=2 end
				end
				if p.d~=newD then p.d=newD else refund=true end
			end

			if name == "gale" then
				refund=true
				for i=1,#projectiles do
					if projectiles[i].speed>0 and (projectiles[i].d~=p.d or projectiles[i].speed<10) then
						refund=false
						projectiles[i].d=p.d
						if projectiles[i].speed<10 then projectiles[i].speed=10 end
					end
				end
			end

			if name == "flame trail" then
				players[pn].flameTrail=10
			end

			if name == "terraform" then
				local x=p.x
				local y=p.y
				if p.d==0 then y=y-1
				elseif p.d==1 then x=x+1
				elseif p.d==2 then y=y+1
				else x=x-1 end
				if (not players.playerOnTile(x,y)) and x>0 and x<17 and y>0 and y<9 then 
					map[x][y]=map[x][y]+1 
					if map[x][y]==2 then map[x][y]=0 end
				else refund=true end
			end

			if name == "fly" then
				players[pn].flying=3
			end

			if name == "fire jet" then
				players[pn].fireJet=true
				players[pn].flying=1.4
			end
			
			if name == "shield" then
				projectiles[#projectiles+1] = {caster=pn,movesWithCaster=true,blocker="shield",despawn=1,name=name,damage=0,image=shieldImg,x=p.x,y=p.y,d=p.d,speed = 0,rx=0,ry=0}
			end
			if name == "freeze" then
				for i=1,#projectiles do
					p=projectiles[i]
					if p.freezes ~= nil then
						for j=1,#players[pn].lineOfSight do
							if players[pn].lineOfSight[j].x == p.rx and players[pn].lineOfSight[j].y == p.ry then
								projectilesToRemove[#projectilesToRemove+1]=i
								projectiles[#projectiles+1] = {rotate=false,blocker="fragileForceField",walkOver=true,despawn=4,name="ice",damage=0,image=iceImg,x=p.rx,y=p.ry,d=p.d,speed = 0,rx=0,ry=0}
								break
							end
						end
					end
				end
			end
			if name == "sprout" then
				for i=0,3 do
					projectiles[#projectiles+1] = {despawn=10,blocker="fragileField",caster=pn,rotate=false,name=name,damage=10,image=thornsImg,x=p.x,y=p.y,d=i,speed = 0,rx=0,ry=0}
					projectiles[#projectiles] = moves.moveProj(#projectiles,1)
				end
			end
			if name == "heal" then
				projectiles[#projectiles+1] = {freezes=true,name=name,damage=-10,image=healOrbImg,x=p.x,y=p.y,d=p.d,speed = 0,rx=0,ry=0}
				projectiles[#projectiles] = moves.moveProj(#projectiles,3)
			end
			if name == "shift" then
				players.shiftTimer = 3
			end
			if name == "arrow" then
				projectiles[#projectiles+1] = {name=name,damage=10,image=arrowImg,x=p.x,y=p.y,d=p.d,speed = 4,rx=0,ry=0}
				projectiles[#projectiles] = moves.moveProj(#projectiles,1)
			end
			if name=="redirect" then
				projectiles[#projectiles+1] = {caster=pn,despawn=2,name=name,damage=0,image=redirectIcon,x=p.x,y=p.y,d=p.d,speed = 0,rx=0,ry=0}
				projectiles[#projectiles] = moves.moveProj(#projectiles,1)
			end
			if name == "spurt" then
				for i=1,3 do
					if p.d==0 or p.d==2 then projectiles[#projectiles+1] = {freezes=true,name=name,damage=7,image=waterOrbImg,x=p.x-2+i,y=p.y,d=p.d,speed = 2,rx=0,ry=0}
					else projectiles[#projectiles+1] = {freezes=true,name=name,damage=7,image=waterOrbImg,x=p.x,y=p.y-2+i,d=p.d,speed = 2,rx=0,ry=0} end
					projectiles[#projectiles] = moves.moveProj(#projectiles,1)
				end
			end
			if name == "spout" then
				for i=1,3 do
					projectiles[#projectiles+1] = {freezes=true,name=name,damage=7,image=waterOrbImg,x=p.x,y=p.y,d=p.d,speed = 4,rx=0,ry=0}
					projectiles[#projectiles] = moves.moveProj(#projectiles,i)
				end
			end
			if name == "ice shard" then
				projectiles[#projectiles+1] = {splits=0,name=name,damage=10,image=iceShardImg,x=p.x,y=p.y,d=p.d,speed = 5,rx=0,ry=0}
				projectiles[#projectiles] = moves.moveProj(#projectiles,1)
			end
			if name == "gust" then
				projectiles[#projectiles+1] = {percent=0,spriteLength=6,aSpeed=2,name=name,damage=15,image=airOrbImg,x=p.x,y=p.y,d=p.d,speed = 8,rx=0,ry=0}
				projectiles[#projectiles] = moves.moveProj(#projectiles,1)
			end
			if name == "air ball" then
				projectiles[#projectiles+1] = {doesBounce=true,despawn=10,percent=0,spriteLength=6,aSpeed=1.5,name=name,damage=15,image=bouncyAirOrbImg,x=p.x,y=p.y,d=p.d,speed = 8,rx=0,ry=0}
				projectiles[#projectiles] = moves.moveProj(#projectiles,1)
			end
			if name == "air flurry" then
				for i=1,4 do
					if p.d == 0 or p.d==2 then projectiles[#projectiles+1] = {percent=0,spriteLength=6,aSpeed=2,name=name,damage=8,image=airOrbImg,x=p.x-3+logic.round(i*1.2),y=p.y,d=p.d,speed = 7,rx=0,ry=0}
					else projectiles[#projectiles+1] = {percent=0,spriteLength=6,aSpeed=2,name=name,damage=8,image=airOrbImg,x=p.x,y=p.y-3+logic.round(i*1.2),d=p.d,speed = 7,rx=0,ry=0} end
					projectiles[#projectiles] = moves.moveProj(#projectiles,1)
				end
			end
			if name == "hurricane" then
				for j=1,3 do
					for i=1,3 do
						if p.d==0 or p.d==2 then projectiles[#projectiles+1] = {percent=0,spriteLength=6,aSpeed=j*i,name=name,damage=10,image=airOrbImg,x=p.x-2+i,y=p.y,d=p.d,speed=j*i,rx=0,ry=0}
							else projectiles[#projectiles+1] = {percent=0,spriteLength=6,aSpeed=j*i,name=name,damage=10,image=airOrbImg,x=p.x,y=p.y-2+i,d=p.d,speed =j*i,rx=0,ry=0} end
						projectiles[#projectiles] = moves.moveProj(#projectiles,j)
					end
				end
			end
			if name == "tornado" then
				local centreIndex = #projectiles+1
				local centreID = math.random(1,10000)
				projectiles[centreIndex] = {vd=p.d,id=centreID,caster=pn,name="tornadoCentre",despawn=3,damage=0,image=tornadoCentreImg,x=p.x,y=p.y,d=p.d,speed=0,rx=0,ry=0}
				projectiles[centreIndex] = moves.moveProj(#projectiles,5)
				local cen = projectiles[centreIndex]
				local createTornado = true
				if cen.x < 1 or cen.x > 16 or cen.y < 1 or cen.y > 8 then createTornado = false	end
				--(OPTIONAL: 2 CENTERS CANNOT BE WITHIN EACH-OTHER)--for i=1,#projectiles do if projectiles[i].name == "tornadoCentre" and projectiles[i].x==cen.x and projectiles[i].y==cen.y and projectiles[i].id ~= cen.id then createTornado = false end end
				for x=1,16 do for y=1,8 do if map[x][y]==0 and cen.x == x and cen.y == y then createTornado = false end end end
				if createTornado == true then
					for x=-2,2 do
						for y=-2,2 do
							if not(x==0 and y==0) then
								projectiles[#projectiles+1] = {vd=p.d,caster=pn,centreID=centreID,name=name,walkOver=true,despawn=3,damage=0,image=tornadoImg,x=p.x+x,y=p.y+y,d=p.d,speed=0,rx=0,ry=0}
								projectiles[#projectiles] = moves.moveProj(#projectiles,5)
							end
						end
					end
				else
					projectilesToRemove[#projectilesToRemove+1]=centreIndex
					refund=true
				end
			end
			if name=="crystalise" then
				for i=1,8 do
					local d=i-1
					projectiles[#projectiles+1] = {spawned=false,rotate=false,name="ice spike",despawn=2,damage=14,image=iceSpikeImg,x=p.x,y=p.y,d=d,speed = 0,rx=0,ry=0}
					projectiles[#projectiles] = moves.moveProj(#projectiles,1)
				end
			end
			if name=="shockwave" then
				for i=1,8 do
					local d=i-1
					projectiles[#projectiles+1] = {meltable=true,name=name,damage=20,image=earthOrbImg,x=p.x,y=p.y,d=d,speed = 12,rx=0,ry=0}
					projectiles[#projectiles] = moves.moveProj(#projectiles,1)
				end
			end
			if name == "aurora borealis" then
				projectiles[#projectiles+1] = {spriteLength=6,continuous=true,blocker="forceField",despawn=5,percent=0,aSpeed=1,name=name,damage=0,image=auroraImg,x=p.x,y=p.y,d=p.d,speed = 0,rx=0,ry=0}
			end
			if name == "blow" then
				for i=1,4 do
					projectiles[#projectiles+1] = {horisontal = true,continuous=true,despawn=5,percent=0,aSpeed=1,name=name,damage=0,image=windImg,x=p.x,y=p.y,d=p.d,speed = 0,rx=0,ry=0}
					projectiles[#projectiles] = moves.moveProj(#projectiles,i)
				end
			end
			if name == "sear" then
				for i=4,7 do
					projectiles[#projectiles+1] = {aRepeats=false,vd=p.d,redirectable=true,percent=0,spriteLength=4,aSpeed=1,name=name,damage=20,image=fireOrbImg,x=p.x,y=p.y,d=i,speed = 3,rx=0,ry=0}
					projectiles[#projectiles] = moves.moveProj(#projectiles,1)
				end
			end
			if name == "blast" then
				for i=0,1 do
					local d = p.d+1+(i*2)
					if d>3 then d=d-4 end
					projectiles[#projectiles+1] = {aRepeats=false,redirectable=true,percent=0,spriteLength=4,aSpeed=1,name=name,damage=10,image=fireOrbImg,x=p.x,y=p.y,d=d,speed = 4,rx=0,ry=0}
					projectiles[#projectiles] = moves.moveProj(#projectiles,1)
				end
			end
			if name == "fire breath" then
				for i=1,3 do
					projectiles[#projectiles+1] = {deflectable=false,posNum=i,caster=pn,damagesCaster=false,removesOnHit=false,despawn=3,name=name,damage=10,x=p.x,y=p.y,d=p.d,speed = 0,rx=0,ry=0}
					projectiles[#projectiles] = moves.moveProj(#projectiles,i)
				end
			end
			if name == "boulder" then
				projectiles[#projectiles+1] = {meltable=true,name=name,damage=20,image=earthOrbImg,x=p.x,y=p.y,d=p.d,speed = 6,rx=0,ry=0}
				projectiles[#projectiles] = moves.moveProj(#projectiles,1)
			end
			if name == "bullet" then
				projectiles[#projectiles+1] = {meltable=true,name=name,damage=20,image=bulletImg,x=p.x,y=p.y,d=p.d,speed = 15,rx=0,ry=0}
				projectiles[#projectiles] = moves.moveProj(#projectiles,1)
			end
			if name == "machine gun" then
				p.machineGunning=5
			end
			if name == "flame wall" then
				for i=1,3 do
					if p.d==0 or p.d==2 then projectiles[#projectiles+1] = {caster=pn,removesOnHitCaster=false,damagesCaster=false,percent=0,spriteLength=4,aSpeed=4,name=name,despawn=1,blocker="fragileForceField",damage=4,image=stillFlameImg,x=p.x-2+i,y=p.y,vd=0,d=p.d,speed = 0,rx=0,ry=0}
					else projectiles[#projectiles+1] = {caster=pn,removesOnHitCaster=false,damagesCaster=false,percent=0,spriteLength=4,aSpeed=4,name=name,despawn=1,blocker="fragileForceField",damage=4,image=stillFlameImg,x=p.x,y=p.y-2+i,vd=0,d=p.d,speed = 0,rx=0,ry=0} end
					projectiles[#projectiles] = moves.moveProj(#projectiles,1)
				end
			end
			if name == "lightning" then
				projectiles[#projectiles+1] = {deflectable=false,turns=0,branched=false,despawn=0.5,name=name,damage=50,image=lightningImg,x=p.x,y=p.y,d=p.d,speed = 0,rx=0,ry=0}
				projectiles[#projectiles] = moves.moveProj(#projectiles,1)	
			end
			if name == "combustion" then
				projectiles[#projectiles+1] = {expanded=false,despawn=0.5,name=name,damage=0,image=combustionBlastImg,x=p.x,y=p.y,d=p.d,speed = 0,rx=0,ry=0}
				projectiles[#projectiles] = moves.moveProj(#projectiles,1)
			end
			if name == "flood" then
				for x=1,16 do
					willSpawn=false
					if x==1 then willSpawn=true end
					projectiles[#projectiles+1] = {removesOnHit=false,freezes=true,rotate=false,willSpawn=willSpawn,layer=8,despawn=1.3^9,name=name,damage=50,image=floodTopImg,x=x,y=8,d=0,speed = 0,rx=0,ry=0}
				end
			end
			if name == "spike" then
				projectiles[#projectiles+1] = {meltable=true,spawned=false,rotate=false,despawn=1.5,name=name,damage=4,image=earthSpikeImg,x=p.x,y=p.y,d=p.d,speed = 0,rx=0,ry=0}
				projectiles[#projectiles] = moves.moveProj(#projectiles,1)
			end
			if name == "earth wave" then
				projectiles[#projectiles+1] = {rider=pn,meltable=true,moved=false,removeOnHit=false,despawn=0.11,name=name,damage=0,image=earthOrbImg,x=p.x,y=p.y,d=p.d,speed = 0,rx=0,ry=0}
				projectiles[#projectiles] = moves.moveProj(#projectiles,1)
				players.move(pn,p.d,true)
			end
			if name == "melt" then
				refund = true
				for i=1,#projectiles do
					local p=projectiles[i]
					if p.meltable ~= nil then
						refund = false
						projectilesToRemove[#projectilesToRemove+1]=i
						projectiles[#projectiles+1] = {removesOnHit=false,hasSpread=false,rotate=false,despawn=8,name="lava",damage=20,image=lavaImg,x=p.rx,y=p.ry,d=p.d,speed = 0,rx=0,ry=0}
					end
				end
			end
			if name == "boomerang" then
				projectiles[#projectiles+1] = {caster=pn,removesOnHitCaster=true,damagesCaster=false,bounces=0,name=name,damage=10,image=boomerangImg,x=p.x,y=p.y,d=p.d,speed = 10,rx=0,ry=0}
				projectiles[#projectiles] = moves.moveProj(#projectiles,1)
			end
			if name == "sword block" then
				projectiles[#projectiles+1] = {caster=pn,deflector=true,removesOnHit=false,blocker="diagonal",despawn=1,name=name,damage=0,image=swordImg,x=p.x,y=p.y,d=p.d,speed = 0,rx=0,ry=0}
				p.deflecting = true
			end
			if name == "sword flurry" then
				p.vd = p.d
				projectiles[#projectiles+1] = {caster=pn,movesWithCaster=true,removesOnHit=false,despawn=3,name="swinging sword",damage=0,image=swordImg,x=p.x,y=p.y,d=p.d,vd=p.d,speed = 0,rx=0,ry=0}
				for i=1,8 do
					projectiles[#projectiles+1] = {caster=pn,movesWithCaster=true,damagesCaster=false,removesOnHit=false,despawn=3,name=name,damage=15,x=p.x,y=p.y,d=i-1,speed = 0,rx=0,ry=0}
					projectiles[#projectiles] = moves.moveProj(#projectiles,1)
				end
			end

			if refund==true then 
				p.chi=p.chi+moves[typeNum][num].cost 
			else
				moves.playMoveSound(moves[typeNum][num].type)
			end

		end
	end
end

function moves.moveProj(n,num)

	local p=projectiles[n]

	if p.d==0 then p.y=p.y-num end
	if p.d==1 then p.x=p.x+num end
	if p.d==2 then p.y=p.y+num end
	if p.d==3 then p.x=p.x-num end
	if p.d==4 then 
		p.x=p.x-num 
		p.y=p.y-num 
	end
	if p.d==5 then 
		p.x=p.x+num 
		p.y=p.y-num 
	end
	if p.d==6 then 
		p.x=p.x+num 
		p.y=p.y+num 
	end
	if p.d==7 then 
		p.x=p.x-num 
		p.y=p.y+num 
	end

	if p.doesBounce then
		if p.x>=16.5 and p.d==1 then p.d,p.x=3,16 end
		if p.x<=0.5 and p.d==3 then p.d,p.x=1,1 end
		if p.y>=8.5 and p.d==2 then p.d,p.y=0,8 end
		if p.y<=0.5 and p.d==0 then p.d,p.y=2,1 end
	end

	return p
end

function moves.playMoveSound(type)
	if type=="water" or type=="air" or type=="earth" or type=="fire" then
		sound.play(type.."Effect")
	end
end

function moves.getProjectiles()
	return projectiles
end