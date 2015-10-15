local LuvSocks = require("../LuvSocks")

local server = LuvSocks.new():listen(1337)
print("LuvSocks server running on port 1337")


server:on("connect", function(client)
	client:on("pong", function(data)
		print("Pong received:", data)
		if type(data) == "table" then
			for k,v in pairs(data) do
				print("",k,v)
			end
		end
	end)

	client:send("ping")
	print("Ping sent.")
end)