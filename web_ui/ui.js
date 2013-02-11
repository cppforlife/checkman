// require "connection.js"
// require "checks.js"
// require "check.js"

function WebUI(domId, connectionUrl) {
  var checks = WebUICheckCollection(domId);

  function checkCallback(callback) {
    return function(msg) {
      callback(WebUICheck(msg));
    };
  }

  var connection = WebUIConnection(connectionUrl, {
    "check.show": checkCallback(checks.show),
    "check.hide": checkCallback(checks.hide),
    "check.update": checkCallback(checks.update)
  });

  return {};
}
