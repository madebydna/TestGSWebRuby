GS.ad = GS.ad || {};
GS.ad.slot = GS.ad.slot || {};
GS.ad.shownArray = [];
GS.ad.functionSlotDefinitionArray = [];
GS.ad.functionAdShowArray = [];
GS.ad.googleId = '/1002894/';

if (gon.advertising_enabled) {
//adobe audience manager code - copied and pasted
  GS.ad.AamGpt = {
    strictEncode: function (str) {
      return encodeURIComponent(str).replace(/[!'()]/g, escape).replace(/\*/g, "%2A");
    },
    getCookie: function (c_name) {
      var i, x, y, c = document.cookie.split(";");
      for (i = 0; i < c.length; i++) {
        x = c[i].substr(0, c[i].indexOf("="));
        y = c[i].substr(c[i].indexOf("=") + 1);
        x = x.replace(/^\s+|\s+$/g, "");
        if (x == c_name) {
          return unescape(y);
        }
      }
    },
    getKey: function (c_name) {
      var c = this.getCookie(c_name);
      c = this.strictEncode(c);
      if (typeof c != "undefined" && c.match(/\w+%3D/)) {
        var cList = c.split("%3D");
        if (typeof cList[0] != "undefined" && cList[0].match(/\w+/)) {
          return cList[0];
        }
      }
    },
    getValues: function (c_name) {
      var c = this.getCookie(c_name);
      c = this.strictEncode(c);
      if (typeof c != "undefined" && c.match(/\w+%3D\w+/)) {
        var cList = c.split("%3D");
        if (typeof cList[1] != "undefined" && cList[1].match(/\w+/)) {
          var vList = cList[1].split("%2C");
          if (typeof vList[0] != "undefined") {
            return vList;
          } else {
            return null;
          }
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  };

  GS.ad.slotRenderedHandler = function(event) {
    if (event.isEmpty) {
      // Hide the entire containing div (which includes the ad div and the ghost text) as no ad has been rendered
      jQuery('.js-' + event.slot.getSlotElementId() + '-wrapper').hide();
    } else {
      // Show the ghost text as an ad is rendered
      jQuery('.js-' + event.slot.getSlotElementId() + '-wrapper .advertisement-text').removeClass('dn').show();
    }
  };

// google code for gpt
  var googletag = googletag || {};
  googletag.cmd = googletag.cmd || [];
  (function () {
    var gads = document.createElement('script');
    gads.async = true;
    gads.type = 'text/javascript';
    var useSSL = "https:" == document.location.protocol;
    gads.src = (useSSL ? "https:" : "http:") + "//www.googletagservices.com/tag/js/gpt.js";
    var node = document.getElementsByTagName('script')[0];
    node.parentNode.insertBefore(gads, node);
  })();

//////////////////////////////////////////////////////////////////////
//
//   Populates the ads that are visible on the page.
//   All ad slots should have the gs_ad_slot class
//   Set either visible or hidden using bootstrap hidden- or visible- classes
//   Uses Adobe Audience Manager for setTargeting and gon.ad_set_targeting for setTargeting - both page level
//
/////////////////////////////////////////////////////////////////////////////
  $(function () {
    var dfp_slots = $(".gs_ad_slot").filter(":visible,[data-ad-defer-render]");
    if (dfp_slots.length > 0 || gon.pagename == "Reviews") {

      googletag.cmd.push(function () {
        //    Remove after ab test
        if (!$.isEmptyObject(gon.ad_set_channel_ids)) {
          googletag.pubads().set("adsense_channel_ids", gon.ad_set_channel_ids);
        }

        $(dfp_slots).each(function () {
          GS.ad.defineSlot($(this));
        });

        while (GS.ad.functionSlotDefinitionArray.length > 0) {
          (GS.ad.functionSlotDefinitionArray.shift())();
        }

        GS.ad.setPageLevelTargeting();
        googletag.pubads().collapseEmptyDivs();
        googletag.pubads().addEventListener('slotRenderEnded', GS.ad.slotRenderedHandler);
        googletag.enableServices();

        $(dfp_slots).each(function() {
          GS.ad.showOrDefer($(this));
        });

        while (GS.ad.functionAdShowArray.length > 0) {
          (GS.ad.functionAdShowArray.shift())();
        }
      });
    }
  });

  GS.ad.getSizeMappings = function() {
    return {
      'box':  googletag.sizeMapping().
              addSize([300, 600], [[300, 600], [300, 250]]).
              addSize([0, 0], [[300, 250]]).
              build(),
    };
  };

  GS.ad.defineSlot = function($adSlot) {
    var sizeMappingMap = GS.ad.getSizeMappings();
    var slot = googletag.defineSlot(
      GS.ad.getSlotName($adSlot),
      GS.ad.getDimensions($adSlot),
      GS.ad.getDivId($adSlot)
    );
    var sizeMapping = sizeMappingMap[$adSlot.attr("data-ad-setting")];
    if (sizeMapping) {
      slot = slot.defineSizeMapping(sizeMapping);
    }
    GS.ad.slot[GS.ad.getDivId($adSlot)] = slot.addService(googletag.pubads());
  };

  GS.ad.getDivId = function (obj) {
    return obj.attr('id');
  };

  GS.ad.getDimensions = function (obj) {
    try {
      return JSON.parse(obj.attr('data-ad-size'));
    } catch (e) {
      GS.util.log('Error parsing ad dimensions for ' + obj.attr('id'));
    }
  };

  GS.ad.getSlotName = function (obj) {
    return GS.ad.googleId + obj.attr('data-dfp');
  };

  GS.ad.setPageLevelTargeting = function () {
    // add targeting for adobe
    GS.ad.AamCookieName = "gpt_aam";
    if (typeof GS.ad.AamGpt.getCookie(GS.ad.AamCookieName) !== 'undefined') {
      googletag.pubads().setTargeting(GS.ad.AamGpt.getKey(GS.ad.AamCookieName), GS.ad.AamGpt.getValues(GS.ad.AamCookieName));
    }
    if (typeof GS.ad.AamGpt.getCookie("aam_uuid") !== "undefined") {
      googletag.pubads().setTargeting("aamId", GS.ad.AamGpt.getCookie("aam_uuid"));
    }

    // being set in localized_profile_controller - ad_setTargeting_through_gon
    // sets all targeting based on what is set in the controller
    if ($.isEmptyObject(gon.ad_set_targeting)) {
      GS.util.log("gon setTargeting is empty for advertising");
    }
    else {
      $.each(gon.ad_set_targeting, function (key, value) {
        googletag.pubads().setTargeting(key, value);
      });
    }
  };

  GS.ad.showOrDefer = function($adSlot) {
    var deferRender = $adSlot.data('ad-defer-render') != undefined;
    if (!deferRender) {
      GS.ad.showAd(GS.ad.getDivId($adSlot));
    }
  };

  GS.ad.showAd = function (divId) {
    if ($.inArray(divId, GS.ad.shownArray) == -1) {
      GS.ad.shownArray.push(divId);
      googletag.display(divId);
    }
    else {
      googletag.pubads().refresh([GS.ad.slot[divId]]);
    }
  };


  GS.ad.addToAdSlotDefinitionArray = function (fn, context, params) {
    GS.ad.functionSlotDefinitionArray.push(GS.util.wrapFunction(fn, context, params));
  };

  GS.ad.addToAdShowArray = function (fn, context, params) {
    GS.ad.functionAdShowArray.push(GS.util.wrapFunction(fn, context, params));
  };

  GS.ad.checkMessageOrigin = function(origin) {
    return typeof origin === 'string' && (origin.match(/greatschools\.org$/) || origin.match(/googlesyndication\.com$/) || origin.match(/doubleclick\.net$/));
  };

  GS.ad.handleGhostTextMessages = function(event) {
    if (typeof event !== 'undefined' && GS.ad.checkMessageOrigin(event.origin) && typeof event.data !== 'undefined' && typeof event.data.ghostText == 'string') {
      jQuery('iframe').each(function() {
        if (this.getAttribute('name') && window.frames[this.getAttribute('name')] == event.source) {
          var $adSlotDiv = jQuery(this).parents('.gs_ad_slot');
          var slotName = $adSlotDiv.attr('id');
          $adSlotDiv.parents('.js-' + slotName + '-wrapper').find('.advertisement-text').text(event.data.ghostText);
        }
      });
    }
  };

  window.addEventListener('message', GS.ad.handleGhostTextMessages, false);

///// examples
// desktop
//<div class="gs_ad_slot visible-lg visible-md" id="div-gpt-ad-1397603538853-0" data-ad-size="[[300,600],[300,250]]" style="width: 300px;" data-dfp="School_Overview_Snapshot_300x250"></div>

// mobile
//<div class="gs_ad_slot visible-sm visible-xs" id="div-gpt-ad-1397602726713-0" data-ad-size="[300,250]" style="width: 300px;" data-dfp="School_Overview_Mobile_Snapshot_300x250"></div>


}