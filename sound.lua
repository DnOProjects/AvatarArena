sound = {}

function sound.load()
	ambientMusic = love.audio.newSource("backgroundMusic.mp3")
	roundIntroEffect = love.audio.newSource("roundIntro.mp3","static")

	ambientMusic:setLooping(true)
	ambientMusic:play()
	fadeTimer = 0
	fadeTime=0.01
	ambientVolume = 0.5

	ambientMusic:setVolume(ambientVolume)
	effects = {roundIntro=roundIntroEffect}
end

function sound.update(dt)
	fadeTimer=fadeTimer-dt
	if fadeTimer<0 then fadeTimer=0 end
	if fadeTimer==0 then ambientMusic:setVolume(ambientMusic:getVolume()+fadeTime) end
	if ambientMusic:getVolume() > ambientVolume then ambientMusic:setVolume(ambientVolume) end
end

function sound.play(effect)
	ambientMusic:setVolume(0.05)
	effects[effect]:play()
	fadeTimer = effects[effect]:getDuration("seconds")
end