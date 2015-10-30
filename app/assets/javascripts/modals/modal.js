var GS = GS || {};

GS.modal = GS.modal || {};

GS.modal.manager = GS.modal.manager || (function ($) {
  var GLOBAL_MODAL_CONTAINER_SELECTOR = '.js-modal-container';
  var GLOBAL_MODAL_SELECTOR = '.js-gsModal';
  var modalsBeingDisplayed = [];

  var getModalContainer = function() {
    return $(GLOBAL_MODAL_CONTAINER_SELECTOR);
  };

  var getModalNode = function(modal) {
    return $($.parseHTML(modal)).closest(GLOBAL_MODAL_SELECTOR);
  };

  var insertModalIntoDom = function (modal) {
//  ajax request is an extra title and html element with modal this appends only
//  the modal into the dom
    var modalNode = getModalNode(modal);
    getModalContainer().append(modalNode);
  };

  // Using the modal's specific URL, retrieve modal HTML. Return the Ajax call's promise
  var requestModalViaAjax = function(modal) {
    return $.ajax({
      method: 'GET',
      url: modal.getUrlWithParams()
    });
  };

  // If modal HTML not already present within DOM, retrieve it and place into DOM
  // The act of retrieving the modal returns a promise, so just return that.
  // If we already have modal just return a resolved promise
  var ensureModalInDOM = function(modal) {
    var deferred = $.Deferred();
    var modalExistsOnPage = modal.$getModal().length > 0;

    if (modalExistsOnPage) {
      deferred.resolve();
    } else {
      deferred = requestModalViaAjax(modal).done(insertModalIntoDom);
    }
    return deferred;
  };

  // Show a modal. Takes a specific modal constructor function.
  // Instantiate a new modal object and make sure it's in the DOM
  // Because some modals can be triggered by JS setTimeout(), we need to prevent multiple modals from being shown
  // There is a notion of modal "stack". In the future of one modal triggers another, we could conceivably allow
  // multiple modals in the stack, and only show the top modal in the stack.
  //
  // This function creates/returns its own promise. That is because the resolving/rejecting of this promise is based on
  // The promise that is returned when we retrieve the modal, and the one that is returned when we show the modal
  //
  // If retrieving modal resolves and showing modal resolves, then resolve
  // If retrieving modal resolves and showing modal rejects, then reject
  // If retrieving modal rejects then reject. (do not try to show modal)
  var showModal = function(ModalConstructor, options) {
    options = options || {};
    var modalDeferred = $.Deferred();
    try {
      var modal = createModal(ModalConstructor, options);

      if (modalsBeingDisplayed.length == 0) {
        ensureModalInDOM(modal).done(function () {
          addModalToStack(modal);
          modal.initialize();
          modal.show().done(function (data) {
            modalDeferred.resolveWith(this, [data]);
          }).fail(function (data) {
            modalDeferred.rejectWith(this, [data]);
          }).always(function () {
            removeModalFromStack(modal);
          });
        }).fail(function (data) {
          modalDeferred.rejectWith(this, [data]);
        });
      } else {
        modalDeferred.reject();
      }
    } catch (e) {
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

  // With show a modal, and upon that finishing, will immediately show "flash" messages returned from Rails
  //
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
    attachDOMHandlers: attachDOMHandlers,
    getModalContainer: getModalContainer
  };

})(jQuery);

