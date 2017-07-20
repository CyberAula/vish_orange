$(document).ready(function(){

	var sh = $(window).scrollHeight();

	if (sh > 400) {
		$("#navbar-home").css("background", "transparent");
	} else {
		$("#navbar-home").css("background", "white");
	}

});
