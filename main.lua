require "logic"
require "input"
require "map"
require "players"
require "moves"
require "ui"
require "ai"
require "animate"
require "Images/images"
require "Sounds/sound"
bitser = require "Online/bitser"

local shader_code = [[
#define NUM_LIGHTS 100

struct Light {
    vec2 position;
    vec3 diffuse;
    float power;
};

extern Light lights[NUM_LIGHTS];
extern int num_lights;

extern vec2 screen;

const float constant = 1.0;
const float linear = 0.09;
const float quadratic = 0.032;

vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords){
    vec4 pixel = Texel(image, uvs);

    vec2 norm_screen = screen_coords / screen;
    vec3 diffuse = vec3(0);

    for (int i = 0; i < num_lights; i++) {
        Light light = lights[i];
        vec2 norm_pos = light.position / screen;

        float distance = length(norm_pos - norm_screen) * light.power;
        float attenuation = 1.0 / (constant + linear * distance + quadratic * (distance * distance));

        diffuse += light.diffuse * attenuation;
    }

    diffuse = clamp(diffuse, 0.0, 1.0);
    return pixel * vec4(diffuse, 1.0) * color;
}
]]

local shader = nil

function save()
	love.filesystem.write("avatarArenaSaves.txt", bitser.dumps(SAVED))
end

function love.load()
	if love.filesystem.getInfo("avatarArenaSaves.txt")~=nil then 
		SAVED=bitser.loads(love.filesystem.read("avatarArenaSaves.txt")) 
	else 
		SAVED={accounts={}}
	end

    shader = love.graphics.newShader(shader_code)

	startServer = true

	debugMode = false

	math.randomseed(os.time())
	love.window.setFullscreen(true)
	love.window.setMode(love.graphics.getWidth(), love.graphics.getHeight(), {borderless=true,display=1})

	love.mouse.setVisible(false)
    love.graphics.setDefaultFilter("nearest","linear", 100 )

    map.load()
    moves.load()
    players.load()
    ui.load()
    sound.load()

    selectedGameMode=1
    --gameState = "menu"
    projectilesToRemove = {}
    showDescription = 1

    moveSet = {1,1}

    gameEndFade=false

    lights = {}
    normalBrightness=0.01 --50%

end

function love.update(dt)
	save()
	if onlineClient == false then

		fadeGameEnd(dt)

		if gameEvent=="time warp" then dt=dt*dtMultiplier end
		if onlineGame then
			if startServer then
				startServer = false
				canvas = love.graphics.newCanvas(1920,1080)
				love.window.setMode(1000, 700, {resizable=true,borderless=false,minwidth=650,minheight=400})
				require "Online/server"
				server.load()
			end
			love.graphics.setCanvas(canvas)
			addToDrawCanvas()
			love.graphics.setCanvas()
			server:setStorage(canvas)
			server:update(dt)
		end

		if gameState=="game" then
			if aiPlayer ~= nil then ai.update(dt) end
			players.update(dt)
			moves.update(dt)
			animate.update(dt)
		end
		ui.update(dt)
		sound.update(dt)

		removeProjectiles()
	else
		client.updateData(dt)
	end

end

	function removeProjectiles()
		table.sort(projectilesToRemove)
		for i=#projectilesToRemove,1,-1 do
			table.remove(projectiles,projectilesToRemove[i])
			table.remove(projectilesToRemove,i)
		end
	end

function fadeGameEnd(dt)
	if gameEndFade~=false and gameEndFade < 1 then
		gameState = "winScreen"
		pausedSelection=2
		projectilesToRemove = {}
		gameEndFade = false 
	end
	if gameEndFade~=false then gameEndFade=gameEndFade-dt end
end

function love.draw()
	
	addToDrawCanvas()

end

function addToDrawCanvas()

	if onlineClient == false and onlineGame == false then
		if gameState=="game" then

			if gameEvent=="night" then

				love.graphics.setShader(shader)
			    shader:send("screen", {
			        love.graphics.getWidth(),
			        love.graphics.getHeight()
			    })
			    shader:send("num_lights", #projectiles+3)    

			    shader:send("lights[0].position", {
			        players[1].x*120-60,
			        players[1].y*120+60
			    })
			    shader:send("lights[0].diffuse", { --light color
			        normalBrightness, normalBrightness, normalBrightness
			    })
			    shader:send("lights[0].power", 1)

			    shader:send("lights[1].position", {players[1].x*120-60,players[1].y*120+60}) --postition
			    shader:send("lights[1].diffuse", {1, 1, 1}) --color
			    shader:send("lights[1].power", 64)

			    shader:send("lights[2].position", {players[2].x*120-60,players[2].y*120+60}) --postition
			    shader:send("lights[2].diffuse", {1, 1, 1}) --color
			    shader:send("lights[2].power", 64)

			    for i=1,#projectiles do
			    	local p= projectiles[i]
			    	if p.glows then
				    	local shaderNum=tostring(2+i)
				    	local c = p.glowColor
				    	local power = p.glowPower or 100
					    shader:send("lights["..shaderNum.."].position", {p.rx*120-60,p.ry*120+60}) --postition
					    shader:send("lights["..shaderNum.."].diffuse", {c[1]/255, c[2]/255, c[3]/255}) --color
					    shader:send("lights["..shaderNum.."].power", 100) --power is inverted for some reason
					end
			    end

			end

			map.draw()
			moves.draw()
			players.draw()

			love.graphics.setShader()
		end

		ui.draw()

		if gameEndFade~=false then
			love.graphics.setColor(1,0.5,0)
			if loser ~= "draw" and gameMode~="Competitive" then love.graphics.printf("Player "..winner.." wins!",0,300,1000,"center",0,2,2) end
			if loser ~= "draw" and gameMode=="Competitive" then love.graphics.printf(battlingAccounts[winner].name.." wins!",0,300,1000,"center",0,2,2) end
			if loser=="draw" then love.graphics.printf("It's a draw!",0,280,1000,"center",0,2,2) end
			love.graphics.setColor(1,1,1,1/gameEndFade-0.25)
			love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
		end

		if debugMode then
			love.graphics.setColor(0,1,0)
			love.graphics.print("Debug Mode:",0,0,0,0.6,0.6)
			love.graphics.print("FPS:  "..love.timer.getFPS(),0,50,0,0.4,0.4)
			love.graphics.print("# Projectiles:  "..#projectiles,0,80,0,0.4,0.4)
			love.graphics.setColor(1,1,1)
		end
	elseif onlineClient == true then
		client.draw()
	elseif onlineGame == true then
		love.graphics.print("Running server..")
	end

end

function startGame()
	dtMultiplier=1
	players.load()
	map.load()
	projectiles = {}
	gameEvent = menu[5].options[menu[5].selected]
	gameState = "game" 
	eventTimer=0
	if gameEvent=="time warp" then eventTimer=1 end
	for i=1,2 do
		players[i].utility = ui[i][1]
		players[i].attack = ui[i][2]
		players[i].power = ui[i][3]
	end

	for i=1,2 do
		players[i].hp = characters[players[i].char].hp
		players[i].maxHp = characters[players[i].char].hp
		players[i].chiRegen = characters[players[i].char].chiRegen
	end

	arenaType = characters[players[1].char].bends[1]
	sound.play("roundIntro")
	if menu[2].options[menu[2].selected]=="ai" then 
		ai.load(aiPlayer,menu[3].options[menu[3].selected]) 
		players[humanPlayer].controller = "human"  
		players[aiPlayer].controller = "ai"
	else
		players[1].controller = "human"  
		players[2].controller = "human" 
	end
end

function love.keypressed(key)
	if onlineClient == false then
		if key=="9" then 
			if debugMode then ambientMusic:play() else ambientMusic:pause() end
			debugMode=not debugMode 
		end
		input.keyInput("keyboard",key)
	else
		client.keyInput(key)
	end
end

function love.mousepressed(x,y,key)
	if onlineClient == false then
		input.keyInput("mouse",key)
	else
		client.keyInput(key)
	end
end