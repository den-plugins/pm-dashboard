function handleSelect(elm, project, tab) {
  var root = location.protocol + '//' + location.host;
  var risk_page = "/pm_dashboards?&tab=" + tab + "&q=" + elm.value;
  var x = window.open('', "_blank");
  x.location = root + risk_page;
}

