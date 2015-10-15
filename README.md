# LuvSocks
Socket.io inspired, lightweight, event driven WebSocket library providing high level APIs for both, server and client. Requires Luvit.io.

# Installation
LuvSocks requires [lit](https://github.com/luvit/lit)
> lit install b42nk/luvsocks

Alternatively you can use LuvSocks in your lit project by defining it as a dependency.
> b42nk/luvsocks

In the frontend just use this to include LuvSocks
```html
<script src="http://raw.githubusercontent.com/b42nk/LuvSocks/master/js/luvsocks.js"></script>
```

#Usage
Server:
```lua
local LuvSocks = require("LuvSocks")

local server = LuvSocks.new():listen(1337)
print("LuvSocks server running on port 1337")


server:on("connect", function(client)
	client:on("pong", function(data)
		print("Pong received:", data)
	end)

	client:send("ping", "Hello there!")
	print("Ping sent: Hello there!")
end)
```

Client:
```html
<head>
	<script src="http://raw.githubusercontent.com/b42nk/LuvSocks/master/js/luvsocks.js"></script>
</head>
<body>
	Open the console!
	<script>
		var socket;
		function connect(){
			socket = new LuvSocks("127.0.0.1", 1337);

			socket.on("connect", function(){
				console.log("Connected!");
			});

			// Reconnect on disconnect.
			socket.on("disconnect", function(){
				connect();
			});

			socket.on("ping", function(data){
				console.log("Ping received: " + data);

				socket.send("pong", "How are you?"); // send supports tables, strings and numbers on both, server and client.

				console.log("Pong sent: How are you?");
			});
		}
		connect();
	</script>
</body>
```