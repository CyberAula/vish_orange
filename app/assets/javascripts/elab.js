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





//-------- APPS JSON -----------

	var SAMPLE = [
  {
  	name:"fake detector news", 
  	app: "fake detector",
  	class: "fakedetector",
  	type: "news", 
  	category: "fake",
  	definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.",
  	dificulty: "easy",
  	url: "#"
  },
   {
  	name:"wordition internet", 
  	app: "wordition",
  	class: "wordition",
  	type: "internet", 
  	category: "definitions", 
  	definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.",
  	dificulty: "easy",
  	url: "#"
  },
  {
  	name:"pass check 1", 
  	app: "pass check",
  	class: "passcheck",
  	type: "1", 
  	category: "security", 
  	definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.",
  	dificulty: "easy",
  	url: "#"
  },
  {
  	name:"fake detector health", 
  	app: "fake detector",
  	class: "fakedetector",
  	type: "health", 
  	category: "fake", 
  	definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.",
  	dificulty: "easy",
  	url: "#"
  },
  {
  	name:"pass check 2", 
  	app: "pass check",
  	class: "passcheck",
  	type: "2", 
  	category: "security",
  	definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.", 
  	dificulty: "easy",
  	url: "#"
  },
  {
  	name:"quiz generator internet", 
  	app: "quiz generator",
  	class: "quizgenerator",
  	type: "internet", 
  	category: "quiz",
  	definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.", 
  	dificulty: "easy",
  	url: "#"
  },
  {
  	name:"fake detector phishing", 
  	app: "fake detector",
  	class: "fakedetector",
  	type: "phishing", 
  	category: "fake",
  	definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.", 
  	dificulty: "easy",
  	url: "#"
  },
   {
  	name:"pass check 3", 
  	app: "pass check",
  	class: "passcheck",
  	type: "3", 
  	category: "security", 
  	definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.",
  	dificulty: "easy",
  	url: "#"
  },
  {
  	name:"quiz generator tic", 
  	app: "quiz generator",
  	class: "quizgenerator",
  	type: "tic", 
  	category: "quiz", 
  	definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.",
  	dificulty: "easy",
  	url: "#"
  },
  {
  	name:"wordition tic", 
  	app: "wordition",
  	class: "wordition",
  	type: "tic", 
  	category: "definitions",
  	definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.", 
  	dificulty: "easy",
  	url: "#"
  }
	];

    var SAMPLE_LARGE = [
  {
    name:"fake detector news", 
    app: "fake detector",
    class: "fakedetector",
    type: "news", 
    category: "fake",
    definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.",
    dificulty: "easy",
    url: "#"
  },
   {
    name:"wordition internet", 
    app: "wordition",
    class: "wordition",
    type: "internet", 
    category: "definitions", 
    definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.",
    dificulty: "easy",
    url: "#"
  },
  {
    name:"pass check 1", 
    app: "pass check",
    class: "passcheck",
    type: "1", 
    category: "security", 
    definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.",
    dificulty: "easy",
    url: "#"
  },
  {
    name:"fake detector health", 
    app: "fake detector",
    class: "fakedetector",
    type: "health", 
    category: "fake", 
    definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.",
    dificulty: "easy",
    url: "#"
  },
  {
    name:"pass check 2", 
    app: "pass check",
    class: "passcheck",
    type: "2", 
    category: "security",
    definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.", 
    dificulty: "easy",
    url: "#"
  },
  {
    name:"quiz generator internet", 
    app: "quiz generator",
    class: "quizgenerator",
    type: "internet", 
    category: "quiz",
    definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.", 
    dificulty: "easy",
    url: "#"
  },
  {
    name:"fake detector phishing", 
    app: "fake detector",
    class: "fakedetector",
    type: "phishing", 
    category: "fake",
    definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.", 
    dificulty: "easy",
    url: "#"
  },
   {
    name:"pass check 3", 
    app: "pass check",
    class: "passcheck",
    type: "3", 
    category: "security", 
    definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.",
    dificulty: "easy",
    url: "#"
  },
  {
    name:"quiz generator tic", 
    app: "quiz generator",
    class: "quizgenerator",
    type: "tic", 
    category: "quiz", 
    definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.",
    dificulty: "easy",
    url: "#"
  },
  {
    name:"wordition tic", 
    app: "wordition",
    class: "wordition",
    type: "tic", 
    category: "definitions",
    definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.", 
    dificulty: "easy",
    url: "#"
  },
  {
    name:"pass check 3", 
    app: "pass check",
    class: "passcheck",
    type: "3", 
    category: "security", 
    definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.",
    dificulty: "easy",
    url: "#"
  },
  {
    name:"quiz generator tic", 
    app: "quiz generator",
    class: "quizgenerator",
    type: "tic", 
    category: "quiz", 
    definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.",
    dificulty: "easy",
    url: "#"
  },
  {
    name:"wordition tic", 
    app: "wordition",
    class: "wordition",
    type: "tic", 
    category: "definitions",
    definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.", 
    dificulty: "easy",
    url: "#"
  }

  ];

	var SAMPLE_ALL = [
  {
  	name:"fake detector news", 
  	app: "fake detector",
  	class: "fakedetector",
  	type: "news", 
  	category: "fake",
  	definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.",
  	dificulty: "easy",
  	url: "#"
  },
  {
  	name:"fake detector phishing", 
  	app: "fake detector",
  	class: "fakedetector",
  	type: "phishing", 
  	category: "fake",
  	definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.", 
  	dificulty: "easy",
  	url: "#"
  },
  {
  	name:"fake detector health", 
  	app: "fake detector",
  	class: "fakedetector",
  	type: "health", 
  	category: "fake",
  	definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.", 
  	dificulty: "easy",
  	url: "#"
  },
  {
  	name:"pass check 1", 
  	app: "pass check",
  	class: "passcheck",
  	type: "1", 
  	category: "security",
  	definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.", 
  	dificulty: "easy",
  	url: "#"
  },
  {
  	name:"pass check 2", 
  	app: "pass check",
  	class: "passcheck",
  	type: "2", 
  	category: "security",
  	definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.", 
  	dificulty: "easy",
  	url: "#"
  },
  {
  	name:"pass check 3", 
  	app: "pass check",
  	class: "passcheck",
  	type: "3", 
  	category: "security",
  	definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.", 
  	dificulty: "easy",
  	url: "#"
  },
  {
  	name:"quiz generator internet", 
  	app: "quiz generator",
  	class: "quizgenerator",
  	type: "internet", 
  	category: "quiz", 
  	definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.",
  	dificulty: "easy",
  	url: "#"
  },
  {
  	name:"quiz generator tic", 
  	app: "quiz generator",
  	class: "quizgenerator",
  	type: "tic", 
  	category: "quiz",
  	definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.", 
  	dificulty: "easy",
  	url: "#"
  },
  {
  	name:"wordition internet", 
  	app: "wordition",
  	class: "wordition",
  	type: "internet", 
  	category: "definitions",
  	definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.", 
  	dificulty: "easy",
  	url: "#"
  },
  {
  	name:"wordition tic", 
  	app: "wordition",
  	class: "wordition",
  	type: "tic", 
  	category: "definitions",
  	definition: "lorem fistrum diodeno pecador me cago en tus muelas se calle ustée papaar papaar ese que llega papaar papaar te voy a borrar el cerito. ahorarr a gramenawer sexuarl a peich pupita.", 
  	dificulty: "easy",
  	url: "#"
  }

	];


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
      app += "<div class='app_text'>";
      app += "<p class='type'>" + apps[i].type + "</p>";
      app += "<div class='name'>";
      app += "<a class='app_go' href='" + apps[i].url + "'>";
      //app += "<p class='name1'>" + apps[i].app.split(" ")[0] + "</p>";
      //app += "<p class='name2'>" + apps[i].app.split(" ")[1] + "</p>";
      app += "<p class='name1'>" + name1 + "</p>";
      app += "<p class='name2'>" + name2 + "</p>";
      app += "</a>";
      app += "<div class='def_arrow'><span class='icon-arrow_down'></span></div>";
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
      console.log($(e).innerWidth())

      $(e).css({
        height: $(e).outerWidth() + 'px'
        });
      });
    //$('.elab-apps').isotope('layout')
  };

  $(window).on('load resize' , () => {
     setTimeout(blocksFn,301);
  });



//-----------------------------


// quick search regex
var qsRegex;
var buttonFilter;
var timevalue;

// init Isotope
var $grid = $('.elab-apps').isotope({
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
    var blocks = $('.icon-arrow_down');
    var whosBig = null;

    blocks.each((i, e) => {
      $(e).on('click', (ev) => {
        var parent = $(ev.target).parents(".app-item");
        if (parent.is(whosBig)) {
          $(".app").removeClass('.no-hover');
          parent.removeClass('big');
          whosBig = null;
        } else {
          if (whosBig) {
            $(".app").removeClass('.no-hover');
            whosBig.removeClass('big');
          }
          $(".app").addClass('.no-hover');
          parent.addClass('big');
          whosBig = parent;
        }
        setTimeout(blocksFn,301);
        setTimeout(()=>{$grid.isotope()},501);

        
      });
      
    });
    
  };

  $(window).on('load' , () => {
    $grid.isotope();
    growBlock();
  });



});
