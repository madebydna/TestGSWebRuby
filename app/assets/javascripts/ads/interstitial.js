GS = GS || {};
GS.ad = GS.ad || {};
GS.ad.interstitial = (function() {

    var destinationUri;

    function readCookie(cookieName) {
        var cookie = "" + document.cookie;
        var i = cookie.indexOf(cookieName);
        if (i == -1 || cookieName == "") return "";

        var j = cookie.indexOf(';', i);
        if (j == -1) j = cookie.length;

        return unescape(cookie.substring(i + cookieName.length + 1, j));
    }

    function makeInterstitialHref(passThroughHref, adSlot) {
        var href = 'http://' + location.host + "/ads/interstitial/?";
        if (adSlot) {
            href += "adslot=" + adSlot + "&"
        }
        href += "passThroughURI=" + encodeURIComponent(passThroughHref);
        return href;
    }

    function attachInterstitial(adSlot) {
        // mobile can opt out of interstitial by using visible-xs on a div with class js-disableInterstitial
        if (gon && gon.show_ads && $('.js-disableInterstitial:visible').size() == 0) {
            doInterstitial(adSlot);
        }
    }

    function doInterstitial(adSlot) {
        if (document.cookie.length == 0) return;
        var interstitial = readCookie('gs_interstitial');
        if (!interstitial) {
            for (var i = 0; i < document.links.length; i++) {
                var link = document.links[i];
                if (!isAdLink(link) && !isExcludedLink(link)) {
                    var linkContent = link.innerHTML;
                    link.href = makeInterstitialHref(link.href, adSlot);
                    try {// GS-7304 this masks the problem...
                        link.innerHTML = linkContent;
                    } catch (e) {
                        //setting the innerHTML on IE7 can sometimes throw an exception
                    }
                }
            }
        }
    }

    function isAdLink(link) {
        var adLinkRegExp = new RegExp("googlesyndication|doubleclick|advertising|" +
            "oascentral|eyewonder|serving-sys|PointRoll|view.atdmt");
        return adLinkRegExp.test(link) || (link.target == "_blank");
    }

    function isExcludedLink(link) {
        return link.className.match(/noInterstitial/) || link.className.match(/js-no_ad/) ||
            (link.href && (link.href.match(/javascript/) || link.href.indexOf(window.location.href + "#") > -1)) ||
            (link.getAttribute("onclick") && link.getAttribute("onclick").toString().match(/window.open/));
    }

    function initInterstitialPage() {
      destinationUri = getDestinationUri();
      setInterstitialCookie();
      setUpNoAdHandler();
     setContinueToDestinationHandlers();
     setContinueTimeout();
    }

    function setInterstitialCookie() {
      $.cookie("gs_interstitial", "viewed", {expires: 1, path: '/' });
    }

    function setUpNoAdHandler() {
      googletag.cmd.push(function () {
        googletag.pubads().addEventListener('slotRenderEnded', function(event) {
          if (event.isEmpty) {
            continueToDestination();
          }
        });
      });
    }

    function setContinueTimeout() {
      setTimeout(continueToDestination, 15000);
    }

    function getDestinationUri() {
      var uri = GS.uri.Uri.getValueOfQueryParam('passThroughURI');
      var uriDecoded = "";
      if (uri && uri.length > 0) {
          uriDecoded = decodeURIComponent(uri);
        }
        return uriDecoded;
      }

    function continueToDestination() {
      location.replace(destinationUri);
    }

    function setContinueToDestinationHandlers() {
      $('.js-continueToDestination').on('click', continueToDestination)
    }

    return {
        attachInterstitial: attachInterstitial,
        initInterstitialPage: initInterstitialPage
    }
})();
