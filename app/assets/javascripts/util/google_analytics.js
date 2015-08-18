/// This will handle events sent on load complete and accept event
GS.googleAnalytics =  GS.googleAnalytics || {};
GS.googleAnalytics.tracking = (function() {
  var gaClickSelector = '.js-gaClick';
  var gaClickLabel = "gaClickLabel";
  var gaClickValue = 'gaClickValue';
  var gaClickAction = 'gaClickAction';
  var gaClickCategory = 'gaClickCategory';

  var clickEventType = "click";

  var init = function(page){
    //if(GS.util.isBrowserTouch()){
    //  clickEventType = "touchend";
    //}
    onClick();
  };

  // category = gtm event category
  // action = gtm event action
  // label = gtm event label
  // value = this is always a number
  var send = function(category, action, label, value){
    analyticsEvent(category, action, label, value);
  };

  /*
  *  need to set up values for category, action and label -- value is a number
  *  ga('send', 'event', category, action, label, value);
  *
  * */

  var onClick = function() {
    $(gaClickSelector).on(clickEventType, function(){
      sendClickEvent($(this));
    });
  };

  var sendClickEvent = function($obj){
    var label = getLabel($obj, gaClickLabel);
    var value = getValue($obj, gaClickValue);
    var action = getAction($obj, gaClickAction);
    var category = getCategory($obj, gaClickCategory);
    send( category, action, label, value);

  };

  var getLabel = function($obj, labelName){
    var label = $obj.data(labelName);
    if(typeof label === 'undefined'){
      return 'label not defined';  // default
    }
    return label;
  };

  var getValue = function($obj, valueName){
    var value = $obj.data(valueName);
    if(typeof value === 'undefined'){
      return -1;  // default
    }
    return value;
  };

  var getAction = function ($obj, actionName) {
      var action = $obj.data(actionName);
      if (typeof action === 'undefined') {
          return 'action not defined';  // default
      }
      return action;
  };

  var getCategory = function($obj, categoryName){
      var category = $obj.data(categoryName);
      if(typeof category === 'undefined'){
          return 'category not defined';  // default
      }
      return category;
  }

  return {
    init:init,
    send:send
  }

})();

///  Usage
//
//<a class='js-gaClick'
//data-ga-click-category='language selection'
//data-ga-click-action='global nav bar'
//data-ga-click-label='spanish'
//data-ga-click-value=''</a>

// any element
// <div class='pbl js-gaClick'
//data-ga-click-category='language selection'
//data-ga-click-label='spanish'
//data-ga-click-action='global nav bar'>
//</div>

// using link_to
//<%= link_to school_url(@school), class: "js-gaClick", data:
//{ ga-click-category => 'school link',
//'ga-click-action'=> 'search result',
//'ga-click-label'=> 'school',
// 'ga-click-value'=>'90', } do %>/
