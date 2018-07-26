players = {}

function players.load()

	aangImg = love.graphics.newImage("aang.png")
	kataraImg = love.graphics.newImage("katara.png")

	aangPortrait = love.graphics.newImage("aangPortrait.png")
	kataraPortrait = love.graphics.newImage("kataraPortrait.png")
	irohPortrait= love.graphics.newImage("irohPortrait.png")

	characters = {
{name="Aang",img=aangImg,portrait=aangPortrait,moveTimer=0.1,hp=100,bends={"air","earth","fire","water","energy","normal"}},
{name="Katara",img=kataraImg,portrait=kataraPortrait,moveTimer=0.15,hp=120,bends={"water","normal"}},
{name="Iroh",img=kataraImg,portrait=irohPortrait,moveTimer=0.15,hp=120,bends={"fire","normal"}}
}

	players[1] = {char=1,x=1,y=1,d=0,timer=0,invulnerability=0,hp=100,utility=1,attack=1,power=1}
	players[2] = {char=1,x=16,y=8,d=0,timer=0,invulnerability=0,hp=100,utility=1,attack=1,power=1}
end

function players.update(dt)
	players.updateTimer(dt)
	players.checkForHits()
end

function players.updateTimer(dt)
	for i=1,2 do
		p = players[i]
		p.timer = p.timer - dt
		p.invulnerability = p.invulnerability -dt*10
		if p.timer < 0 then p.timer = 0 end
		if p.invulnerability < 0 then p.invulnerability = 0 end
	end
end

function players.checkForHits()
	for i=1,2 do
		for j=1,#projectiles do
			if projectiles[j].rx==players[i].x and projectiles[j].ry==players[i].y and players[i].invulnerability==0 and players[i].hp > 0 then
				players[i].hp=players[i].hp-projectiles[j].damage
				players[i].invulnerability = 10
			end
		end
		if players[i].hp < 0 then
			players[i].hp=0
		end
	end
end

function players.draw()
	for i=1,2 do
		p = players[i]
		love.graphics.setColor(255,255,255)
		if p.invulnerability>0 then love.graphics.setColor(255,255,255,(math.sin(p.invulnerability)+1)*100) end
		love.graphics.draw(characters[p.char].img,p.x*120-60,p.y*120+60,math.pi*p.d/2,1,1,60,60)
		love.graphics.setColor(255,255,255)
	end
end

function players.move(p,d,unconditional)
	ox,oy = players[p].x,players[p].y
	if players[p].timer==0 or unconditional then
		if not unconditional then players[p].timer = characters[players[p].char].moveTimer end
		players[p].d = d
		if d==0 then players[p].y=players[p].y-1 end
		if d==1 then players[p].x=players[p].x+1 end
		if d==2 then players[p].y=players[p].y+1 end
		if d==3 then players[p].x=players[p].x-1 end
	end
	if players[p].x<1 or players[p].x>16 then players[p].x = ox end
	if players[p].y<1 or players[p].y>8 then players[p].y = oy end
end