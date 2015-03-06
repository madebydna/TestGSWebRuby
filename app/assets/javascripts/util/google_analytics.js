/// This will handle events sent on load complete and accept event
GS.googleAnalytics =  GS.googleAnalytics || {};
GS.googleAnalytics.tracking = (function() {
  var gaLoadSelector = '.js-gaLoad';
  var gaClickSelector = '.js-gaClick';
  var gaLoadLabel = 'gaLoadLabel';
  var gaClickLabel = "gaClickLabel";
  var gaLoadValueNumber = 'gaLoadValue';
  var gaClickValueNumber = 'gaClickValue';
  var clickEventType = "click";
  var pageName = '';

  var init = function(page){
    //if(GS.util.isBrowserTouch()){
    //  clickEventType = "touchend";
    //}
    pageName = page;
    onLoad();
    onClick();
  };

  // category = pagename
  // action = click, load, video play, etc
  // label = unique description of action - video name, click identifier, name of button
  // value = this is always a number
  var send = function(category, action, label, value){
    ga('send', category, action, label, value);
  };

  /*
  *  need to set up values for category, action and label -- value is a number
  *  ga('send', category, action, label, value);
  *
  * */

  var onLoad = function(){
    $(gaLoadSelector).filter(":visible").each(function () {
      sendLoadEvent($(this));
    });
  };

  var onClick = function() {
    $(gaClickSelector).on(clickEventType, function(){
      sendClickEvent($(this));
    });
  };

  var sendClickEvent = function(obj){
    var label = getLabel(obj, gaClickLabel);
    var value = getValue(obj, gaClickValueNumber);
    send( getPageName(), clickEventType, label, value);
  };

  var sendLoadEvent = function(obj){
    var label = getLabel(obj, gaLoadLabel);
    var value = getValue(obj, gaLoadValueNumber);
    send( getPageName(), 'load', label, value);
  };

  var getPageName = function(){
    return pageName;
  };

  var getLabel = function(obj, labelName){
    var label = obj.data(labelName);
    if(typeof label === 'undefined'){
      return 'label not defined';  // default
    }
    return label;
  };

  var getValue = function(obj, valueName){
    var value = obj.data(valueName);
    if(typeof value === 'undefined'){
      return -1;  // default
    }
    return value;
  };

  return {
    init:init,
    send:send
  }

})();
//
//  Usage
//
//<a class='js-gaLoad js-gaClick'
//data-ga-load-label='loadlinktest'
//data-ga-click-label='clickonlinktest'
//data-ga-load-value='33'
//data-ga-click-value='99'>TEST</a>

// any element
//<div class="pbl js-gaLoad" data-ga-load-label='bread crumbs on page' data-ga-load-value='989'>

// using link_to
//<%= link_to school_url(@school), class: "js-gaClick", data:
//{'ga-click-label'=> 'school header link',
//    'ga-click-value'=>'90', } do %>