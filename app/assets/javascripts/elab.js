$(document).ready(function() {
console.log('click')

//-------- INITIAL SCROLL -----------

	var scroll_arrow = $('.scroll_arrow');
	var scroll_part = $('.main-elab-content');
	var scroll_view = $('.elab-apps');

	var scroll = function() {
  	//scroll_part.scrollTo(scroll_view);
  	scroll_part.animate({scrollTop: scroll_view.offset().top}, 500);
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
		console.log('click')
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

	var apps = SAMPLE;
	












});
