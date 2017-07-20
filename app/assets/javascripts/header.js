
$( window ).scroll(function() {
  var sh = $(window).scrollTop();
	if (sh > 410) {
    $("#navbar-home").css("background-color", "white");
	}
  if (sh < 410) {
		$("#navbar-home").css("background-color", "transparent");
	}
});
