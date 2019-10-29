import { isScrolledInViewport } from 'util/viewport';
import { anyStateNamePartialRegex } from 'util/states';

const onGK = window.location.href.indexOf("/gk/") !== -1;
const isStatePageRegex = new RegExp(`\\/(${anyStateNamePartialRegex})\\/?`);
const isCityPageRegex = new RegExp(`\\/(${anyStateNamePartialRegex})\\/[\\w\\-]+\\/?`);
const isSchoolPageRegex = new RegExp(`\\/(${anyStateNamePartialRegex})\\/[\\w-]+\\/\\d+-[\\w-]+\\/?`);
const onStatePage = isStatePageRegex.test(window.location.href);
const onCityPage = isCityPageRegex.test(window.location.href);
const onSchoolPage = isSchoolPageRegex.test(window.location.href);
export const onRefreshablePage = onGK || onSchoolPage; // || onStatePage || onCityPage;


export const INDIRECT_CAMPAIGN_IDS = [208549694, 123081254]; // Google AdX  and Rubicon Project_Unlimited
export const INDIRECT_AD_REFRESH_RATE = 15000;
export const MIN_VIEW_TIME = 1000;

export const setAdSlotForRefresh = function(divId) {
  console.log("Setting slot", divId, "for refresh");
  setTimeout(function(){
    GS.ad.showAd(divId);
  }, INDIRECT_AD_REFRESH_RATE);
}

export const setForRefreshAfterMinViewTime = function(divId) {
  setTimeout(function(){
    if (isScrolledInViewport(document.getElementById(divId))) {
      GS.ad.slotViewability[divId].markedForRefresh = true;
      setAdSlotForRefresh(divId);
    };
  }, MIN_VIEW_TIME);
}

// Check all ad slots for visibility, this is called on scroll and resize
export const checkElementViewability = function() {
  const elements = document.querySelectorAll(".gs_ad_slot");
  for(var i = 0; i < elements.length; i++) {
    let element = elements[i];
    if (!GS.ad.slotViewability[element.id]) { continue; }
    const {currentIndirectAd, viewedAt, markedForRefresh } = GS.ad.slotViewability[element.id];
    if (isScrolledInViewport(element) && currentIndirectAd) {
      const currentTime = new Date().getTime();
      if (!viewedAt) {
        // Ad has just become visible, record its viewedAt time
        GS.ad.slotViewability[element.id].viewedAt = currentTime;
      } else if ((currentTime - viewedAt) > MIN_VIEW_TIME 
        && !markedForRefresh) {
        // Marking ad for refresh, attribute prevents it from being set multiple times
        GS.ad.slotViewability[element.id].markedForRefresh = true;
        setAdSlotForRefresh(element.id);
      }
    }
  }
}
