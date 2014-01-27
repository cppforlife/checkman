function WebUIHeartBeat(domId, callbacks) {
  var _lastReceivedAt = null;
  var _timeoutError = null;
  var _died = false;

  // Schedule one initially in case
  // we never receive a single beat.
  _scheduleTimeoutError();

  return {
    beat: beat
  };

  function beat(msg) {
    _lastReceivedAt = new Date();
    _updateStats(msg);
    _scheduleTimeoutError();
    if (_died) _onLive();
  }

  function _scheduleTimeoutError() {
    if (_timeoutError) clearTimeout(_timeoutError);
    _timeoutError = setTimeout(_onDead, 10 * 1000);
  }

  function _onLive() {
    console.log("WebUIHeartBeat - onLive");
    _died = false;
    if (callbacks.live) callbacks.live();
  }

  function _onDead() {
    console.log("WebUIHeartBeat - onDead");
    _died = true;
    if (callbacks.dead) callbacks.dead();
  }

  function _updateStats(msg) {
    var text =
      msg.total_checks_count
      + " total checks</br>"
      + msg.disabled_checks_count
      + " disabled checks</br>@ "
      + _formattedLastReceivedAt();
    document.getElementById(domId).innerHTML = text;
  }

  function _formattedLastReceivedAt() {
    if (_lastReceivedAt) {
      return _lastReceivedAt.toLocaleTimeString();
    } else {
      return "?";
    }
  }
}

function WebUIHeartBeatOverlay(domId) {
  return {
    show: show,
    hide: hide
  };

  function show() {
    var el = document.getElementById(domId);
    el.setAttribute("data-show", "true");
  }

  function hide() {
    var el = document.getElementById(domId);
    el.removeAttribute("data-show");
  }
}

function WebUILastUpdated(domId, getSecs) {
  var timer = setInterval(function() {
    var secs = getSecs();
    var secsText = (secs ? secs : "?") + "s ago";
    document.getElementById(domId).innerHTML = secsText;
  }, 2000);

  return {};
}
