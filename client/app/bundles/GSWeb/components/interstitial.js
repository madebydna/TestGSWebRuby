// TODO depends on gon
import { getValueOfQueryParam } from '../util/uri';

let destinationUri;

function readCookie(cookieName) {
    let cookie = "" + document.cookie;
    let i = cookie.indexOf(cookieName);
    if (i == -1 || cookieName == "") return "";

    let j = cookie.indexOf(';', i);
    if (j == -1) j = cookie.length;

    return unescape(cookie.substring(i + cookieName.length + 1, j));
}

function makeInterstitialHref(passThroughHref, adSlot) {
    let href = "/interstitial/?";
    if (adSlot) {
        href += "adslot=" + adSlot + "&"
    }
    href += "passThroughURI=" + encodeURIComponent(passThroughHref);
    return href;
}

export function attachInterstitial(adSlot) {
    // mobile can opt out of interstitial by using visible-xs on a div with class js-disableInterstitial
    if (gon && gon.show_ads && $('.js-disableInterstitial:visible').size() == 0) {
        doInterstitial(adSlot);
    }
}

function doInterstitial(adSlot) {
    if (document.cookie.length == 0) return;
    let interstitial = readCookie('gs_interstitial');
    if (!interstitial) {
        for (let i = 0; i < document.links.length; i++) {
            let link = document.links[i];
            if (!isAdLink(link) && !isExcludedLink(link)) {
                let linkContent = link.innerHTML;
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
    let adLinkRegExp = new RegExp("googlesyndication|doubleclick|advertising|" +
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
  let uri = getValueOfQueryParam('passThroughURI');
  let uriDecoded = "";
  if (uri && uri.length > 0) {
      uriDecoded = decodeURIComponent(uri);
    }
  if ( ! validUri(uriDecoded) ) {
    uriDecoded = "/"; 
  }
  return encodeURI(uriDecoded);
  }

function validUri(uri) {
  let valid = ( uriRelative(uri) ||
        uriAbsoluteToGsOrg(uri) ||
           uriAbsoluteToLocalhost(uri) );
  return valid;
}

function uriRelative(uri) {
  return uri.startsWith("/") && !uri.startsWith("//");
}

function uriAbsoluteToGsOrg(uri) {
  let gsOrgMatch = /^http(?:s)?:\/\/(?:[^\\/\\?]+\.)?greatschools\.org(?:\/|:|$).*/;
  return uri.match(gsOrgMatch);
}

function uriAbsoluteToLocalhost(uri) {
  let localhostMatch = /^http:\/\/localhost(?:\/|:|$).*/;
  return uri.match(localhostMatch);
}

function continueToDestination() {
  location.replace(destinationUri);
}

function setContinueToDestinationHandlers() {
  $('.js-continueToDestination').on('click', continueToDestination)
}

export { initInterstitialPage }
