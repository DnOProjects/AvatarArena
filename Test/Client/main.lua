lovernetlib = require('lovernet')
lovernet = lovernetlib.new()
lovernet:addOp('s')
lovernet:addOp('g')

chat = {}

function love.keypressed(key)
  if key == "return" then
    for i=1,10 do lovernet:pushData('s',{t=textinput}) end
    textinput = nil
  end
end

function love.textinput(char)
  textinput = (textinput or "") .. char
end

function love.update(dt)

  lovernet:sendData('g',chat_index or 0)

  if lovernet:getCache('g') then
    for _,message in pairs(lovernet:getCache('g')) do
      chat_index = math.max(message.i,chat_index or 0)
      table.insert(chat,message.t)
    end
    lovernet:clearCache('g')
  end

  lovernet:update(dt)

end

function love.draw()
  love.graphics.print(textinput or "")
  for i,text in pairs(chat) do
    love.graphics.print(text,0,i*16)
  end
end