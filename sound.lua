sound = {}

function sound.load()
	ambientMusic = love.audio.newSource("backgroundMusic.mp3")
	ambientMusic:setLooping(true)
	ambientMusic:play()
end

function sound.update()
end