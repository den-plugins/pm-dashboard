function handleSelect(elm, project) {
  var root = location.protocol + '//' + location.host;
  var risk_page = "/pm_dashboards?project_id=" + project + "&tab=risks" + "&risk=" + elm.value;
  var x = window.open('', "_blank");
  x.location = root + risk_page;
}
