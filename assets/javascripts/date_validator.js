function checkDateField(ele) {
  var patt = /^(19|20)\d\d[-](0[1-9]|1[012])[-](0[1-9]|[12][0-9]|3[01])$/;
  var stringDate = ele.val();
  if (patt.test(stringDate)){
    var parts = stringDate.split('-');
    try {var d = jQuery.calendars.newDate(parts[0], parts[1], parts[2]);} catch(err){return false;}
    if (d != undefined){return true;} else{return false;}
  }else{
    return false;
  }
}

function validateDate(input) {
  var not = jQuery("#"+input.id+"_notice");
  var ele = jQuery(input);
  var form = ele.closest('form');
  var submit = form.find('input:submit');
  if (checkDateField(ele)) {
    submit.show();
    ele.removeClass("wrong");
    not.empty();
  } else {
    submit.hide();
    ele.addClass('wrong');
    not.html("not valid");
    not.css({left: ele.position().left, top: (ele.position().top - 16) + 'px'});
  }
}
