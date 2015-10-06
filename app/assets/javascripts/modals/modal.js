var GS = GS || {};

GS.modal = GS.modal || {};

GS.modal.manager = GS.modal.manager || (function ($) {
  var GLOBAL_MODAL_CONTAINER_SELECTOR = '.js-modal-container';
  var modalsBeingDisplayed = [];

  var insertModalIntoDom = function (modal) {
    $(GLOBAL_MODAL_CONTAINER_SELECTOR).append(modal);
  };

  var requestModalViaAjax = function(modal) {
    return $.ajax({
      method: 'GET',
      url: modal.getUrlWithParams()
    });
  };

  var ensureModalInDOM = function(modal) {
    var deferred = $.Deferred();
    var modalExistsOnPage = $(modal.getSelector()).length > 0;

    if (modalExistsOnPage) {
      deferred.resolve();
    } else {
      deferred = requestModalViaAjax(modal).done(insertModalIntoDom);
    }
    return deferred;
  };

  var showModal = function(ModalConstructor, options) {
    options = options || {};
    var modal = createModal(ModalConstructor, options);
    var modalDeferred = $.Deferred();

    if(modalsBeingDisplayed.length == 0) {
      ensureModalInDOM(modal).done(function() {
        addModalToStack(modal);
        modal.initialize();
        modal.show().done(function(data) {
          modalDeferred.resolveWith(this, [data]);
        }).fail(function(data) {
          modalDeferred.rejectWith(this, [data]);
        }).always(function() {
          removeModalFromStack(modal);
        });
      }).fail(function(data) {
        modalDeferred.rejectWith(this, [data]);
      });
    } else {
      modalDeferred.reject();
    }

    return modalDeferred.promise();
  };

  var removeModalFromStack = function(modal) {
    modalsBeingDisplayed = _.pull(modalsBeingDisplayed, modal);
  };

  var addModalToStack = function(modal) {
    modalsBeingDisplayed.push(modal);
  };

  var createModal = function(ModalConstructor, options) {
    return new ModalConstructor($, options);
  };

  // 'flash': [
  //            'error': [
  //                       'a message',
  //                       'another message'
  //                     ]
  var showModalThenMessages = function(ModalConstructor, options) {
    return showModal(ModalConstructor, options).done(function(data) {
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

  var attachDOMHandlers = function() {
    $('.js-show-modal').each(function() {
      $(this).on('click', function() {
        var modalName = $(this).data('modal');
        if (GS.modal.hasOwnProperty(modalName)) {
          showModalThenMessages(GS.modal[modalName]);
        }
      });
    });
  };

  return {
    showModal: showModal,
    showModalThenMessages: showModalThenMessages,
    attachDOMHandlers: attachDOMHandlers
  };

})(jQuery);



