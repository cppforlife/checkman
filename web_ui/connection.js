function WebUIConnection(url, callbacks) {
  var socket = new WebSocket(url);
  console.log("WebUIConnection - connecting:", url);

  socket.onopen = function()
    { console.log("WebUIConnection - open"); };
  socket.onerror = function(error)
    { console.log("WebUIConnection - error:", error); }

  var _lastMessageReceivedAt = null;

  socket.onmessage = function(msg) {
    var parsedMsg = JSON.parse(msg.data);
    if (parsedMsg.type && callbacks[parsedMsg.type]) {
      _lastMessageReceivedAt = Date.now();
      callbacks[parsedMsg.type](parsedMsg);
    } else {
      console.log("WebUIConnection - unhandled:", msg);
    }
  };

  return {
    secsSinceLastMessageReceived: secsSinceLastMessageReceived
  };

  function secsSinceLastMessageReceived() {
    if (_lastMessageReceivedAt) {
      return (Date.now() - _lastMessageReceivedAt) / 1000;
    } else {
      return null;
    }
  }
}
