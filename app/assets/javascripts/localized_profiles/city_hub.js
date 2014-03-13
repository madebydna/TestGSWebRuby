GS.textSwitch = function(el, target, replace) {
  if (el.value == replace) {
      el.value = target;
  }
};

GS.uri = GS.uri || {};
GS.hubs = GS.hubs || {};
GS.util = GS.util || {};

// GS.searchBySchoolNameForm = (function() {
//   var SEARCH_PAGE_PATH = '/search/search.page';
//   var FORM_SELECTOR = '#js-findByNameForm';
//   var DEFAULT_SEARCH_FIELD_TEXT = 'School name';
//   var SEARCH_FIELD_SELECTOR = '#js-findByNameBox';

//   var init = function() {
//     var $form = jQuery(FORM_SELECTOR);
//     $form.on('click', '#js-submit', function(){
//       if(DEFAULT_SEARCH_FIELD_TEXT === $form.find(SEARCH_FIELD_SELECTOR).val()) {
//         return true;
//       }
//       return submitForm($form);
//     });
//   };

//   var submitForm = function($form) {
//     var searchString = $form.find(SEARCH_FIELD_SELECTOR).val();
//     var collectionId = $form.find('#js-collectionId').val();
//     var state = $form.find('#js-state').val();

//     var queryStringData = GS.uri.getQueryData();

//     queryStringData.q = encodeURIComponent(searchString);
//     queryStringData.collectionId = encodeURIComponent(collectionId);
//     queryStringData.state = state;

//     window.location.href = window.location.protocol + '//' + window.location.host +
//       SEARCH_PAGE_PATH +
//       GS.uri.Uri.getQueryStringFromObject(queryStringData);

//     return false;
//   };

//   return {
//     init: init
//   };
// })();

GS.util.isDeveloperWorkstation = function() {
  var hostname = window.location.hostname;
  return hostname.indexOf("localhost") > -1 ||
    hostname.indexOf("127.0.0.1") > -1 ||
    hostname.match(/^172.18.1.*/) !== null ||
    hostname.match(/^172.21.1.*/) !== null ||
    hostname.indexOf("samson.") != -1 ||
    hostname.indexOf("mitchtest.") != -1 ||
    hostname.indexOf("rcox.office.") != -1 ||
    (hostname.match(/.+office.*/) !== null && hostname.indexOf("cpickslay.office") == -1) ||
    hostname.indexOf("vpn.greatschools.org") != -1 ||
    hostname.indexOf("macbook") > -1;
};

GS.hubs.setupResponsiveCarousel = function() {
  var options = {
    fx: "carousel",
    slides: "> div",
    loader: "wait",
    speed: "1000",
    pauseOnHover: "true",
    timeout: "1000",
    easing: "linear",
    carouselVisible: '6',
    slideshow: "true",
    next: "#next",
    prev: "#prev"
  };

  function cycle(visibleCount) {
    var $slideshow = $('.cycle-slideshow');
    $slideshow.cycle($.extend(options, { carouselVisible: visibleCount }));
    $slideshow.css('margin-left', 'auto').css('margin-right', 'auto');
  }

  function initCycle() {
    var width = $(window).width();
    $('.cycle-slideshow').cycle('destroy');
    if (width <= 400) {
      cycle(1);
    } else if (width > 400 && width <= 540) {
      cycle(2);
    } else if (width > 540 && width <= 690) {
      cycle(3);
    } else if ( width > 690 && width <= 800 ) {
      cycle(4);
    } else if ( width > 800 && width <= 980 ) {
      cycle(5);
    } else {
      cycle(6);
    }
  }
  initCycle();

  var reinitTimer;
  $(window).resize(function() {
      clearTimeout(reinitTimer);
      reinitTimer = setTimeout(initCycle, 100);
  });
};


GS.hubs.clearLocalUserCookies = function() {
  // http://www.quirksmode.org/js/cookies.html
  var date = new Date();
  date.setTime(date.getTime()+(-2*24*60*60*1000));
  var expires = "; expires=" + date.toGMTString();
  var localUserCookieNames = ["hubCity", "hubState", "ishubUser" ,"choosePage", "eventsPage","enrollPage", "eduPage"];
  var isDeveloperWorkstation = GS.util.isDeveloperWorkstation();
  for(var i = 0; i < localUserCookieNames.length; i++) {
    var localUserCookie = "";
    localUserCookie = localUserCookieNames[i] + "=" + expires + "; path=/";
    if(!isDeveloperWorkstation) localUserCookie += "; domain=.greatschools.org";
    document.cookie = localUserCookie;
  }
};

jQuery(function() {
  // GS.searchBySchoolNameForm.init();
  GS.hubs.setupResponsiveCarousel();
});
