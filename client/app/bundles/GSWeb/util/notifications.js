// TODO: import lodash methods
// TODO: should modal look different for error messages?
import modalManager from '../components/modals/manager';

const topNotificationBarSelector = '#js-top-notification-bar';

export const $getNotificationContainer = function() {
  return $(topNotificationBarSelector);
};

export const closeNotificationMessage = function (wait) {
  $getNotificationContainer().children().each(function () {
    var $this = $(this);
    setTimeout(function () {
      if ($this.hasClass("alert")) {
        $this.remove();
      }
    }, wait);
  });
};

export const error = function(message) {
  // TODO: style the modal differently depending on the type of message ?
  modalManager.showModal('SuccessModal', {
    subheading: message
  });
};

export const notice = function(message) {
  modalManager.showModal('SuccessModal', {
    subheading: message
  });
};

export const success = function(message) { 
  modalManager.showModal('SuccessModal', {
    subheading: message
  });
}

export const warning = function(message) {
  modalManager.showModal('SuccessModal', {
    subheading: message
  });
};

export const flash_message = function(type, message) {
  if(type == 'notice') {
    notice(message);
  } else if(type == 'success') {
    success(message)
  } else if(type == 'error') {
    error(message);
  } else if(type == 'warning') {
    warning(message);
  }
};

//            'error': [
//                       'a message',
//                       'another message'
//                     ],
//            'notice: [
//                       'a message',
//                       'another message'
//                     ],
export const flash_from_hash = function(hash) {
  var type = _.findKey(hash, function(type, messages) {
    return messages.length > 0;
  });
  if (type) {
    flash_message(type, hash[type][0]);
  }
};

export const flashMessagesInAjaxResponse = function(response) {
  if (response && response.hasOwnProperty('flash')) {
    return flash_from_hash(response.flash);
  }
};

// TODO: move this somewhere else ?
jQuery(document).ready(function() {
  $getNotificationContainer().on('click', '.close', function () {
    $(this).closest('.alert').remove();
  });

  closeNotificationMessage(10000);
});

