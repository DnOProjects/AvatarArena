players = {}

players[1] = {beenBlown=false,char=1,x=1,y=1,d=0,timer=0,invulnerability=0,hp=100,maxHp=100,chiRegen=4,chi=0,maxChi=100,utility=1,attack=1,power=1}
players[2] = {beenBlown=false,char=1,x=16,y=8,d=0,timer=0,invulnerability=0,hp=100,maxHp=100,chiRegen=4,chi=0,maxChi=100,utility=1,attack=1,power=1}

function players.load()

	players.world = "physical"
	players.shiftTimer = 0
	
	lineOfSightWidth = 5

	characters = {
{name="Aang",chiRegen=4,img=aangImg,portrait=aangPortrait,moveTimer=0.1,hp=100,bends={"air","earth","fire","water","energy","normal"}},
{name="Katara",chiRegen=4,img=kataraImg,portrait=kataraPortrait,moveTimer=0.15,hp=120,bends={"water","normal"}},
{name="Iroh",chiRegen=8,img=irohImg,portrait=irohPortrait,moveTimer=0.15,hp=80,bends={"fire","normal"}},
{name="Toph",chiRegen=4,img=tophImg,portrait=tophPortrait,moveTimer=0.15,hp=130,bends={"earth","normal"}},
{name="Gyatso",chiRegen=6,img=gyatsoImg,portrait=gyatsoPortrait,moveTimer=0,hp=80,bends={"air","normal"}},
{name="Sokka",chiRegen=4,img=sokkaImg,portrait=sokkaPortrait,moveTimer=0.15,hp=130,bends={"sokka","normal"}}
}

	p1 = players[1]
	p2 = players[2]
	players[1] = {lineOfSight={},deflecting=false,beenBlown=false,char=p1.char,x=1,y=1,d=0,vd=0,timer=0,invulnerability=0,hp=100,maxHp=100,chiRegen=4,chi=0,maxChi=100,utility=p1.utility,attack=p1.attack,power=p1.power}
	players[2] = {lineOfSight={},deflecting=false,beenBlown=false,char=p2.char,x=16,y=8,d=0,vd=0,timer=0,invulnerability=0,hp=100,maxHp=100,chiRegen=4,chi=0,maxChi=100,utility=p2.utility,attack=p2.attack,power=p2.power}

end

function players.update(dt)
	players.updateTimer(dt)
	players.checkForHits()
	players.checkForLineOfSight()
	players.poolChi(dt)
	players.die()
end

	function players.poolChi(dt)
		for i=1,2 do
			p=players[i]
			p.chi=p.chi+p.chiRegen*dt
			if p.chi>p.maxChi then p.chi=p.maxChi end
		end
	end

	function players.updateTimer(dt)
		players.shiftTimer = players.shiftTimer - dt
		if players.shiftTimer < 0 then players.shiftTimer = 0 end
		if players.shiftTimer==0 then players.world="physical" else players.world="spiritual" end

		for i=1,2 do
			p = players[i]
			p.timer = p.timer - dt
			p.invulnerability = p.invulnerability - dt*10
			if p.timer < 0 then p.timer = 0 end
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

	function players.checkForHits()
		for i=1,2 do
			for j=1,#projectiles do
				if projectiles[j].damage>0 and projectiles[j].rx==players[i].x and projectiles[j].ry==players[i].y and players[i].invulnerability==0 and players[i].deflecting == false and players[i].hp > 0 then
					if not((projectiles[j].name=="boomerang" or projectiles[j].name=="sword flurry") and projectiles[j].caster==i) then
						players[i].hp=players[i].hp-projectiles[j].damage
						players[i].invulnerability = 10
					end
					if projectiles[j].removesOnHit == nil or projectiles[j].removesOnHit==true then
						if not(projectiles[j].name=="boomerang") or projectiles[j].caster == i then
							projectilesToRemove[#projectilesToRemove+1] = j
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
			    projectilesToRemove = {}
			    loser = i
			end
		end
	end

function players.draw()
	for i=1,2 do
		p = players[i]
		love.graphics.setColor(255,255,255)
		if p.invulnerability>0 then
			love.graphics.setColor(255,255,255,(math.sin(p.invulnerability)+1)*100)
		end
		if logic.round(players[i].vd) == 0 then
			love.graphics.draw(characters[p.char].img,p.x*120-60,p.y*120+60,math.pi*p.d/2,1,1,60,60)
		else
			love.graphics.draw(characters[p.char].img,p.x*120-60,p.y*120+60,math.pi*p.vd/2,1,1,60,60)
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
	if players[p].timer==0 or unconditional then
		if not unconditional then players[p].timer = characters[players[p].char].moveTimer end
		players[p].d = d
		players[p].lineOfSight = {}
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
end	

	function players.canBeHere(n)
		p=players[n]
		on=n+1
		if on==3 then on=1 end
		op=players[on]

		if p.x<1 or p.x>16 or p.y<1 or p.y>8
		or (p.x==op.x and p.y==op.y) then return false end

		for i=1,#projectiles do
			pr=projectiles[i]
			if pr.blocker and p.x==pr.rx and p.y==pr.ry and not(pr.blocker=="forceField") then return false  end
		end

		return true
	end

	function players.canCast(p)
		for i=1,#projectiles do
			pr=projectiles[i]
			if pr.rx==p.x and pr.ry==p.y then
				if pr.name == "aurora borealis" then return false end
			end
		end
		return true
	end