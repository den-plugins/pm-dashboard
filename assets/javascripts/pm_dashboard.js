function handleSelect(elm, project, tab) {
  var root = location.protocol + '//' + location.host;
  var risk_page = "/projects/" + project + "/project_management/" + tab +"/show?id=" + elm.value;
  var x = window.open('', "_blank");
  x.location = root + risk_page;
}

j=jQuery.noConflict();

jQuery("#tab-content-resource_costs").ready(function(){
  jQuery("#undef_weeks").height(jQuery("#resource_costs").innerHeight());
});

jQuery("#tab-resource_costs").live("click", function(){
  jQuery("#undef_weeks").height(jQuery("#resource_costs").innerHeight());
});

function bulk_edit_allocations() {
  jQuery('#allocation_edit').show();
  jQuery('#allocation_show').hide();
  jQuery('#show_actions').hide();
  jQuery('#edit_actions').show();
}

function edit_allocations(id) {
  jQuery("#date_range_" + id ).hide();
  jQuery("#date_range_" + id + "_edit").show();
}

function show_allocations() {
  jQuery('#allocation_edit').hide();
  jQuery('#allocation_add').hide();
  jQuery('#allocation_show').show();
  jQuery('#show_actions').show();
  jQuery('#edit_actions').hide();
}

function add_allocations() {
  jQuery('#allocation_add').show();
  jQuery('#show_actions').hide();
  jQuery('#edit_actions').show();
}

function show_ajax_popup() {
  jQuery('#ajax-indicator').show().attr('style', 'z-index: 9999;');
}

function hide_ajax_popup() {
  jQuery('#ajax-indicator').attr('style', 'z-index: 100;').hide();
}

function validatedatesinput(start_date, versionType){
  if(versionType == 0 || versionType == 2){
    jQuery("#version_started_date").attr("readonly", "readonly");
    jQuery("#version_started_date").val(jQuery("#version_effective_date").val());
    jQuery("#version_started_date_trigger").hide();
  }else{
    jQuery("#version_started_date").removeAttr("readonly");
    jQuery("#version_started_date").val(start_date);
    jQuery("#version_started_date_trigger").show();
  }
}

function validatedatesonchange(versionType){
  if(versionType == 0 || versionType == 2){
    jQuery("#version_started_date").val(jQuery("#version_effective_date").val());
  }
}
