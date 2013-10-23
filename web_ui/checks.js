// require "check.js"

function WebUICheckCollection(domId) {
  return {
    show: show,
    hide: hide,
  };

  // Converges UI based on check's state
  function show(check, filter) {
    hide(check);

    if (check.isDisabled()) {
      return console.log(
        "WebUICheckCollection - show: disabled check", 
        check.contextualName()
      );
    }

    if (!check.matchesFilter(filter)) {
      return console.log(
        "WebUICheckCollection - show: filtered check", 
        check.contextualName()
      );
    }

    // Build DOM element for the check
    var checksEl = document.getElementById(domId);
    var checkDom = _checkDom(check);

    // Add green checks to the end of the list
    // and keep red/undetermined checks in the begginning
    if (check.isOk()) {
      checksEl.innerHTML += checkDom;
    } else {
      checksEl.innerHTML = checkDom + checksEl.innerHTML;
    }
  }

  function hide(check) {
    var checkEl = document.getElementById(_checkDomId(check));
    if (checkEl) {
      checkEl.remove();
    }
  }

  function _checkDom(check) {
    var tpl = "<div id='$check_dom_id'>$check_content_dom</div>";
    tpl = tpl.replace("$check_dom_id", _checkDomId(check));
    tpl = tpl.replace("$check_content_dom", _checkContentDom(check));
    return tpl;
  }

  function _checkContentDom(check) {
    var tpl = "<div class='check $check_status $check_changing'>$check_name</div>";
    tpl = tpl.replace("$check_status", check.status());
    tpl = tpl.replace("$check_changing", check.isChanging() ? "changing" : "");
    tpl = tpl.replace("$check_name", check.contextualName());
    return tpl;
  }

  function _checkDomId(check) {
    return domId + "-check-" + check.uniqueId();
  }
}
