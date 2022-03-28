$(window).scroll(function(){
var sh = $(window).scrollTop();
	if(sh > 410){
    $(".navbar-transparent").css({
			"background-color": "#000",
			"box-shadow": "none"
		});
    $(".navbar-transparent #brand a").css("color", "#fff");
	}
  if(sh < 410){
		$(".navbar-transparent").css({
			"background-color": "#000",
			"box-shadow": "none"
		});
    $(".navbar-transparent #brand a").css("color", "#fff");
	}
});
