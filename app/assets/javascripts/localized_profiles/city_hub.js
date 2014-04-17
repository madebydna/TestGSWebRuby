GS.textSwitch = function(el, target, replace) {
  if (el.value == replace) {
      el.value = target;
  }
};

GS.uri = GS.uri || {};
GS.hubs = GS.hubs || {};

GS.hubs.clearLocalUserCookies = function() {
  function createCookie(name, value, days) {
    var expires;

    if (days) {
      var date = new Date();
      date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
      expires = "; expires=" + date.toGMTString();
    } else {
      expires = "";
    }
    document.cookie = escape(name) + "=" + escape(value) + expires + "; path=/";
  }

  function eraseCookie(name) {
    createCookie(name, "", -1);
  }

  var localUserCookieNames = ["hubCity", "hubState", "ishubUser" ,"choosePage", "eventsPage","enrollPage", "eduPage"];
  for(var i = 0; i < localUserCookieNames.length; i++) {
    eraseCookie(localUserCookieNames[i]);
  }
}

$(document).ready(function() {
  $('.js-clear-local-cookies-link').each(function() {
    $(this).click(GS.hubs.clearLocalUserCookies);
  });
});
