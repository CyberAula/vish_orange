var Vish = Vish || {};

//tooltip function
document.addEventListener("DOMContentLoaded", function(){
  $("[rel=tooltip]").tooltip({ placement: 'bottom', container:'body'});


  //for the copy to clipboard funcionality of the contest resources
  var clipboard = new Clipboard('#button_copy_clipboard');

});

$(document).ready(function(){
    $('textarea').autosize();

});


var submitRegistrationInvisibleRecaptchaForm = function () {
  document.getElementById("new_user_devise_form").submit();
};

var submitReportSpamInvisibleRecaptchaForm = function () {
  document.getElementById("spam_report_form").submit();
};
