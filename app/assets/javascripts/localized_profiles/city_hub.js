GS.textSwitch = function(el, target, replace) {
  if (el.value == replace) {
      el.value = target;
  }
};

GS.uri = GS.uri || {};
GS.hubs = GS.hubs || {};
GS.util = GS.util || {};

GS.util.isDeveloperWorkstation = function() {
  var hostname = window.location.hostname;
  return hostname.indexOf("localhost") > -1 ||
    hostname.indexOf("127.0.0.1") > -1 ||
    hostname.match(/^172.18.1.*/) !== null ||
    hostname.match(/^172.21.1.*/) !== null ||
    hostname.indexOf("samson.") != -1 ||
    hostname.indexOf("hugo.") != -1 ||
    hostname.indexOf("mitchtest.") != -1 ||
    hostname.indexOf("rcox.office.") != -1 ||
    (hostname.match(/.+office.*/) !== null && hostname.indexOf("cpickslay.office") == -1) ||
    hostname.indexOf("vpn.greatschools.org") != -1 ||
    hostname.indexOf("macbook") > -1;
};

GS.hubs.clearLocalUserCookies = function() {
  var isDeveloperWorkstation = GS.util.isDeveloperWorkstation();
  var localUserCookieNames = ["hubCity", "hubState", "ishubUser" ,"choosePage", "eventsPage","enrollPage", "eduPage"];
  for(var i = 0; i < localUserCookieNames.length; i++) {
    var opts = { path: '/' }
    if (!isDeveloperWorkstation) opts['domain'] = '.greatschools.org'
    $.removeCookie(localUserCookieNames[i])
  }
}

$(document).ready(function() {
  $('.js-clear-local-cookies-link').each(function() {
    $(this).click(GS.hubs.clearLocalUserCookies);
  });
});
