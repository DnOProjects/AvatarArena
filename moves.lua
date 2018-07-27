require "logic"
require "players"
require "animate"
require "sound"

moves = { --first moves must all be normal

--Utility
{{name="charge",type="normal",cost=2},
{name="aurora borealis",type="water",cost=8},
{name="wall",type="earth",cost=5}},
--Attack
{{name="arrow",type="normal",cost=6},
{name="spurt",type="water",cost=16},
{name="gust",type="air",cost=8},
{name="blast",type="fire",cost=10},
{name="boulder",type="earth",cost=8}},
--Power
{{name="block",type="normal",cost=40}}
}

projectiles = {}

function moves.load()
	arrowImg = love.graphics.newImage("arrow.png")
	waterOrbImg = love.graphics.newImage("water.png")
	earthOrbImg = love.graphics.newImage("earth.png")
	
	fireOrbImg = love.graphics.newImage("fireSprite.png")
	airOrbImg = love.graphics.newImage("airSprite.png")
	auroraImg = love.graphics.newImage("auroraSprite.png")
end

function moves.update(dt)
	moves.moveProjectiles(dt)
	moves.roundPositions()
	moves.removeReduntantProjectiles()
	moves.despawn(dt)
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
		love.graphics.setColor(255,255,255)
		if p.percent then
			animate.draw(p.image,p.rx*120-60,p.ry*120+60,p.percent,math.pi*p.d/2,p.spriteLength,p.continuous)
		else
			love.graphics.draw(p.image,p.rx*120-60,p.ry*120+60,math.pi*p.d/2,1,1,60,60)
		end
	end
end

function moves.cast(typeNum,num,pn)
	p=players[pn]
	if p.chi >= moves[typeNum][num].cost then
		p.chi=p.chi-moves[typeNum][num].cost

		name = moves[typeNum][num].name

		if name == "arrow" then
			projectiles[#projectiles+1] = {name=name,damage=10,image=arrowImg,x=p.x,y=p.y,d=p.d,speed = 4,rx=0,ry=0}
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
		if name == "aurora borealis" then
			projectiles[#projectiles+1] = {continuous=true,blocker="forceField",despawn=5,percent=0,spriteLength=6,aSpeed=1,name=name,damage=0,image=auroraImg,x=p.x,y=p.y,d=p.d,speed = 0,rx=0,ry=0}
			projectiles[#projectiles] = moves.moveProj(#projectiles,1)
		end
		if name == "blast" then
			for i=0,1 do
				local d = p.d+1+(i*2)
				if d>3 then d=d-4 end
				projectiles[#projectiles+1] = {percent=0,spriteLength=6,aSpeed=0.7,name=name,damage=10,image=fireOrbImg,x=p.x,y=p.y,d=d,speed = 4,rx=0,ry=0}
				projectiles[#projectiles] = moves.moveProj(#projectiles,1)
			end
		end
		if name == "boulder" then
			projectiles[#projectiles+1] = {name=name,damage=20,image=earthOrbImg,x=p.x,y=p.y,d=p.d,speed = 8,rx=0,ry=0}
			projectiles[#projectiles] = moves.moveProj(#projectiles,1)
		end
		if name == "wall" then
			for i=1,3 do
				if p.d==0 or p.d==2 then projectiles[#projectiles+1] = {name=name,despawn=1,blocker="fragile",damage=0,image=earthOrbImg,x=p.x-2+i,y=p.y,d=p.d,speed = 0,rx=0,ry=0}
					else projectiles[#projectiles+1] = {name=name,damage=0,despawn=1,blocker="fragile",image=earthOrbImg,x=p.x,y=p.y-2+i,d=p.d,speed = 0,rx=0,ry=0} end
				projectiles[#projectiles] = moves.moveProj(#projectiles,1)
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

	return p
end

function moves.playMoveSound(type)
	if type=="water" or type=="air" or type=="earth" or type=="fire" then
		sound.play(type.."Effect")
	end
end