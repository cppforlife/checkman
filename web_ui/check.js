function WebUICheck(checkMsg) {
  return {
    uniqueId: uniqueId,
    status: status,
    isOk: isOk,
    isChanging: isChanging,
    isDisabled: isDisabled,
    contextualName: contextualName,
    matchesFilter: matchesFilter
  };

  function uniqueId() { return checkMsg.check.id; }

  function name()                 { return checkMsg.check.name; }
  function primaryContextName()   { return checkMsg.check.primary_context_name; }
  function secondaryContextName() { return checkMsg.check.secondary_context_name; }

  function status()     { return checkMsg.check.status.toLowerCase(); }
  function isOk()       { return status() == "ok"; }
  function isChanging() { return checkMsg.check.changing; }
  function isDisabled() { return checkMsg.check.disabled; }

  function contextualName() {
    var primary   = primaryContextName();
    var secondary = secondaryContextName();
    var result    = [];

    if (primary) {
      result.push(primary);
    }
    // Include secondary name if it does not 
    // match primary to avoid repetition
    if (secondary && primary != secondary) {
      result.push(secondary);
    }
    result.push(name());

    return result.join(" > ");
  }

  // Determines if check matches filter in different formats:
  // 'primary', 'primary/secondary', 'primary/secondary/name'
  function matchesFilter(filter) {
    var subFilters = filter.split(",");
    for (var i in subFilters) {
      var p = subFilters[i].split("/");
      var matchesPrimary   = p[0] == "*" || p[0] == primaryContextName();
      var matchesSecondary = p[1] == "*" || p[1] == secondaryContextName();
      var matchesName      = p[2] == "*" || p[2] == name();

      if (p.length == 1) {
        if (matchesPrimary) return true;
      } else if (p.length == 2) {
        if (matchesPrimary && matchesSecondary) return true;
      } else if (p.length == 3) {
        if (matchesPrimary && matchesSecondary && matchesName) true;
      }
    }
    return false;
  }
}
