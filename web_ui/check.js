function WebUICheck(checkMsg) {
  return {
    uniqueId: uniqueId,
    contextualName: contextualName,
    status: status,
    isOk: isOk,
    isChanging: isChanging,
    isDisabled: isDisabled
  };

  function uniqueId() {
    return checkMsg.check.id;
  }

  function name() {
    return checkMsg.check.name;
  }

  function primaryContextName() {
    return checkMsg.check.primary_context_name;
  }

  function secondaryContextName() {
    return checkMsg.check.secondary_context_name;
  }

  function contextualName() {
    if (primaryContextName() && secondaryContextName()) {
      if (primaryContextName() != secondaryContextName()) {
        return [
          primaryContextName(),
          secondaryContextName(),
          name()
        ].join(" > ");
      }
    }
    if (primaryContextName()) {
      return [primaryContextName(), name()].join(" > ");
    }
    return name();
  }

  function status() {
    return checkMsg.check.status.toLowerCase();
  }

  function isOk() {
    return status() == "ok";
  }

  function isChanging() {
    return checkMsg.check.changing;
  }

  function isDisabled() {
    return checkMsg.check.disabled;
  }
}
