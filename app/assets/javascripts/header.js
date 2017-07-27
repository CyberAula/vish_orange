$(window).scroll(function(){
var sh = $(window).scrollTop();
	if(sh > 410){
    $(".navbar-transparent").css({
			"background-color": "#fff",
			"box-shadow": "0 0 8px 0 rgba(0,0,0,0.2)"
		});
    $(".navbar-transparent #brand a").css("color", "#333");
	}
  if(sh < 410){
		$(".navbar-transparent").css({
			"background-color": "transparent",
			"box-shadow": "none"
		});
    $(".navbar-transparent #brand a").css("color", "#fff");
	}
});
