ai={}

function ai.load(aiPlayer,diff)
	players[aiPlayer].controller = "ai"
	ai.diff=diff
	ai.saving = false
	ai.reactionTimer=0
	ai.dodgeTimer=0
end

function ai.update(dt)

	ai.reactionTimer=ai.reactionTimer-dt
	ai.dodgeTimer=ai.dodgeTimer-dt

	if players[aiPlayer].controller=="ai" then

		local p=players[aiPlayer]
		local op=players[humanPlayer]
		local key=nil
		keys={"up","down","left","right",",",".","/"}
		if aiPlayer == 1 then keys={"r","f","d","g","`","1","2"} end

		if ai.diff=="easy" then
			key=keys[math.random(1,6)]
		end

		if ai.reactionTimer<0 then
			if ai.diff=="medium" then
				if math.random(1,10) == 1 then
					key=keys[math.random(1,5)]
				else 
					key=ai.perfect(p,op,false)
				end
				ai.reactionTimer=0.3
			end

			if ai.diff=="hard" then
				key=ai.perfect(p,op,false)
				ai.reactionTimer=0.1
			end

			if ai.diff=="expert" then
				key=ai.perfect(p,op,true)
				ai.reactionTimer=-1
			end
		end

		input.keyInput(key,"ai")	

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

function ai.perfect(p,op,expert)

	-- p = AI
	-- op = Player

	danger=false
	avoidKey=nil
	local playerDanger = {x=false,y=false}
	for i=1,#projectiles do -- Decides which key to press to avoid an incoming attack
		local pr=projectiles[i]
		if pr.d==0 and pr.x==p.x and pr.y>p.y then avoidKey,danger=keys[math.random(3,4)],pr.y-p.y end -- Key 3 = left, Key 4 = right
		if pr.d==1 and pr.y==p.y and pr.x<p.x then avoidKey,danger=keys[math.random(1,2)],p.x-pr.x end -- Key 1 = up, Key 2 = down
		if pr.d==2 and pr.x==p.x and pr.y<p.y then avoidKey,danger=keys[math.random(3,4)],p.y-pr.y end
		if pr.d==3 and pr.y==p.y and pr.x>p.x then avoidKey,danger=keys[math.random(1,2)],pr.x-p.x end
		if op.x == pr.x then playerDanger.x = true end
		if op.y == pr.y then playerDanger.y = true end
	end

	local key=nil
	if (not((p.x==op.x) or (p.y==op.y)) and (expert==false or ai.dodgeTimer<0)) then -- Decides if to move onto the same line as the enemy
		if math.abs(p.x-op.x)<math.abs(p.y-op.y) and playerDanger.x == false then
			if p.x>op.x then key=keys[3] else key=keys[4] end
		elseif playerDanger.y == false then
			if p.y<op.y then key=keys[2] else key=keys[1] end
		end
	else
		if not ai.facing(p,op) then -- Change direction to face opponent
			if p.x==op.x then
				if p.d==0 then key=keys[2] else key=keys[1] end
			else
				if p.d==1 then key=keys[3] else key=keys[4] end
			end
		else
			if expert and danger~=false then -- Cast utility if the AI is in danger of an attack AND playing on expert
				if danger<2 and math.random(1,5)==1 then key=keys[5] else key=avoidKey end
			else
				if not ai.saving then
					if p.chi>moves[2][p.attack].cost then -- Cast attack if the AI has enough chi AND they're not saving up chi
						key=keys[6]
						if math.random(1,4)==1 then ai.saving=true end -- 1/4 chance for the AI to start saving chi
					end
				else
					if p.chi>moves[3][p.power].cost then -- Cast power if the AI has enough chi AND they're saving up chi
						key=keys[7]
						ai.saving = false
					end
				end
			end
		end
	end
	if danger~=false and ai.dodgeTimer < 0 then ai.dodgeTimer = 0.5 end
	return key

end