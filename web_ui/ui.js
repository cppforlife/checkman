// require "connection.js"
// require "checks.js"
// require "check.js"

function WebUILastUpdated(domId, getSecs) {
  var timer = setInterval(function() {
    var secs = getSecs();
    var secsText = (secs ? secs : "?") + "s ago";
    document.getElementById(domId).innerHTML = secsText;
  }, 2000);

  return {};
}

function WebUI(connectionUrl, domIds) {
  var checks = WebUICheckCollection(domIds.checks);

  var connection = WebUIConnection(connectionUrl, {
    "check.show": checkCallback(checks.show),
    "check.hide": checkCallback(checks.hide),
    "check.update": checkCallback(checks.update)
  });

  var lastUpdated = WebUILastUpdated(domIds.lastUpdated, function() {
    return connection.secsSinceLastMessageReceived();
  });

  return {};

  function checkCallback(callback) {
    return function(msg) {
      callback(WebUICheck(msg));
    };
  }
}
