

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// REVIEW ADS - for page injection when needed
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

GS.reviewsAd = GS.reviewsAd || {};

GS.reviewsAd.reviewSlotsArr = [
  {name:'Responsive_School_Reviews_Review1_728x90', dimensions: [728, 90]},
  {name:'Responsive_School_Reviews_Review2_300x250', dimensions: [300, 250]},
  {name:'Responsive_School_Reviews_Review3_728x90', dimensions: [728, 90]}
];
GS.reviewsAd.reviewSlotsMobileArr = [
  {name:'Responsive_Mobile_School_Reviews_Review1_320x50', dimensions: [320, 50]},
  {name:'Responsive_Mobile_School_Reviews_Review2_300x250', dimensions: [300, 250]},
  {name:'Responsive_Mobile_School_Reviews_Review3_320x50', dimensions: [320, 50]}
];

GS.reviewsAd.reviewSlotCount = GS.reviewsAd.reviewSlotsArr.length;

// This is creating ad slots for the reviews page.  This way they can be injected on next ten click.
//  This occurs before the setTargeting calls.
GS.reviewsAd.reviewContent = function() {
  if (gon.review_count > 0) {
    var ad_count = GS.reviewsAd.getReviewAdCount(gon.review_count);
    for (i = 0; i < ad_count; i++) {
      var desktop_ad = GS.reviewsAd.getReviewDefinedAdSlotArray(i);
      var mobile_ad = GS.reviewsAd.getReviewDefinedAdSlotArrayMobile(i);
      GS.ad.slot[GS.reviewsAd.reviewAdSlotName(i)] = googletag.defineSlot(
          GS.ad.googleId + desktop_ad['name'],
        desktop_ad['dimensions'],
        GS.reviewsAd.reviewAdSlotName(i)
      ).addService(googletag.pubads());

      GS.ad.slot[GS.reviewsAd.reviewAdSlotNameMobile(i)] = googletag.defineSlot(
          GS.ad.googleId + mobile_ad['name'],
        mobile_ad['dimensions'],
        GS.reviewsAd.reviewAdSlotNameMobile(i)
      ).addService(googletag.pubads());
    }
  }
};


// called by google advertising init above and also by the ajax call back in reviews.js
GS.reviewsAd.writeDivAndFillReviews = function(startId){
  var review_id = startId;
  $(".js_insertAdvertisingReview").each(function( index ) {
    // need to add div with width size
    var reviewIdName = GS.reviewsAd.reviewAdSlotName(review_id);
    var reviewIdNameMobile = GS.reviewsAd.reviewAdSlotNameMobile(review_id);
    $(this).append(
        (GS.reviewsAd.reviewDiv(reviewIdName, 'visible-lg visible-md visible-sm', GS.reviewsAd.getAdSlotWidthStr(index)))
        + " \n "
        + (GS.reviewsAd.reviewDiv(reviewIdNameMobile, 'visible-xs', GS.reviewsAd.getAdSlotWidthStrMobile(index)))
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
};

GS.reviewsAd.getReviewDefinedAdSlotArray = function(num){
  return GS.reviewsAd.reviewSlotsArr[num%GS.reviewsAd.reviewSlotCount];
};

GS.reviewsAd.getReviewDefinedAdSlotArrayMobile = function(num){
  return GS.reviewsAd.reviewSlotsMobileArr[num%GS.reviewsAd.reviewSlotCount];
};

GS.reviewsAd.getReviewAdCount = function(reviewCount){
  return Math.round(reviewCount*GS.reviewsAd.reviewSlotCount / 10)+1;
};

GS.reviewsAd.getAdSlotWidthStr = function(index){
  return GS.reviewsAd.reviewSlotsArr[index]['dimensions'][0]+'px';
};

GS.reviewsAd.getAdSlotWidthStrMobile = function(index){
  return GS.reviewsAd.reviewSlotsMobileArr[index]['dimensions'][0]+'px';
};

GS.reviewsAd.reviewDiv = function(id, visible_sizes_str, width) {
  return '<div class="gs_ad_slot_reviews '+visible_sizes_str+'"><div class="ma" id="'+ id +'" style="width:'+width+'"></div></div>';
};

GS.reviewsAd.reviewAdSlotName = function(num){
  return "adReviewPagination_"+num;
};

GS.reviewsAd.reviewAdSlotNameMobile = function(num){
  return "adReviewPaginationMobile_"+num;
};



///// examples
// desktop
//<div class="gs_ad_slot visible-lg visible-md" id="div-gpt-ad-1397603538853-0" data-ad-size="[[300,600],[300,250]]" style="width: 300px;" data-dfp="School_Overview_Snapshot_300x250"></div>

// mobile
//<div class="gs_ad_slot visible-sm visible-xs" id="div-gpt-ad-1397602726713-0" data-ad-size="[300,250]" style="width: 300px;" data-dfp="School_Overview_Mobile_Snapshot_300x250"></div>



