$(document).ready(function(){
  $("#facebook_btn").click(function(){
    if($(this).hasClass("clicked")){
      $(this).removeClass("clicked");
      $(".drop_right").hide();
    } else {
      $(".social_btn").removeClass("clicked");
      $(this).addClass("clicked");
      $(".drop_right").hide();
      $("#drop_right_facebook").show();
    }
  });
  //twitter
  $("#twitter_btn").click(function(){
    if($(this).hasClass("clicked")){
      $(this).removeClass("clicked");
      $(".drop_right").hide();
    } else {
      $(".social_btn").removeClass("clicked");
      $(this).addClass("clicked");
      $(".drop_right").hide();
      $("#drop_right_twitter").show();
    }
  });
  //youtube
  $("#youtube_btn").click(function(){
    if($(this).hasClass("clicked")){
      $(this).removeClass("clicked");
      $(".drop_right").hide();
    } else {
      $(".social_btn").removeClass("clicked");
      $(this).addClass("clicked");
      $(".drop_right").hide();
      $("#drop_right_youtube").show();
    }
  });

  //News
  $("#news_btn").click(function(){
    if($(this).hasClass("clicked")){
      $(this).removeClass("clicked");
      $(".drop_right").hide();
    } else {
      $(".social_btn").removeClass("clicked");
      $(this).addClass("clicked");
      $(".drop_right").hide();
      $("#drop_right_news").show();
    }
  });


  //close button
  $(".close_social_btn").click(function(){
      close_drop_right();
  });

  var close_drop_right = function(){
    $(".social_btn").removeClass("clicked");
    $(".drop_right").hide();
      $(".ytv-video-playerContainer")[0].contentWindow.postMessage('{"event":"command","func":"pauseVideo","args":""}', '*');
  }
  var controller = new YTV('YourPlayerID', {
     apiKey: "<%= Vish::Application.config.APP_CONFIG['YouTubeAPIKEY'] %>",
	   playlist: 'PL-qNzC6Q_XM5tMM04Abi8Oy-qHVovu_-0',
     accent: '#fff',
     playerTheme: 'light',
     listTheme: 'light',
     responsive: false
    });
    //code to hide drop_right panels when clicking outside
    $('html').on('click', function(e){
      //avoid closing the panels when click on social buttons or directly in the panels
      if(!$(e.target).hasClass("social_btn") && !$(e.target).parent().hasClass("social_btn") && !$(e.target).parents().hasClass("ytv-list") && !$(e.target).hasClass("close_social_btn") && $(".social_btn.clicked").length > 0){
        close_drop_right();
      }
    });

});
