function handleSelect(elm, project, tab) {
  var root = location.protocol + '//' + location.host;
  var risk_page = "/pm_dashboards?&tab=" + tab + "&q=" + elm.value;
  var x = window.open('', "_blank");
  x.location = root + risk_page;
}

j=jQuery.noConflict();

jQuery('.editable').live('focus', function(){
  var id = jQuery(this).attr('id');
  //value = jQuery("#" + id + " #highlight_highlight").val();
  jQuery(this).removeClass('editable').addClass('edit-mode');
  jQuery("#" + id + " :submit").removeAttr("disabled");
});

jQuery('.edit-mode').live('blur', function(){
  var id = jQuery(this).attr('id');
  jQuery(this).removeClass('edit-mode').addClass('editable');
  jQuery("#" + id + " :submit").attr("disabled", true);
});

function edit_allocations() {
  jQuery('#allocation_edit').show();
  jQuery('#allocation_show').hide();
  jQuery('#show_actions').hide();
  jQuery('#edit_actions').show();
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
