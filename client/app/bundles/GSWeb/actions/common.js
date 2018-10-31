export const SHOW_MOBILE_OVERLAY_AD = 'LOAD_MOBILE_OVERLAY_AD';

export const loadMobileOverlayAd = () => (dispatch, getState) =>
  dispatch({
    type: SHOW_MOBILE_OVERLAY_AD
  });
