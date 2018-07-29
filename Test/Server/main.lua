lovernetlib = require('lovernet')
lovernet = lovernetlib.new{type=lovernetlib.mode.server}

lovernet:addOp('g') -- (g)etMessages .. use single character to reduce bandwidth
lovernet:addValidateOnServer('g','number')
lovernet:addProcessOnServer('g',function(self,peer,arg,storage)
  storage.chat = storage.chat or {}
  local ret = {}
  for _,line in pairs(storage.chat) do
    if line.index > arg then
      table.insert(ret,{i=line.index,t=line.text})
    end
  end
  return ret
end)

lovernet:addOp('s') -- (s)endMessage .. use single character to reduce bandwidth
lovernet:addValidateOnServer('s',{t='string'})
lovernet:addProcessOnServer('s',function(self,peer,arg,storage)
  storage.chat = storage.chat or {}
  storage.current_index = (storage.current_index or 0) + 1
  table.insert(storage.chat,{index=storage.current_index,text=arg.t})
end)

function love.update(dt)
  lovernet:update(dt)
end