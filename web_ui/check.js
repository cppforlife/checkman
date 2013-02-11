function WebUICheck(checkMsg) {
  return {
    uniqueId: uniqueId,
    name: name,
    status: status,
    isOk: isOk,
    isChanging: isChanging
  };

  function uniqueId() {
    return checkMsg.check.id;
  }

  function name() {
    return checkMsg.check.name;
  }

  function status() {
    return checkMsg.check.text.toLowerCase();
  }

  function isOk() {
    return status() == "ok";
  }

  function isChanging() {
    return checkMsg.check.changing;
  }
}
