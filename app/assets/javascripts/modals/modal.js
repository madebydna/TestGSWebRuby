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
        modalDeferred.resolveWith(data);
      }).fail(function(data) {
        modalDeferred.rejectWith(data);
      });
    }).fail(function(data) {
      modalDeferred.rejectWith(data);
    });

    return modalDeferred.promise();
  };

  return {
    showModal: showModal
  };

})(jQuery);



