function WebUIHeartBeat(domId, getLocalStats) {
  var _lastReceivedAt = null;
  var _timeoutError = null;

  // Schedule one initially
  // in case we never receive a single beat.
  scheduleTimeoutError();

  return {
    beat: beat
  };

  function beat(msg) {
    _lastReceivedAt = new Date();
    updateStats(msg);
    compareStats(msg, getLocalStats());
    scheduleTimeoutError();
  }

  function scheduleTimeoutError() {
    if (_timeoutError) {
      clearTimeout(_timeoutError);
    }
    _timeoutError = setTimeout(function() {
      showError("No heartbeat within 10 secs.");
    }, 10 * 1000);
  }

  function updateStats(msg) {
    var text = msg.total_checks_count    + " total checks</br>" +
               msg.disabled_checks_count + " disabled checks</br>" +
               "@ " + formattedLastReceivedAt();
    document.getElementById(domId).innerHTML = text;
  }

  function compareStats(msg, localStats) {
    var expectedPresentedChecksCount =
      (msg.total_checks_count - msg.disabled_checks_count);

    if (expectedPresentedChecksCount != localStats.presentedChecksCount) {
      showError("Checks are out of sync.");
    }
  }

  function showError(description) {
    alert(description);
  }

  function formattedLastReceivedAt() {
    if (_lastReceivedAt) {
      return _lastReceivedAt.toLocaleTimeString();
    } else {
      return "?";
    }
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
