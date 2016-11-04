var GS = GS || {}
GS.util = GS.util || {};

var _kiq = _kiq || [];

GS.util.log = function (msg) {
    if (window.console) {
        console.log(msg);
    }
};

// Function wrapping code.
// fn - reference to function.
// context - what you want "this" to be.
// params - array of parameters to pass to function.
GS.util.wrapFunction = function(fn, context, params) {
  return function() {
    fn.apply(context, params);
  };
};


GS.store = GS.store || {};
GS.store.state = GS.store.state || {};
GS.util.memoizeAjaxRequest = function(key, promiseMaker) {
  var deferred = $.Deferred();
  var val = GS.store.state[key];
  if(val !== undefined) {
    deferred.resolve(val);
    return deferred;
  } else {
    return promiseMaker().done(function(response) {
      GS.store.state[key] = response;
    });
  }
};

GS.util.deleteAjaxCall = function(obj, hash) {
  var $self = obj;
  hash = hash || {};
  var link_value = hash.href || $self.attr("href");
  var callback = hash.callback || $self.data('callback') || GS.util.ajaxCallbackSuccess;
  var callback_error = hash.callback_error || $self.data('callback_error') || GS.util.ajaxCallbackError;
  var params_local = hash.params_local || $self.data('params-local');

  if (link_value !== undefined) {
    $.when(
      $.ajax({
        url: link_value,
        type: 'DELETE',
      })
    ).then(
      function (data) {
        callback($self, data, params_local);
      },
      function (data) {
        callback_error($self, data, params_local);
      }
    );
  }
};

GS.util.ajaxCallbackSuccess = function(obj, data, params) {
  console.log("Ajax delete success");
};

GS.util.ajaxCallbackError = function(obj, data, params) {
  console.log("Ajax delete error");
};

GS.util.getJsClasses = function($element) {
  var klasses = $element.attr('class');
  if (klasses !== undefined) {
    var jsClasses =  _.filter(klasses.split(' '), function(klass) {
      return klass.match(/js-/) !== null
    });
  };
  return jsClasses === undefined ? '' : jsClasses.join(' ');
};

GS.util.isHistoryAPIAvailable = function() {
  return (typeof(window.History) !== 'undefined' && typeof(window.history.pushState) !== 'undefined');
};

GS.util.manuallySendAnalyticsEvent = function($element) {
  var category = $element.data('event-category');
  var action   = $element.data('event-action');
  var label    = $element.data('event-label');

  analyticsEvent(category, action, label);
};
