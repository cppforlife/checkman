// require "check.js"

function WebUICheckCollection(domId) {
  var _presentedChecksCount = 0;

  return {
    show: show,
    hide: hide,
    update: update,
    presentedChecksCount: presentedChecksCount,
  };

  function show(check) {
    if (check.isDisabled()) return;

    var checksEl = document.getElementById(domId);
    var checkDom = _checkDom(check);

    if (check.isOk()) {
      checksEl.innerHTML += checkDom;
    } else {
      checksEl.innerHTML = checkDom + checksEl.innerHTML;
    }

    _presentedChecksCount += 1;
  }

  function hide(check) {
    var checkEl = document.getElementById(_checkDomId(check));
    if (checkEl) {
      checkEl.remove();
      _presentedChecksCount -= 1;
    }
  }

  function update(check) {
    hide(check);
    show(check);
  }

  function presentedChecksCount() {
    return _presentedChecksCount;
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
