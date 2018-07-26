sound = {}

function sound.load()
	ambientMusic = love.audio.newSource("backgroundMusic.mp3")

	roundIntroEffect = love.audio.newSource("roundIntro.mp3","static")
	earthEffect = love.audio.newSource("earthEffect.mp3","static")
	waterEffect = love.audio.newSource("waterEffect.mp3","static")
	airEffect = love.audio.newSource("airEffect.mp3","static")
	fireEffect = love.audio.newSource("fireEffect.mp3","static")

	ambientMusic:setLooping(true)
	ambientMusic:play()
	fadeTimer = 0
	fadeTime=0.01
	ambientVolume = 0.5

	ambientMusic:setVolume(ambientVolume)
	effects = {roundIntro=roundIntroEffect,earthEffect=earthEffect,waterEffect=waterEffect,airEffect=airEffect,fireEffect=fireEffect}
end

function sound.update(dt)
	fadeTimer=fadeTimer-dt
	if fadeTimer<0 then fadeTimer=0 end
	if fadeTimer==0 then ambientMusic:setVolume(ambientMusic:getVolume()+fadeTime) end
	if ambientMusic:getVolume() > ambientVolume then ambientMusic:setVolume(ambientVolume) end
end

function sound.play(effect)
	ambientMusic:setVolume(0.25)
	if effects[effect]:isPlaying() then effects[effect]:stop() end
	effects[effect]:play()
	effects[effect]:setVolume(0.5)
	fadeTimer = effects[effect]:getDuration("seconds")
end