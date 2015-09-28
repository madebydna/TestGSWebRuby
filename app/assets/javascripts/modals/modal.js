var GS = GS || {};

GS.modal = GS.modal || {};

GS.modal.manager = GS.modal.manager || (function ($) {
  var GLOBAL_MODAL_CONTAINER_SELECTOR = '.js-modal-container';

  var insertModalIntoDom = function (modal) {
    $(GLOBAL_MODAL_CONTAINER_SELECTOR).append(modal);
  };

  var getModal = function(modalObject, options) {
    options = options || {};
    var modalCssClass = options.modalCssClass || modalObject.getModalCssClass();
    var url = modalObject.url();
    url = GS.uri.Uri.addQueryParamToUrl('modal_css_class', modalCssClass, url);
    url = GS.I18n.preserveLanguageParam(url);
    return $.ajax({
      method: 'GET',
      url: url
    });
  };

  var showModal = function (modalObject, options) {
    var modalDeferred = $.Deferred();
    getModal(modalObject, options).done(function (response) {
      insertModalIntoDom(response);
      modalObject.initialize();
      modalObject.show().done(function(data) {
        modalDeferred.resolveWith(this, [data]);
      }).fail(function(data) {
        modalDeferred.rejectWith(this, [data]);
      });
    }).fail(function(data) {
      modalDeferred.rejectWith(this, [data]);
    });

    return modalDeferred.promise();
  };

  // 'flash': [
  //            'error': [
  //                       'a message',
  //                       'another message'
  //                     ]
  var showModalThenMessages = function(modalObject, options) {
    showModal(modalObject, options).done(function(data) {
      if (data && data.hasOwnProperty('flash')) {
        GS.notifications.flash_from_hash(data.flash);
      }
    }).fail(function(data) {
      if (data && data.hasOwnProperty('flash')) {
        var flash = data.flash;
        if (!flash.hasOwnProperty('error')) {
          flash['error'] = ['Something went wrong, please try again soon.'];
        }
        GS.notifications.flash_from_hash(flash);
      }
    });
  };

  return {
    showModal: showModal,
    showModalThenMessages: showModalThenMessages
  };

})(jQuery);



