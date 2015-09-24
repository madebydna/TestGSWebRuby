var GS = GS || {};

GS.modal = GS.modal || {};

GS.modal.manager = GS.modal.manager || (function ($) {
  var GLOBAL_MODAL_CONTAINER_SELECTOR = '.js-modal-container';

  var insertModalIntoDom = function (modal) {
    $(GLOBAL_MODAL_CONTAINER_SELECTOR).append(modal);
  };

  var displayModal = function (modalObject, options) {
    options = options || {};
    var modalCssClass = options.modalCssClass || modalObject.getModalCssClass();
    var url = modalObject.url();
    url = GS.uri.Uri.addQueryParamToUrl('modal_css_class', modalCssClass, url);
    url = GS.I18n.preserveLanguageParam(url);
    return $.ajax({
      method: 'GET',
      url: url
    }).done(function (response) {
      insertModalIntoDom(response);
      modalObject.initialize();
      modalObject.show();
    }).fail(function (response) {
      // The caller can specify what to do if the model fails.
    });
  };

  return {
    displayModal: displayModal
  };

})(jQuery);



