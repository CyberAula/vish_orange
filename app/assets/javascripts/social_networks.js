$(document).ready(function(){
  $("#facebook_btn").click(function(){
    $(this).toggleClass("padding_btn")
      $("#drop_right_facebook").toggleClass("left_44");
  });
  //twitter
  $("#twitter_btn").click(function(){
    $(this).toggleClass("padding_btn")
      $("#drop_right_twitter").toggleClass("left_44");
  });
  //youtube
  $("#youtube_btn").click(function(){
    $(this).toggleClass("padding_btn")
      $("#drop_right_youtube").toggleClass("left_44");
  });

  var controller = new YTV('drop_right_youtube', {
	   playlist: 'PL-qNzC6Q_XM7ydZR4sA5lntkihNVOCuST',
     accent: '#fff',
     playerTheme: 'dark',
     listTheme: 'dark',
     responsive: false     
    });
});
