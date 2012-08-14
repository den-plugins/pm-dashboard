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

jQuery('#resource_members_content table.list tbody tr').live('mouseover', function(){
  var row = jQuery(this).closest('tr').prevAll().length;
  jQuery("table.list > tbody").find("tr:eq("+row+")").addClass("highlight");
}).live('mouseout', function(){
  var row = jQuery(this).closest('tr').prevAll().length;
  jQuery("table.list > tbody").find("tr:eq("+row+")").removeClass("highlight");
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

function show_allocations(id) {
  jQuery('#allocation_edit_' + id).hide();
  jQuery('#allocation_add_' + id).hide();
  jQuery('#allocation_show_' + id).show();
  jQuery('#show_actions_' + id).show();
  jQuery('#edit_actions_' + id).hide();
}

function add_allocations(id) {
  jQuery('#allocation_add_' + id).show();
  jQuery('#show_actions_' + id).hide();
  jQuery('#edit_actions_' + id).show();
}

function show_ajax_popup() {
  jQuery('#ajax-indicator').show().attr('style', 'z-index: 9999;');
}

function hide_ajax_popup() {
  jQuery('#ajax-indicator').attr('style', 'z-index: 100;').hide();
}

function validatedatesinput(start_date, versionType, formAction){
  if((versionType == 0 || versionType == 2) && formAction == "add") {
    jQuery("#version_started_date").attr("readonly", "readonly");
    jQuery("#version_original_end_date").attr("readonly", "readonly");
    jQuery("#version_effective_date").attr("readonly", "readonly");
    jQuery("#version_started_date").val(jQuery("#version_effective_date").val());
    jQuery("#version_started_date_trigger").hide();
    jQuery("#version_original_end_date_trigger").hide();
    jQuery("#version_effective_date_trigger").hide();
  }else{
    jQuery("#version_started_date").removeAttr("readonly");
    jQuery("#version_original_end_date").removeAttr("readonly");
    jQuery("#version_effective_date").removeAttr("readonly");
    jQuery("#version_started_date").val(start_date);
    jQuery("#version_started_date_trigger").show();
    jQuery("#version_original_end_date_trigger").show();
    jQuery("#version_effective_date_trigger").show();
    if(jQuery("#version_started_date").attr('value') == ""){
       jQuery("#version_started_date").val(jQuery("#version_original_start_date").val());
    }
    if(jQuery("#version_effective_date").attr('value') == "") {
       jQuery("#version_effective_date").val(jQuery("#version_original_end_date").val());
    }
  }
}

function validateStartDatesOnchange(versionType){
  if(versionType == 0 || versionType == 2){
    jQuery("#version_original_end_date").val(jQuery("#version_original_start_date").val());
    jQuery("#version_started_date").val(jQuery("#version_original_start_date").val());
    jQuery("#version_effective_date").val(jQuery("#version_original_start_date").val());
  }
  if(versionType == 1){
    jQuery("#version_started_date").val(jQuery("#version_original_start_date").val());
  }
}

function validateEndDatesOnChange(versionType){
  if(versionType == 1){
    jQuery("#version_effective_date").val(jQuery("#version_original_end_date").val());
  }
}

function validatedatesonchange(versionType){
  if(versionType == 0 || versionType == 2){
    jQuery("#version_started_date").val(jQuery("#version_effective_date").val());
  }
}

function toggle_allocation_btn(){
  btn = jQuery("#btn_allocate_selected");
  (jQuery("input:checked").length > 0)? btn.show() : btn.hide();
}

function toggle_resources_selection(){
  btn = jQuery("#btn_toggle_resource_selection");
  (btn.hasClass("allChecked"))? btn.removeClass("allChecked") : btn.addClass("allChecked");
  jQuery("INPUT[type='checkbox']").attr('checked', btn.hasClass("allChecked"));
  toggle_allocation_btn();
}

// instead of on the fly computation, base it on what is displayed
function cost_color_code_for_fixed() {
  var budget = parseFloat(jQuery("#pm_dashboard_financial td#budget_amount").text().replace(',', ''));
  var forecast = parseFloat(jQuery("#pm_dashboard_financial td#forecast_amount").text().replace(',', ''));
  var actual = parseFloat(jQuery("#pm_dashboard_financial td#actual_amount").text().replace(',', ''));
  
  var cost_label = jQuery(".value.cost_color");
  var cost_color = jQuery(".cost_color");
  
  if (actual > budget) {
    cost_label.text("Red Flag");
    cost_color.removeClass("yellow green").addClass("red");
  } else if (forecast > budget) {
    cost_label.text("Warning");
    cost_color.removeClass("red green").addClass("yellow");
  } else {
    cost_label.text("Good");
    cost_color.removeClass("yellow red").addClass("green");
  }
}

function cost_color_code_for_tm() {
  var percentage = parseFloat(jQuery("#pm_dashboard_utilization td#percentage").text().replace('%', '').replace(',',''));
  
  var cost_label = jQuery(".value.cost_color");
  var cost_color = jQuery(".cost_color");
  
  if (percentage >= 85) {
    cost_label.text("Good");
    cost_color.removeClass("yellow red").addClass("green");
  } else if (percentage >= 80 && percentage < 85) {
    cost_label.text("Warning");
    cost_color.removeClass("red green").addClass("yellow");
  } else if (percentage >= 0 && percentage < 80) {
    cost_label.text("Red Flag");
    cost_color.removeClass("yellow green").addClass("red");
  }
}

/* Retrospective Note Feature */

jQuery("span#nextp").live("click", function(){
  var current = jQuery("span#current");
  var me = jQuery(this);
  me.attr("id", "current");
  me.addClass("selected");
  jQuery("."+me.attr("rel")).removeClass("hidden")

  current.attr("id", "nextp")
  current.removeClass("selected")
  jQuery("."+current.attr("rel")).addClass("hidden")
});

jQuery("#content_version_id").live("change", function(){
  var option = jQuery(this).children("option:selected"),
      new_selected = jQuery(this).parent().children(".iter_"+option.val()),
      old_selected = jQuery(this).parent().children(".selected");
  
  new_selected.addClass("selected").removeClass("hidden");
  old_selected.removeClass("selected").addClass("hidden");
});

jQuery("#submit_proj").live("click", function(){
  var url = "/notes/";
  var id = jQuery("#id_proj"),
      text = jQuery("#text_proj"),
      proj_id = jQuery("#proj_id");

  if(id.val())
    url += "update";
  else
    url += "create";
  
  jQuery('#ajax-indicator').show();
  jQuery.ajax({
    type: 'post',
    url: url,
    data: {'id': id.val(), 'text': text.val(), 'project_id': proj_id.val(), 'type': 'project'},
    error: function(data) {
      console.log(data);
    },
    success: function() {
      jQuery('#ajax-indicator').hide();
      id.val("");
      text.val("");
    }
  });
});

