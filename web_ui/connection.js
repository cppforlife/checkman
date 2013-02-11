function WebUIConnection(url, callbacks) {
  var socket = new WebSocket(url);

  socket.onopen = function()
    { console.log("WebUIConnection - open"); };
  socket.onerror = function(error)
    { console.log("WebUIConnection - error", error); }

  socket.onmessage = function(msg) {
    var parsedMsg = JSON.parse(msg.data);
    if (parsedMsg.type && callbacks[parsedMsg.type]) {
      callbacks[parsedMsg.type](parsedMsg);
    }
  };

  return {};
}
