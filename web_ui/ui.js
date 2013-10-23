// require "connection.js"
// require "heart_beat.js"
// require "checks.js"
// require "check.js"

function WebUI(connectionUrl, checkFilter, domIds) {
  var checks = WebUICheckCollection(domIds.checks);

  var heartBeatOverlay = 
    WebUIHeartBeatOverlay(domIds.heartBeatOverlay);

  // Make sure every so often that proper number
  // of checks are presented; otherwise, alert the viewer
  var heartBeat = WebUIHeartBeat(domIds.heartBeat, {
    "live": function() { heartBeatOverlay.hide(); },
    "dead": function() { heartBeatOverlay.show(); }
  });

  // Respond to events received from Checkman app
  var connection = WebUIConnection(connectionUrl, {
    "check.show": function(msg) { checks.show(WebUICheck(msg), checkFilter); },
    "check.hide": function(msg) { checks.hide(WebUICheck(msg)); },
    "heartbeat":  heartBeat.beat
  });

  // Present heart beat information
  var lastUpdated = WebUILastUpdated(domIds.lastUpdated, function() {
    return connection.secsSinceLastMessageReceived();
  });

  return {};
}

function WebUIPageLocation(location) {
  return {
    connectionUrl: connectionUrl,
    checkFilter: checkFilter
  }

  function connectionUrl() {
    var url = "ws://" + location.host + "/check_updates";
    console.log("WebUIPageLocation - connectionUrl", url);
    return url;
  }

  function checkFilter() {
    var filter = parseQueryString()["filter"] || "*";
    console.log("WebUIPageLocation - checkFilter", filter);
    return filter;
  }

  function parseQueryString() {
    var query = location.search.substr(1); // remove '?'
    var data  = query.split("&");
    var result = {};
    for (var i=0; i<data.length; i++) {
      var item = data[i].split("=");
      result[item[0]] = item[1];
    }
    return result;
  }
}
