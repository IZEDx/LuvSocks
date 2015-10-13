local WebSocket = require("websocket")
local json = require("json")
local table = require("table")


exports.new = function(func)
	local t = {}

	t.listener = {connect = {}, data = {}, disconnect = {}, timeout = {}}
	t.clients = {}

	t.on = function(self, s, c)
		if self.listener[s] and type(self.listener[s]) == "table" and type(c) == "function" then
			table.insert(self.listener[s], c)
		end
		return self
	end

	t.call = function(self, s, ...)
	    if self.listener[s] and type(self.listener[s]) == "table" then
	    	local t = {}
	      	for k,v in pairs(self.listener[s]) do
	        	if type(v) == "function" then
	        		local r = v(...)
	        		if r then
            			table.insert(t, r)
	        		end
	        	end
	      	end
	      	return unpack(t)
	    end
	end

	t.server = WebSocket.server.new()
	:on("connect", function(client)
		client._send = client.send
		client.send = function(self, key, data)
			data = json.encode({key, data})
			client:_send(data)
		end

		t:call("connect", client)
	end)
	:on("disconnect", function(client)
		t:call("disconnect", client)
	end)
	:on("timeout", function(client)
		t:call("disconnect", client)
	end)
	:on("data", function(client, message)
		client.send = function(self, key, data)
			data = json.encode({key, data})
			client:_send(data)
		end
		local data = json:decode(message)
		local key = data[1]
		data = data[2]
		t:call(key, data)
	end)

	t.listen = function(self, ...)
		self.server:listen(...)
		return self
	end

	if type(func) == "function" then
		func(t)
	end

	return t
end


