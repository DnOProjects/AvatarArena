require "logic"
require "players"
require "animate"
require "sound"

	moves = { --first moves must all be normal
{{name="charge",type="normal"},{name="wall",type="earth"},{name="blink",type="air"}},--utility
{{name="arrow",type="normal"},{name="spurt",type="water"},{name="gust",type="air"},{name="blast",type="fire"},{name="boulder",type="earth"}},--attack
{{name="block",type="normal"},{name="supernova",type="fire"},{name="heal",type="water"}}--power	
}

projectiles = {}

function moves.load()
	arrowImg = love.graphics.newImage("arrow.png")
	waterOrbImg = love.graphics.newImage("water.png")
	earthOrbImg = love.graphics.newImage("earth.png")
	airOrbImg = love.graphics.newImage("airSprite.png")
	fireOrbImg = love.graphics.newImage("fire.png")
end

function moves.update(dt)
	moves.moveProjectiles(dt)
	moves.floorPositions()
	moves.updateAnimations(dt)
end

	function moves.updateAnimations(dt)
		for i=1,#projectiles do
			p=projectiles[i]
			if p.percent then p.percent = p.percent + dt*100*p.aSpeed end
			if p.percent and p.percent > 100 then p.percent = p.percent-100 end
		end
	end

	function moves.moveProjectiles(dt)
		--speed is in tiles/sec
		for i=1,#projectiles do
			p=projectiles[i]
			p=moves.moveProj(p,p.speed*dt)
		end
	end

	function moves.floorPositions()
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
			animate.draw(p.image,p.rx*120-60,p.ry*120+60,p.percent,math.pi*p.d/2,p.spriteLength)
		else
			love.graphics.draw(p.image,p.rx*120-60,p.ry*120+60,math.pi*p.d/2,1,1,60,60)
		end
	end
end

function moves.cast(typeNum,num,pn)
	moves.playMoveSound(moves[typeNum][num].type)
	p=players[pn]
	name = moves[typeNum][num].name
	if name == "arrow" then
		projectiles[#projectiles+1] = {name=name,damage=10,image=arrowImg,x=p.x,y=p.y,d=p.d,speed = 4,rx=0,ry=0}
		projectiles[#projectiles] = moves.moveProj(projectiles[#projectiles],1)
	end
	if name == "spurt" then
		for i=1,3 do
			if p.d==0 or p.d==2 then projectiles[#projectiles+1] = {name=name,damage=10,image=waterOrbImg,x=p.x-2+i,y=p.y,d=p.d,speed = 2,rx=0,ry=0}
				else projectiles[#projectiles+1] = {name=name,damage=10,image=waterOrbImg,x=p.x,y=p.y-2+i,d=p.d,speed = 2,rx=0,ry=0} end
			projectiles[#projectiles] = moves.moveProj(projectiles[#projectiles],1)
		end
	end
	if name == "charge" then for i=1,3 do players.move(pn,p.d,true) end end
	if name == "gust" then
		projectiles[#projectiles+1] = {percent=0,spriteLength=6,aSpeed=2,name=name,damage=10,image=airOrbImg,x=p.x,y=p.y,d=p.d,speed = 4,rx=0,ry=0}
		projectiles[#projectiles] = moves.moveProj(projectiles[#projectiles],1)
	end
	if name == "blast" then
		for i=0,1 do
			local d = p.d+(i*2)
			if d==4 then d=0 end
			if d==5 then d=1 end
			projectiles[#projectiles+1] = {percent=0,spriteLength=6,aSpeed=0.7,name=name,damage=10,image=fireOrbImg,x=p.x,y=p.y,d=d,speed = 4,rx=0,ry=0}
			projectiles[#projectiles] = moves.moveProj(projectiles[#projectiles],1)
		end
	end
	if name == "boulder" then
		projectiles[#projectiles+1] = {name=name,damage=20,image=earthOrbImg,x=p.x,y=p.y,d=p.d,speed = 8,rx=0,ry=0}
		projectiles[#projectiles] = moves.moveProj(projectiles[#projectiles],1)
	end
end

function moves.moveProj(p,num)
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