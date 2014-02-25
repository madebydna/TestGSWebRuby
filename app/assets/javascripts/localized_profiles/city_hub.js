GS.textSwitch = function(el, target, replace) {
  if (el.value == replace) {
      el.value = target;
  }
};

GS.uri = {};
GS.hubs = {};
GS.util = {};

GS.uri.getQueryData = function(queryString) {
  var data = {};
  if(queryString !== undefined) {
    queryString = queryString.substring(1);
  }
  else {
    var index = window.location.href.indexOf('?');
    if(index === -1) {
      queryString = "";
    }
    else {
      queryString = window.location.href.slice(index + 1);
    }
  }

  var hashes = queryString.split('&');
  if (queryString.length > 0 && hashes.length > 0) {
    for (var i = 0; i < hashes.length; i++) {
      var hash = hashes[i].split('=');
      var key = hash[0];
      var value = hash[1];

      // if the querystring key is already in the data hash, then the querystring had multiple key=value pairs
      // with the same key. Make the key point to an array with all the values
      if (data.hasOwnProperty(key)) {
        // if the value in the data hash is _already_ an array, just push on the value
        if (data[key] instanceof Array) {
            data[key].push(value);

            // otherwise we need to copy the existing value that's on the data hash into a new array
        } else {
            var anArray = [];
            anArray.push(data[key]);
            anArray.push(hash[1]);
            data[hash[0]] = anArray;
        }
      } else {
        data[hash[0]] = hash[1];
      }
    }
  }
  return data;
};

GS.searchBySchoolNameForm = (function() {
  var SEARCH_PAGE_PATH = '/search/search.page';
  var FORM_SELECTOR = '#jq-findByNameForm';
  var DEFAULT_SEARCH_FIELD_TEXT = 'School name';
  var SEARCH_FIELD_SELECTOR = '#js-findByNameBox';

  var init = function() {
    var $form = jQuery(FORM_SELECTOR);
    $form.on('click', '#js-submit', function(){
      if(DEFAULT_SEARCH_FIELD_TEXT === $form.find(SEARCH_FIELD_SELECTOR).val()) {
        return true;
      }
      return submitForm($form);
    });
  };

  var submitForm = function($form) {
    var searchString = $form.find(SEARCH_FIELD_SELECTOR).val();
    var collectionId = $form.find('#jq-collectionId').val();
    var state = $form.find('#jq-state').val();

    var queryStringData = GS.uri.Uri.getQueryData();

    queryStringData.q = encodeURIComponent(searchString);
    queryStringData.collectionId = encodeURIComponent(collectionId);
    queryStringData.state = state;

    window.location.href = window.location.protocol + '//' + window.location.host +
      SEARCH_PAGE_PATH +
      GS.uri.Uri.getQueryStringFromObject(queryStringData);

    return false;
  };

  return {
    init: init
  };
})();

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

  function initCycle() {
    var width = $(document).width();
    $('.cycle-slideshow').cycle('destroy');
    if (width < 400) {
      $('.cycle-slideshow').cycle($.extend(options, { carouselVisible: 1 }));
    } else if (width > 400 && width < 540) {
      $('.cycle-slideshow').cycle($.extend(options, { carouselVisible: 2 }));
    } else if (width > 540 && width < 690) {
      $('.cycle-slideshow').cycle($.extend(options, { carouselVisible: 3 }));
    } else if ( width > 690 && width < 800 ) {
      $('.cycle-slideshow').cycle($.extend(options, { carouselVisible: 4 }));
    } else if ( width > 800 && width < 980 ) {
      $('.cycle-slideshow').cycle($.extend(options, { carouselVisible: 5 }));
    } else {
      $('.cycle-slideshow').cycle($.extend(options, { carouselVisible: 6 }));
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
  GS.searchBySchoolNameForm.init();
  GS.hubs.setupResponsiveCarousel();
});
