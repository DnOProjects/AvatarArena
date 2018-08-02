ai={}

function ai.load(num,diff)
	players[2].controler = "ai"
	ai.diff=diff
	ai.saving = false
	ai.reactionTimer=0
	ai.dodgeTimer=0
end

function ai.update(dt)

	ai.reactionTimer=ai.reactionTimer-dt
	ai.dodgeTimer=ai.dodgeTimer-dt

	if players[2].controler=="ai" then

		local p=players[2]
		local op=players[1]
		local key=nil
		local keys={"up","down","left","right",",",".","/"}

		if ai.diff=="easy" then
			key=keys[math.random(1,6)]
		end

		if ai.reactionTimer<0 then
			if ai.diff=="medium" then
				if math.random(1,10) == 1 then
					key=keys[math.random(1,5)]
				else 
					key=ai.perfect(p,op)
				end
				ai.reactionTimer=0.3
			end

			if ai.diff=="hard" then
				key=ai.perfect(p,op)
				ai.reactionTimer=0.1
			end

			if ai.diff=="expert" then
				key=ai.perfect(p,op,true)
				ai.reactionTimer=-1
			end
		end

		server.keyInput(key,"ai")	

	end
end

function ai.facing(p,op)
	local d=p.d
	if d==0 and p.y>op.y and p.x==op.x then return true end
	if d==1 and p.x<op.x and p.y==op.y then return true end
	if d==2 and p.y<op.y and p.x==op.x then return true end
	if d==3 and p.x>op.x and p.y==op.y then return true end
	return false
end

function ai.perfect(p,op,hard)

	danger=false
	local keys = {"up","down","left","right"}
	avoidKey=nil
	for i=1,#projectiles do
		pr=projectiles[i]
		if pr.d==0 and pr.x==p.x and pr.y>p.y then avoidKey,danger=keys[math.random(3,4)],pr.y-p.y end
		if pr.d==1 and pr.y==p.y and pr.x<p.x then avoidKey,danger=keys[math.random(1,2)],p.x-pr.x end
		if pr.d==2 and pr.x==p.x and pr.y<p.y then avoidKey,danger=keys[math.random(3,4)],p.y-pr.y end
		if pr.d==3 and pr.y==p.y and pr.x>p.x then avoidKey,danger=keys[math.random(1,2)],pr.x-p.x end
	end

	local key=nil
	if (not((p.x==op.x) or (p.y==op.y)) and (hard~=true or ai.dodgeTimer<0)) then
				if math.abs(p.x-op.x)<math.abs(p.y-op.y) then
					if p.x>op.x then key="left" else key="right" end
				else
					if p.y<op.y then key="down" else key="up" end
				end
			else
				if not ai.facing(p,op) then
					if p.x==op.x then
						if p.d==0 then p.d=2 else p.d=0 end
					else
						if p.d==1 then p.d=3 else p.d=1 end
					end
				else
					if hard and not(danger==false) then
						if danger<2 and math.random(1,5)==1 then key="," else key=avoidKey end
					else
						if not ai.saving then
							if p.chi>moves[2][p.attack].cost then
								key="."
								if math.random(1,4)==1 then ai.saving=true end
							end
						else
							if p.chi>moves[3][p.power].cost then
								key="/"
								ai.saving = false
							end
						end
					end
				end
			end
	if danger~=false and ai.dodgeTimer <0 then ai.dodgeTimer = 0.5 end
	return key
end