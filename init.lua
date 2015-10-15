local WebSocket = require("websocket")
local json = require("json")
local table = require("table")
local md5 = require("md5")
local os = require("os")
local math = require("math")

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
	:on("connect", function(sock)
		local client = {}
		client.socket = sock
		client.listener = {}
		client.ip = client.socket:address().ip
		client.uid = md5.hex(client.ip .. tostring(os.time()) .. tostring(math.random()))
		client.socket.client = client

		client.send = function(self, key, data)
			if type(data) == "table" then
				data = base64.encodeTable({packet = key, data = data})
				client.socket:send(json.encode(data))
			end
		end

		client.on = function(self, event, cb)
			self.listener[event] = cb
		end

		client.call = function(self, event, ...)
			if type(self.listener[event]) == "function" then
				self.listener[event](...)
			end
		end

		t.clients[client.uid] = client

		t:call("connect", client)
	end)
	:on("disconnect", function(sock)
		sock.client:call("disconnect")
		t:call("disconnect", sock.client)
		t.clients[sock.client.uid] = nil
		sock.client.socket = nil
		sock.client = nil
	end)
	:on("timeout", function(sock)
		sock.client:call("disconnect")
		t:call("disconnect", sock.client)
		t.clients[sock.client.uid] = nil
		sock.client.socket = nil
		sock.client = nil
	end)
	:on("data", function(sock, message)
		if message and #message > 3 then
			local data = base64.decodeTable(json:decode(message))
			if data.packet then
				sock.client:call(data.packet, data.data)
				t:call(data.packet, sock.client, data.data)
			end
		end
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


