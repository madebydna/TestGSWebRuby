// TODO: import lodash methods
// TODO: should modal look different for error messages?
import modalManager from '../components/modals/manager';
import { findKey } from 'lodash';

export const error = function(message) {
  // TODO: style the modal differently depending on the type of message ?
  modalManager.showModal('SuccessModal', {
    heading: 'Whoops!',
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
  var type = findKey(hash, function(type, messages) {
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
