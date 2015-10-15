var encodeTable = function(t){
  if (typeof t === 'object' || typeof t === 'array'){
    for(k in t){
      if (typeof t[k] === 'object' || typeof t[k] === 'array'){
        t[btoa(k.toString())] =  t[k];
        delete t[k];
        encodeTable(t[btoa(k.toString())]);
      }else{
        t[btoa(k.toString())] =  btoa(t[k].toString());
        delete t[k];
      }
    }
  }
}

var decodeTable = function(t){
  if (typeof t === 'object' || typeof t === 'array'){
    for(k in t){
      if (typeof t[k] === 'object' || typeof t[k] === 'array'){
        t[atob(k.toString())] =  t[k];
        delete t[k];
        decodeTable(t[atob(k.toString())]);
      }else{
        t[atob(k.toString())] =  atob(t[k].toString());
        delete t[k];
      }
    }
  }
}



var Zed_WS = function(self){
  self.listener = {};

  var ws = new WebSocket("ws://" + self.host + ":" + (self.port + 1) + "/");

  ws.onmessage = function (evt)
  {
    var msg = evt.data;
    var data = JSON.parse(msg);
    decodeTable(data);
    if(self.listener[data.packet]){
      self.listener[data.packet](data.data);
    }
  };

  ws.onopen = function()  {
    if(self.listener["connect"]){
      self.listener["connect"]()
    }
  };

  ws.onclose = function(){
    if(self.listener["disconnect"]){
      self.listener["disconnect"]()
    }
  };

  self.send = function(packet, _data){
    var data = {packet: packet, data: _data};
    encodeTable(data);
    ws.send(JSON.stringify(data));
  };

  self.on = function(packet, cb){
    self.listener[packet] = cb;
  };

  window.onbeforeunload = function(e) {
    var data = {packet: "disconnect", data: {}};
    encodeTable(data);
    ws.send(JSON.stringify(data));
  };

  return self;
}


function LuvSocks(host, port){
  var self = this;
  self.host = host;
  self.port = port;
  if ("WebSocket" in window)
    return Zed_WS(self);
  else 
    return false;
}
