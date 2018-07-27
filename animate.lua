require "logic"
animate = {}

function animate.draw(sprite,x,y,percent,r,spriteLength)
	spriteNum = math.floor((percent/100)*spriteLength,0)
	quad=love.graphics.newQuad(spriteNum*120,0,120,120,120*spriteLength,120)
	love.graphics.draw(p.image,quad,x,y,r,1,1,60,60)
end

function animate.update(dt)
	animate.updateAnimations(dt)
end

function animate.updateAnimations(dt)
	for i=1,#projectiles do
		p=projectiles[i]
		if p.percent then 
			p.percent = p.percent + dt*100*p.aSpeed
			if p.percent > 100 then p.percent = p.percent-100 end
		end
	end
end