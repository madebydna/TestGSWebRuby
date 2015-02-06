GS.ga = GS.ga || {};
GS.ga.trackingTypeVar = 'google-tracking-type';
GS.ga.trackingValueVar = 'google-tracking-value';

//TODO. This is a quick prototype. Would be nice to look these points in following iterations.
// 1) Refactor the js class using a better pattern
// 2) May not pass the elem .
// 3) Look into using ga.js vs analytics.gs . Which is the most recent way of doing google analytics and the advantages of each?
// 4) Is adding data attributes on elements the way to go or is there a better approach?
GS.ga.track = function(elem) {
  // if google tracking has a value send to google on button click
  var google_tracking_type = '';
  var google_tracking_value = '';
  if($(elem).data('google-tracking-value') !== undefined && $(elem).data('google-tracking-value') !== ''){
    google_tracking_value = $(elem).data('google-tracking-value');
  }
  if($(elem).data(GS.ga.trackingTypeVar) !== undefined && $(elem).data(GS.ga.trackingTypeVar) !== ''){
    google_tracking_type = $(elem).data(GS.ga.trackingTypeVar);
  }
  if(google_tracking_type && google_tracking_value){
    ga('send', 'event', 'button', 'click', google_tracking_type, google_tracking_value);
  }else if (google_tracking_type){
    ga('send', 'event', 'button', 'click', google_tracking_type);
  }
};
