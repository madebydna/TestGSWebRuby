var GS = GS || {};
GS.ad = GS.ad || {};
GS.ad.slot = GS.ad.slot || {};
GS.ad.shownArray = [];

//adobe audience manager code - copied and pasted
GS.ad.AamGpt = {
  strictEncode: function(str){
    return encodeURIComponent(str).replace(/[!'()]/g, escape).replace(/\*/g, "%2A");
  },
  getCookie: function(c_name){
    var i,x,y,c=document.cookie.split(";");
    for (i=0;i<c.length;i++)
    {
      x=c[i].substr(0,c[i].indexOf("="));
      y=c[i].substr(c[i].indexOf("=")+1);
      x=x.replace(/^\s+|\s+$/g,"");
      if (x==c_name)
      {
        return unescape(y);
      }
    }
  },
  getKey: function(c_name){
    var c=this.getCookie(c_name);
    c=this.strictEncode(c);
    if(typeof c != "undefined" && c.match(/\w+%3D/)){
      var cList=c.split("%3D");
      if(typeof cList[0] != "undefined" && cList[0].match(/\w+/)){
        return cList[0];
      }
    }
  },
  getValues: function(c_name){
    var c=this.getCookie(c_name);
    c=this.strictEncode(c);
    if(typeof c != "undefined" && c.match(/\w+%3D\w+/)){
      var cList=c.split("%3D");
      if(typeof cList[1] != "undefined" && cList[1].match(/\w+/)){
        var vList=cList[1].split("%2C");
        if(typeof vList[0] != "undefined"){
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


// google code for gpt
var googletag = googletag || {};
googletag.cmd = googletag.cmd || [];
(function() {
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
$(function(){
  var dfp_slots = $(".gs_ad_slot").filter(":visible");
  if (dfp_slots.length > 0 || gon.pagename == "Reviews") {
    googletag.cmd.push(function() {
      $(dfp_slots).each(function(){
          GS.ad.slot[GS.ad.getDivId($(this))] = googletag.defineSlot( GS.ad.getSlotName($(this)), GS.ad.getDimensions($(this)), GS.ad.getDivId($(this)) ).addService(googletag.pubads());
      });
      if(gon.pagename == "Reviews"){

          GS.ad.reviewContent();
      }
      GS.ad.setPageLevelTargeting();
      googletag.enableServices();


      $(dfp_slots).each(function(){
          GS.ad.showAd(GS.ad.getDivId($(this)));
      });

      if(gon.pagename == "Reviews") {
        GS.ad.writeDivAndFillReviews(0);
      }
    });
  }
});

GS.ad.getDivId = function(obj){
  return obj.attr('id');
}

GS.ad.getDimensions = function(obj){
  return JSON.parse(obj.attr('data-ad-size'));
}

GS.ad.getSlotName = function(obj){
  return '/1002894/' + obj.attr('data-dfp');
}

GS.ad.setPageLevelTargeting = function(){
  // add targeting for adobe
  GS.ad.AamCookieName = "gpt_aam";
  if (typeof GS.ad.AamGpt.getCookie(GS.ad.AamCookieName) !== 'undefined') {
    googletag.pubads().setTargeting(GS.ad.AamGpt.getKey(GS.ad.AamCookieName), GS.ad.AamGpt.getValues(GS.ad.AamCookieName));
  }
  if(typeof GS.ad.AamGpt.getCookie("aam_uuid") !== "undefined" ){
    googletag.pubads().setTargeting("aamId", GS.ad.AamGpt.getCookie("aam_uuid"));
  };

  // being set in localized_profile_controller - ad_setTargeting_through_gon
  // sets all targeting based on what is set in the controller
  $.each( gon.ad_set_targeting, function( key, value ){
    googletag.pubads().setTargeting(key, value);
  });
}


GS.ad.showAd = function(divId){
  if($.inArray(divId, GS.ad.shownArray) == -1){
    GS.ad.shownArray.push(divId);
    googletag.display(divId);
  }
  else{
    googletag.pubads().refresh([GS.ad.slot[divId]]);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// REVIEW ADS - for page injection when needed
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

GS.ad.reviewSlotsArr = [
  ['School_Reviews_Review1_728x90', [728, 90]],
  ['School_Reviews_Review2_300x250', [300, 250]],
  ['School_Reviews_Review3_728x90', [728, 90]]
];
GS.ad.reviewSlotsMobileArr = [
  ['School_Reviews_Mobile_Review1_320x50', [320, 50]],
  ['School_Reviews_Mobile_Review2_300x250', [300, 250]],
  ['School_Reviews_Mobile_Review3_320x50', [320, 50]]
];

GS.ad.reviewSlotCount = GS.ad.reviewSlotsArr.length;

// This is creating ad slots for the reviews page.  This way they can be injected on next ten click.
//  This occurs before the setTargeting calls.
GS.ad.reviewContent = function() {
  if (gon.review_count > 0) {
    var ad_count = GS.ad.getReviewAdCount(gon.review_count);
    for (i = 0; i < ad_count; i++) {
      desktop_ad = GS.ad.getReviewDefinedAdSlotArray(i);
      mobile_ad = GS.ad.getReviewDefinedAdSlotArrayMobile(i);
      GS.ad.slot[GS.ad.reviewAdSlotName(i)] = googletag.defineSlot(
              '/1002894/' + desktop_ad[0],
              desktop_ad[1],
              GS.ad.reviewAdSlotName(i)
      ).addService(googletag.pubads());

      GS.ad.slot[GS.ad.reviewAdSlotNameMobile(i)] = googletag.defineSlot(
              '/1002894/' + mobile_ad[0],
              mobile_ad[1],
              GS.ad.reviewAdSlotNameMobile(i)
      ).addService(googletag.pubads());
    }
  }
}


// called by google advertising init above and also by the ajax call back in reviews.js
GS.ad.writeDivAndFillReviews = function(startId){
  var review_id = startId;
  $(".js_insertAdvertisingReview").each(function( index ) {
    // need to add div with width size
    var reviewIdName = GS.ad.reviewAdSlotName(review_id);
    var reviewIdNameMobile = GS.ad.reviewAdSlotNameMobile(review_id);
    $(this).append(
          (GS.ad.reviewDiv(reviewIdName, 'visible-lg visible-md visible-sm', GS.ad.getAdSlotWidthStr(index)))
          + " \n "
          + (GS.ad.reviewDiv(reviewIdNameMobile, 'visible-xs', GS.ad.getAdSlotWidthStrMobile(index)))
    );

    $(this).removeClass('js_insertAdvertisingReview');

    if($("#"+reviewIdName+":visible").length !== 0){
      GS.ad.showAd(reviewIdName);
    }
    if($("#"+reviewIdNameMobile+":visible").length !== 0){
      GS.ad.showAd(reviewIdNameMobile);
    }
    review_id++;
  });
}

GS.ad.getReviewDefinedAdSlotArray = function(num){
  return GS.ad.reviewSlotsArr[num%GS.ad.reviewSlotCount];
}

GS.ad.getReviewDefinedAdSlotArrayMobile = function(num){
  return GS.ad.reviewSlotsMobileArr[num%GS.ad.reviewSlotCount];
}

GS.ad.getReviewAdCount = function(reviewCount){
  return Math.round(reviewCount/GS.ad.reviewSlotCount)+1;
}

GS.ad.getAdSlotWidthStr = function(index){
  return GS.ad.reviewSlotsArr[index][1][0]+'px';
}

GS.ad.getAdSlotWidthStrMobile = function(index){
  return GS.ad.reviewSlotsArr[index][1][0]+'px';
}

GS.ad.reviewDiv = function(id, visible_sizes_str, width) {
  return '<div class="gs_ad_slot_reviews ma '+visible_sizes_str+'" id="'+ id +'" style="width:'+width+'"></div>';
}

GS.ad.reviewAdSlotName = function(num){
 return "adReviewPagination_"+num;
}

GS.ad.reviewAdSlotNameMobile = function(num){
  return "adReviewPaginationMobile_"+num;
}

///// examples
// desktop
//<div class="gs_ad_slot visible-lg visible-md" id="div-gpt-ad-1397603538853-0" data-ad-size="[[300,600],[300,250]]" style="width: 300px;" data-dfp="School_Overview_Snapshot_300x250"></div>

// mobile
//<div class="gs_ad_slot visible-sm visible-xs" id="div-gpt-ad-1397602726713-0" data-ad-size="[300,250]" style="width: 300px;" data-dfp="School_Overview_Mobile_Snapshot_300x250"></div>