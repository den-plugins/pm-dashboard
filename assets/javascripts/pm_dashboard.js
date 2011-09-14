function handleSelect(elm, project, tab) {
  var root = location.protocol + '//' + location.host;
  var risk_page = "/pm_dashboards?&tab=" + tab + "&q=" + elm.value;
  var x = window.open('', "_blank");
  x.location = root + risk_page;
}

j=jQuery.noConflict();

var fields = 0;

function setFieldsCount(c) { fields = c; }

function addToFromFields(id) {
  fields += 1;
  jQuery("#" + id).clone(true)
    .attr('id', id + '_' + fields).insertAfter("#"+ id);
  
  jQuery(".close").click(function() {
    fields = 0;
  });
}
