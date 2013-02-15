// require "connection.js"
// require "heart_beat.js"
// require "checks.js"
// require "check.js"

function WebUI(connectionUrl, domIds) {
  var checks = WebUICheckCollection(domIds.checks);

  var heartBeat = WebUIHeartBeat(domIds.heartBeat, function() {
    return { presentedChecksCount: checks.presentedChecksCount() };
  });

  var connection = WebUIConnection(connectionUrl, {
    "check.show": checkCallback(checks.show),
    "check.hide": checkCallback(checks.hide),
    "check.update": checkCallback(checks.update),
    "heartbeat": heartBeat.beat
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
