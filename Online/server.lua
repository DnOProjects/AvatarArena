lovernetlib = require('Online/lovernet')
server = lovernetlib.new{type=lovernetlib.mode.server}

function server.load()
	
	server:addOp('q') --query (send gameState to client)
	server:addOp('p') --point (recieve keyPresses)
	
	server:addProcessOnServer('q',function(self,peer,arg,storage)
		return storage:newImageData():getString()
	end)

	server:addValidateOnServer('p',{key='string'})

	server:addProcessOnServer('p',function(self,peer,arg,storage)
	  	user = self:getUser(peer)
	  	input.keyInput(arg.key)
	end)

end
