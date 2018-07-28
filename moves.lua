require "logic"
require "players"
require "animate"
require "sound"

moves = { --first moves must all be normal

--Utility
{{name="charge",type="normal",cost=2,desc="You charge forwards with such force that you can almost phase-through certain projectiles!"},
{name="aurora borealis",type="water",cost=8,desc="Using spirit-bending, you summon the spirits of the aurora borealis to defend you."},
{name="blow",type="air",cost=8,desc="A funnel of air to propel you forwards or push your opponent back!"},
{name="redirect",type="fire",cost=8,desc="\"If you let the energy in your own body flow, the lightning will follow it...\"\n\n\"You must not let the lightning pass through your heart, or the damage could be deadly!\""},
{name="sword block",type="sokka",cost=5,desc="You deflect an enemy's attack, sending it flying away to the side."},
{name="wall",type="earth",cost=5,desc="The ground rises up to shield you from harm!"}},

--Attack
{{name="arrow",type="normal",cost=6,desc="A well-placed arrow can be as effective as any pillar of fire or collumn of rock!"},
{name="spurt",type="water",cost=16,desc="A writhing spray of water, ready to force itself down your enemy's throat and drown their very lungs!"},
{name="gust",type="air",cost=8,desc="A ball of whirling air."},
{name="blast",type="fire",cost=10,desc="Two glowing embers shoot sideways from each hand."},
{name="boomerang",type="sokka",cost=6,desc="The boomerang whirls around the edge of the arena before returning to your hand."},
{name="boulder",type="earth",cost=8,desc="A giant rolling boulder - it's a little slow but deals a lot of damage."}},

--Power
{{name="block",type="normal",cost=40,desc="To-write"},
{name="lightning",type="fire",cost=50,desc="\"The energy is both yin and yang, you can separate these energies, creating an imbalance. The energy wants to restore balance and in a moment the positive and negative energy come crashing back together. You provide release and guidance, creating lightning.\""},
{name="gale",type="air",cost=30,desc="A devestating, unpredictable flurry of wind!"},
{name="shockwave",type="earth",cost=30,desc="You send seismic waves rippling through the earth, letting it rise up around you!"},
{name="flood",type="water",cost=80,desc="The waters rise up to drown your enemies!"}}
}

projectiles = {}

function moves.load()
	-- Nothing here, so sad :(
end

function moves.update(dt)
	moves.moveProjectiles(dt)
	moves.roundPositions()
	moves.removeReduntantProjectiles()
	moves.despawn(dt)
	for i=1,#projectiles do moves.updateProjectile(projectiles[i]) end
	for i=1,2 do 
		if not(players[i].beenBlown==false) then
			if players[i].beenBlown-dt > 0 then players[i].beenBlown = players[i].beenBlown-dt else players[i].beenBlown = false end
		end
	end
end

	function moves.updateProjectile(p)
		if p.name == "blow" then
			for i=1,2 do
				pl=players[i]
				if pl.x==p.rx and pl.y==p.ry and not(pl.beenBlown) then
					players.move(i,p.d,true)
					pl.beenBlown=0.1
				end
			end
		end
		if p.name == "redirect" then
			for i=1,#projectiles do
				op = projectiles[i]
				--if op.redirectable then
					if not(op==p) and op.rx==p.rx and op.ry==p.ry then
						op.d=p.d
					end
				--end
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
						projectiles[#projectiles+1]={willSpawn=willSpawn,layer=p.layer-1,despawn=1.3^p.layer-1,name=p.name,damage=50,image=floodTopImg,x=x,y=p.layer-1,d=p.d,speed = 0,rx=0,ry=0}
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
	end

	function moves.despawn(dt)
		for i=1,#projectiles do
			p=projectiles[i]
			if p.despawn then
				p.despawn = p.despawn - dt
				if p.despawn < 0 then projectilesToRemove[#projectilesToRemove+1]=i end
			end
		end
	end
	
	function moves.removeReduntantProjectiles()
		for i=1,#projectiles do
			p=projectiles[i]
			if p.rx<1 or p.rx>16 or p.ry<1 or p.ry > 8 then
				projectilesToRemove[#projectilesToRemove+1]=i
			end

			for j=1,#projectiles do
				if not(i==j) then
					op=projectiles[j]
					if op.blocker and op.rx==p.rx and op.ry==p.ry then
						projectilesToRemove[#projectilesToRemove+1]=i
						if op.blocker=="fragile" then projectilesToRemove[#projectilesToRemove+1]=j end
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
	for i=1,#projectiles do
		p=projectiles[i]
		if (not p.despawn) or p.despawn > 0.5 then love.graphics.setColor(255,255,255)
		else love.graphics.setColor(255,255,255,p.despawn/0.5*255) end

		if p.percent then
			animate.draw(p.image,p.rx*120-60,p.ry*120+60,p.percent,math.pi*p.d/2,p.spriteLength,p.continuous,p.horisontal)
		else
			love.graphics.draw(p.image,p.rx*120-60,p.ry*120+60,math.pi*p.d/2,1,1,60,60)
		end

		love.graphics.setColor(255,255,255)
	end
end

function moves.cast(typeNum,num,pn)
	p=players[pn]
	if p.chi >= moves[typeNum][num].cost and players.canCast(p) then
		p.chi=p.chi-moves[typeNum][num].cost
		local name = moves[typeNum][num].name
		
		if name == "arrow" then
			projectiles[#projectiles+1] = {name=name,damage=10,image=arrowImg,x=p.x,y=p.y,d=p.d,speed = 4,rx=0,ry=0}
			projectiles[#projectiles] = moves.moveProj(#projectiles,1)
		end
		if name=="redirect" then
			projectiles[#projectiles+1] = {despawn=2,name=name,damage=0,image=redirectIcon,x=p.x,y=p.y,d=p.d,speed = 0,rx=0,ry=0}
			projectiles[#projectiles] = moves.moveProj(#projectiles,1)
		end
		if name == "spurt" then
			for i=1,3 do
				if p.d==0 or p.d==2 then projectiles[#projectiles+1] = {name=name,damage=10,image=waterOrbImg,x=p.x-2+i,y=p.y,d=p.d,speed = 2,rx=0,ry=0}
					else projectiles[#projectiles+1] = {name=name,damage=10,image=waterOrbImg,x=p.x,y=p.y-2+i,d=p.d,speed = 2,rx=0,ry=0} end
				projectiles[#projectiles] = moves.moveProj(#projectiles,1)
			end
		end
		if name == "charge" then for i=1,3 do players.move(pn,p.d,true) end end
		if name == "gust" then
			projectiles[#projectiles+1] = {percent=0,spriteLength=6,aSpeed=2,name=name,damage=10,image=airOrbImg,x=p.x,y=p.y,d=p.d,speed = 4,rx=0,ry=0}
			projectiles[#projectiles] = moves.moveProj(#projectiles,1)
		end
		if name == "gale" then
			for j=1,3 do
				for i=1,3 do
					if p.d==0 or p.d==2 then projectiles[#projectiles+1] = {percent=0,spriteLength=6,aSpeed=j*i,name=name,damage=10,image=airOrbImg,x=p.x-2+i,y=p.y,d=p.d,speed =j*i,rx=0,ry=0}
						else projectiles[#projectiles+1] = {percent=0,spriteLength=6,aSpeed=j*i,name=name,damage=10,image=airOrbImg,x=p.x,y=p.y-2+i,d=p.d,speed =j*i,rx=0,ry=0} end
					projectiles[#projectiles] = moves.moveProj(#projectiles,j)
				end
			end
		end
		if name=="shockwave" then
			for i=1,8 do
				local d=i-1
				projectiles[#projectiles+1] = {name=name,damage=15,image=earthOrbImg,x=p.x,y=p.y,d=d,speed = 4,rx=0,ry=0}
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
		if name == "blast" then
			for i=0,1 do
				local d = p.d+1+(i*2)
				if d>3 then d=d-4 end
				projectiles[#projectiles+1] = {redirectable=true,percent=0,spriteLength=6,aSpeed=0.7,name=name,damage=10,image=fireOrbImg,x=p.x,y=p.y,d=d,speed = 4,rx=0,ry=0}
				projectiles[#projectiles] = moves.moveProj(#projectiles,1)
			end
		end
		if name == "boulder" then
			projectiles[#projectiles+1] = {name=name,damage=15,image=earthOrbImg,x=p.x,y=p.y,d=p.d,speed = 4,rx=0,ry=0}
			projectiles[#projectiles] = moves.moveProj(#projectiles,1)
		end
		if name == "wall" then
			for i=1,3 do
				if p.d==0 or p.d==2 then projectiles[#projectiles+1] = {name=name,despawn=1,blocker="fragile",damage=0,image=earthOrbImg,x=p.x-2+i,y=p.y,d=p.d,speed = 0,rx=0,ry=0}
					else projectiles[#projectiles+1] = {name=name,damage=0,despawn=2,blocker="fragile",image=earthOrbImg,x=p.x,y=p.y-2+i,d=p.d,speed = 0,rx=0,ry=0} end
				projectiles[#projectiles] = moves.moveProj(#projectiles,1)
			end
		end
		if name == "lightning" then
			projectiles[#projectiles+1] = {turns=0,branched=false,despawn=0.5,name=name,damage=50,image=lightningImg,x=p.x,y=p.y,d=p.d,speed = 0,rx=0,ry=0}
			projectiles[#projectiles] = moves.moveProj(#projectiles,1)	
		end
		if name == "flood" then
			for x=1,16 do
				willSpawn=false
				if x==1 then willSpawn=true end
				projectiles[#projectiles+1] = {willSpawn=willSpawn,layer=8,despawn=1.3^9,name=name,damage=50,image=floodTopImg,x=x,y=8,d=0,speed = 0,rx=0,ry=0}
			end
		end
		
		moves.playMoveSound(moves[typeNum][num].type)
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

	return p
end

function moves.playMoveSound(type)
	if type=="water" or type=="air" or type=="earth" or type=="fire" then
		sound.play(type.."Effect")
	end
end