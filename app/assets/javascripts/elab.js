
var $grid;
$(document).ready(function() {
console.log('click')

//-------- INITIAL SCROLL -----------

	var scroll_arrow = $('.scroll_arrow');
	var scroll_part = $('.main-elab-content');
	var scroll_view = $('.elab-apps');
  var elab_text = $('.elab-text');
  var scroll_text = $('.scroll_text');


	var scroll = function() {
  	//scroll_part.scrollTo(scroll_view);

  	//scroll_part.animate({scrollTop: scroll_view.first().position().top - 78}, 500);

    //scroll_part.animate({scrollTop: scroll_view.offset().top - 78}, 500);

    /*scroll_part.animate(scrollTo(scroll_view), 2000);
    elab_text.css({
      position: "absolute",
      top: -110 + "vh"
    });
    scroll_view.css({
      top: 0
    });*/

    /*elab_text.css({
      height: 0 + "px",
      marginTop: 0 + "px",
      paddingTop: 0 + "px",
      opacity: 0
    });*/

    document.getElementById('elab-apps').scrollIntoView({block: 'start', behavior: 'smooth'});

	};

	scroll_arrow.on('click', scroll);


//-------- LANGUAJE MENU -----------

	var accordion = function (className) {
	  var item = $(className);
	  item.toggleClass("closed");
	  if (item.css('max-height') == '0px'){
	  	item.css('max-height', item.prop("scrollHeight") + 20 + "px");
	  } else {
	  	item.css('max-height', '0');
	  }
	};

	//////////OPEN LANGUAJE //////////

	var language_arrow = $("#lang_arrow");

	language_arrow.on("click", function() {
    $(this).toggleClass("closed");
    accordion(".other_languages");
	});


  //------------ CREATE APP DIVS -------------

  $('.alt_text').hide();

	var apps = SAMPLE;

  var main_apps = $('.elab-apps');
  var app_rows = Math.ceil(apps.length/4);

  //main_apps.css("grid-template-rows", "repeat(" + app_rows + ", 20.5vw)");

  var create_apps = function () {

    var app = "";

    for(var i = 0; i < apps.length; i++){

      var name1 = (apps[i].app.split(" ").length != 1) ? (apps[i].app.split(" ")[0]) : "";
      var name2 = (apps[i].app.split(" ").length != 1) ? (apps[i].app.split(" ")[1]) :  apps[i].app;

      //console.log(name1);
      //console.log(name2);
      //console.log(apps[i].app.split(" ")[0]);

      app += "<div class='app-item all " + apps[i].category + " " + apps[i].class + " " + apps[i].type + "'>";
      app += "<div class='app app" + i + " " + apps[i].category + " " + apps[i].class + " " + apps[i].type + "'>";
      app += "<span class='icon-cross app_cross'></span>";
      app += "<div class='app_text'>";
      app += "<p class='type'>" + apps[i].type + "</p>";
      app += "<div class='name'>";
      app += "<a class='app_go' href='" + apps[i].url + "'>";
      //app += "<p class='name1'>" + apps[i].app.split(" ")[0] + "</p>";
      //app += "<p class='name2'>" + apps[i].app.split(" ")[1] + "</p>";
      app += "<p class='name1'>" + name1 + "</p>";
      app += "<p class='name2'>" + name2 + "</p>";
      app += "</a>";
      app += "<div class='def_arrow'><span class='icon-arrow_down info_arrow'></span></div>";
      app += "</div>";
      app += "</div>";
      app += "</div>";
      app += "</div>";
    };

    main_apps.append(app);
  };

  create_apps();


  //------------ APP DIVS HEIGHT -------------

  var blocksFn = () => {
    var blocks = $('.app');
    blocks.each((i, e) => {
      var blocksparent = $(e).parents('.app-item');
      let newHeight = $(e).outerWidth();
      if (blocksparent.hasClass('big')) {
        newHeight = $(e).outerWidth() / 2 - parseFloat(blocksparent.css('margin-right')) / 2;
      } 
       $(e).css({
        height: newHeight + 'px'
        });
    });
  };

  $(window).on('load resize' , () => {
    setTimeout(()=>{
      blocksFn();
      $grid.isotope();
    },500);
    
  });



//-----------------------------


// quick search regex
var qsRegex;
var buttonFilter;
var timevalue;

// init Isotope
$grid = $('.elab-apps').isotope({
  itemSelector: '.app-item',
  //layoutMode: 'layout',
/*  layoutMode: 'fitRows',
  fitRows: {
    gutter: 40
  },*/
  filter: function() {
    var $this = $(this);
    var searchResult = qsRegex ? $this.text().match( qsRegex ) : true;
    var buttonResult = buttonFilter ? $this.is( buttonFilter ) : true;
    return searchResult && buttonResult;
  }
});

$('#filters').on( 'click', '.icon-menu', function() {
  $('.app-item').removeClass('big');
  $('.app').removeClass('no-hover');
  buttonFilter = $( this ).attr('data-filter');
  if ($(buttonFilter).length == 0) {
    $grid.isotope();
    $('.alt_text').show();
    scroll();
    timevalue = window.setTimeout(function(){
      $('.alt_text').hide();
      $(".icon-all")[0].click();
    }, 3000);
  } else {
    $grid.isotope();
clearTimeout(timevalue);
    $('.alt_text').hide();
    scroll();
  }
});

// use value of search field to filter
var $quicksearch = $('#appSearch').keyup( debounce( function() {
  qsRegex = new RegExp( $quicksearch.val(), 'gi' );
  $grid.isotope();
  scroll();
}) );


  // change is-checked class on buttons
$('.filters').each( function( i, buttonGroup ) {
  var $buttonGroup = $( buttonGroup );
  $buttonGroup.on( 'click', '.icon-menu', function() {
    $buttonGroup.find('.is-checked').removeClass('is-checked');
    $( this ).addClass('is-checked');
  });
});


// debounce so filtering doesn't happen every millisecond
function debounce( fn, threshold ) {
  var timeout;
  threshold = threshold || 100;
  return function debounced() {
    clearTimeout( timeout );
    var args = arguments;
    var _this = this;
    function delayed() {
      fn.apply( _this, args );
    }
    timeout = setTimeout( delayed, threshold );
  };
}


//----------- APP DIV BIG --------------

 var growBlock = () => {
    var arrow_app = $('.info_arrow');
    var cross_app = $('.app_cross');
    var whosBig = null;

    arrow_app.each((i, e) => {
      $(e).on('click', (ev) => {
        var parent = $(ev.target).parents(".app-item");
        var parentmin = $(ev.target).parents(".app");
        console.log(parentmin);
        if (parent.is(whosBig)) {
          parent.removeClass('big');
          $('.app').removeClass('no-hover');
          $('.info_arrow').css('pointer-events', 'auto');
          whosBig = null;
        } else {
          if (whosBig) {
            whosBig.removeClass('big');
            $('.app').removeClass('no-hover');
            $('.info_arrow').css('pointer-events', 'auto');
          }
          parent.addClass('big');
          parentmin.addClass('no-hover');
          $(e).css('pointer-events', 'none');
          whosBig = parent;
        }
        //setTimeout(blocksFn,500);
        setTimeout(()=>{$grid.isotope()},200);
      }); 
    });

<<<<<<< HEAD
    cross_app.each((i, e) => {
      $(e).on('click', (ev) => {
        $('.app-item').removeClass('big');
        $('.app').removeClass('no-hover');
        $('.info_arrow').css('pointer-events', 'auto');
        whosBig = null;
        setTimeout(()=>{$grid.isotope()},100);
      }); 
    });
=======

      });

    });

>>>>>>> 0576c2527995c5bde7ab0d74edcbc8702037dd98
  };

  $(window).on('load' , () => {
    $grid.isotope();
    growBlock();
  });



});
