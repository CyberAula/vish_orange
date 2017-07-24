$(window).scroll(function(){
var sh = $(window).scrollTop();
	if(sh > 410){
    $("#navbar-home").css({
			"background-color": "#fff",
			"box-shadow": "0 0 8px 0 rgba(0,0,0,0.2)"
		});
    $("#brand a").css("color", "#333");
	}
  if(sh < 410){
		$("#navbar-home").css({
			"background-color": "transparent",
			"box-shadow": "none"
		});
    $("#brand a").css("color", "#fff");
	}
});
