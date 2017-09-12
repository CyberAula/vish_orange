$(window).scroll(function(){
   if ($(this).scrollTop() > 100) {
      $('.scrollup').fadeIn();
   } else {
      $('.scrollup').fadeOut();
   }
  });
  $('.scrollup, .spread').click(function(){
    $("html, body").animate({ scrollTop: 0 }, 600);
    return false;
  });
