ai={}

function ai.load(aiPlayer,diff)
	players[aiPlayer].controller = "ai"
	ai.diff=diff
	ai.saving = false
	ai.reactionTimer=0
	ai.dodgeTimer=0
	ai.mode="ramble"
	ai.destination={x=8,y=4}
	ai.currentPriority = 0
	ai.sillTimer=0
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
					key=ai.perfect(p,op)
				end
				ai.reactionTimer=0.3
			end

			if ai.diff=="hard" then
				key=ai.perfect(p,op)
				ai.reactionTimer=0.1
			end

			if ai.diff=="expert" then
				--key=ai.perfect(p,op,true)
				key=ai.perfect2(p,op,dt)
				ai.reactionTimer=0.1
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

function ai.changeMode()
	local r=math.random(1,7)
	if r<5 then ai.mode="attack" end
	if r==7 then ai.mode="power" end
	if r<7 and r>4 then 
		ai.mode="ramble" 
		ai.destination={x=math.random(2,15),y=math.random(2,7)}
	end
end

function ai.perfect2(p,op,dt)

	if p.x==ai.destination.x and p.y==ai.destination.y then ai.sillTimer = ai.sillTimer + dt else ai.sillTimer = 0 end
	if ai.sillTimer>2 then ai.destination={x=math.random(2,15),y=math.random(2,7)} end

	if (ai.destination.x==1 and op.x~=1) or (ai.destination.x==16 and op.x~=16) then ai.destination.x=math.random(2,15) end
	if (ai.destination.y==1 and op.y~=1) or (ai.destination.y==8 and op.y~=8) then ai.destination.y=math.random(2,7) end

	for i=1,#projectiles do
		local pr = moves.moveProj(i,1)
		pr.rx = logic.round(pr.x,0)
		pr.ry = logic.round(pr.y,0)
		if pr.damage>0 and pr.rx==p.x and pr.ry==p.y and pr.caster~=aiPlayer then
			ai.mode="dodge"
		end
		local pr = moves.moveProj(i,-1)
	end

	--modes: attack,power,dodge,ramble
	if (p.x~=ai.destination.x or p.y~=ai.destination.y) and ai.mode~="dodge" then

		if math.abs(p.x-ai.destination.x)> math.abs(p.y-ai.destination.y) then
			if p.x>ai.destination.x then return keys[3] else return keys[4] end
		else
			if p.y>ai.destination.y then return keys[1] else return keys[2] end
		end

	else

		for i=1,#projectiles do--checking for special projectile behaviors
			local pr=projectiles[i]
			if pr.name == "flood" then
				return keys[1]
			end
			if (pr.name == "fire breath" or pr.name == "swinging sword") and pr.caster == aiPlayer then
				ai.destination={x=op.x,y=op.y}
			end
			if pr.name=="heal" then ai.destination={x=pr.rx,y=pr.ry} end
		end	


		if ai.mode=="dodge" then --NOT 100% HAPPY WITH ATM (TO POST-CORNWALL DANNY)

			--if moves[1][p.utility].defensive and math.random(1,2)==1 then

			local moveOptions={true,true,true,true}
			for i=1,#projectiles do
				local pr=moves.moveProj(i,1)
				if pr.damage>0 and pr.caster~=aiPlayer then
					if pr.rx==p.x+1 and pr.ry==p.y then table.remove(moveOptions,4) end
					if pr.rx==p.x-1 and pr.ry==p.y then table.remove(moveOptions,3) end
					if pr.rx==p.x and pr.ry==p.y+1 then table.remove(moveOptions,2) end
					if pr.rx==p.x and pr.ry==p.y-1 then table.remove(moveOptions,1) end
					local pr = moves.moveProj(i,-1)
				end
			end
			local keyMoveOptions={}
			for i=1,4 do
				if moveOptions[i]==true then keyMoveOptions[#keyMoveOptions+1] = keys[i] end
			end
			ai.changeMode()
			if #keyMoveOptions==0 then 
				return "nokey" 
			end
			return keyMoveOptions[math.random(1,#keyMoveOptions)]
		end

		if ai.mode=="ramble" then
				if p.x==ai.destination.x and p.y==ai.destination.y then
					ai.changeMode()
				end
		end
		
		if ai.mode=="attack" or ai.mode=="power" then

			local attackNum=1
			local moveNum=p.attack
			if ai.mode=="power" then attackNum,moveNum=2,p.power end

			if p.x~=op.x and p.y~=op.y then
				if math.abs(p.x-op.x)<math.abs(p.y-op.y) then
					ai.destination.x=op.x
				else
					ai.destination.y=op.y
				end
			end

			if ai.facing(p,op) then
				if p.chi>moves[attackNum+1][moveNum].cost then
					ai.changeMode()
					return keys[attackNum+5]
				else return "nokey" end
			else--turn to face
				if p.x==op.x then
					if p.y>op.y then return keys[2] else return keys[1] end
				else
					if p.x>op.x then return keys[4] else return keys[3] end
				end
			end
		end

	end
end


function ai.perfect(p,op)

	-- p = AI
	-- op = Player

	local key=nil
	moveSpecific = ai.moveSpecific(p,op)
	if moveSpecific == false then
		danger=false
		avoidKey=nil
		local playerDanger = {x=false,y=false}
		for i=1,#projectiles do -- Decides which key to press to avoid an incoming attack
			local pr=projectiles[i]
			if pr.d==0 and pr.x==p.x and pr.y>p.y then avoidKey,danger=keys[math.random(3,4)],pr.y-p.y end -- Key 3 = left, Key 4 = right
			if pr.d==1 and pr.y==p.y and pr.x<p.x then avoidKey,danger=keys[math.random(1,2)],p.x-pr.x end -- Key 1 = up, Key 2 = down
			if pr.d==2 and pr.x==p.x and pr.y<p.y then avoidKey,danger=keys[math.random(3,4)],p.y-pr.y end
			if pr.d==3 and pr.y==p.y and pr.x>p.x then avoidKey,danger=keys[math.random(1,2)],pr.x-p.x end
			if op.x == pr.x and op.d ~= pr.d then playerDanger.x = true end
			if op.y == pr.y and op.d ~= pr.d then playerDanger.y = true end
		end
		if not(p.x==op.x or p.y==op.y) then -- Decides if to move onto the same line as the enemy
			if math.abs(p.x-op.x)<math.abs(p.y-op.y) and playerDanger.x == false then
				if p.x>op.x then key=keys[3] else key=keys[4] end
			elseif math.abs(p.x-op.x)>math.abs(p.y-op.y) and playerDanger.y == false then
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
				if danger~=false then -- Cast utility if the AI is in danger of an attack AND playing on expert
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
	else
		key = moveSpecific
	end
	return key

end

function ai.moveSpecific(p,op)

	local topPriorityActive = false
	local key = false
	for i=1,#projectiles do
		pr = projectiles[i]
		if (pr.name == "fire breath" or pr.name == "swinging sword") and pr.caster == aiPlayer and ai.currentPriority < 1 then ai.currentPriority = 1 end
		if (pr.name == "fire breath" or pr.name == "swinging sword") and pr.caster == aiPlayer and ai.currentPriority == 1 then
			topPriorityActive = true
			if math.abs(p.x-op.x)>math.abs(p.y-op.y) then
				if p.x>op.x then key=keys[3] else key=keys[4] end
			else
				if p.y>op.y then key=keys[1] else key=keys[2] end
			end
		end
		if pr.name == "heal" and p.hp < p.maxHp and ai.currentPriority < 2 then ai.currentPriority = 2 end
		if pr.name == "heal" and p.hp < p.maxHp and ai.currentPriority == 2 then
			topPriorityActive = true
			if math.abs(projectiles[i].x-op.x)>math.abs(projectiles[i].y-op.y) then
				if pr.x<op.x then key=keys[3] else key=keys[4] end
			else
				if pr.y<op.y then key=keys[1] else key=keys[2] end
			end
		end
	end
	if topPriorityActive == false then ai.currentPriority = 0 end
	return key

end