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
    hostname.indexOf("mitchtest.") != -1 ||
    hostname.indexOf("rcox.office.") != -1 ||
    (hostname.match(/.+office.*/) !== null && hostname.indexOf("cpickslay.office") == -1) ||
    hostname.indexOf("vpn.greatschools.org") != -1 ||
    hostname.indexOf("macbook") > -1;
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
