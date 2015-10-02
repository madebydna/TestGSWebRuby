var GS = GS || {};
GS.modal = GS.modal || {};
GS.modal.joinModal = GS.modal.joinModal || (function($) {
  var MODAL_CSS_CLASS = 'join-modal';
  var MODAL_SELECTOR = '.' + MODAL_CSS_CLASS;
  var FORM_SELECTOR = 'form';
  var MODAL_URL = '/gsr/modals/join_modal';
  var $modal = undefined;
  var deferred = undefined;

  var $getModal = function() {
    $modal = $modal || $(MODAL_SELECTOR);
    return $modal;
  };

  var $getJoinForm = function() {
    return $getModal().find(FORM_SELECTOR);
  };

  var preventInteractions = function() {
    var $joinForm = $(FORM_SELECTOR);
    var $submitButton = $joinForm.find('button[type=submit]');
    $submitButton.hide();
  };

  var allowInteractions = function() {
    var $joinForm = $(FORM_SELECTOR);
    var $submitButton = $joinForm.find('button[type=submit]');
    $submitButton.show();
  };

  var show = function () {
    deferred = deferred || $.Deferred();
    $getModal().modal('show');
    return deferred.promise();
  };

  var hide = function () {
    $getModal().modal('hide');
  };

  var initializeDeferred = function() {
    deferred = deferred || $.Deferred();
    if (deferred.state() != 'pending') {
      deferred = $.Deferred();
    }
  };

  var initializeShowHideBehavior = function() {
    $getModal().on('hidden.bs.modal', function() {
      if(deferred.state() == 'pending') {
        deferred.reject();
      }
    });

    deferred.always(function() {
      if(isShown()) {
        hide();
      }
    });
  };

  var initializeForm = function() {
    $getJoinForm().on('submit', function() {
      preventInteractions();
    });

    $getJoinForm().on('ajax:success', function(event, jqXHR, options, data) {
      deferred.resolveWith(this, [jqXHR]);
    }).on('ajax:error',function(event, jqXHR, options, data) {
      allowInteractions();
      deferred.resolveWith(this, [jqXHR]);
    });
  };

  var initialize = function () {
    initializeDeferred();
    initializeShowHideBehavior();
    initializeForm();
  };

  var isShown = function() {
    return ($getModal().data('bs.modal') || {}).isShown;
  };

  var url = function () {
    return MODAL_URL;
  };

  var getCssClass = function () {
    return MODAL_CSS_CLASS;
  };

  return {
    initialize: initialize,
    show: show,
    url: url,
    getCssClass: getCssClass,
    deferred: deferred
  };


})(jQuery);