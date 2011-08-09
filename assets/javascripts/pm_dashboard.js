function handleSelect(elm, project) {
  var root = location.protocol + '//' + location.host;
  var risk_page = "/pm_dashboards?project_id=" + project + "&tab=risks" + "&risk=" + elm.value;
  var x = window.open(root + risk_page, "_self");
  x.location();
}
