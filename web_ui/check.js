function WebUICheck(checkMsg) {
  return {
    uniqueId: uniqueId,
    name: name,
    status: status,
    isOk: isOk,
    isChanging: isChanging
  };

  function uniqueId() {
    return checkMsg.check_id;
  }

  function name() {
    return checkMsg.check_name;
  }

  function status() {
    return checkMsg.check_text.toLowerCase();
  }

  function isOk() {
    return status() == "ok";
  }

  function isChanging() {
    return checkMsg.check_changing;
  }
}
