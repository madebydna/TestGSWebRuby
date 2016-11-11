var GS = GS || {};
GS.notifications = GS.notifications || (function($) {
  var $getNotificationContainer = function() {
    return $('#js-top-notification-bar');
  };

  $getNotificationContainer().on('click', '.close', function () {
    $(this).closest('.alert').remove();
  });

  var closeNotificationMessage = function (wait) {
    $getNotificationContainer().children().each(function () {
      var $this = $(this);
      setTimeout(function () {
        if ($this.hasClass("alert")) {
          $this.remove();
        }
      }, wait);
    });
  };

  var error = function(message) {

    $getNotificationContainer().append(
      GS.handlebars.partialContent(
        'notification_bar_message',{
          message: message,
          bootstrapType: 'danger'
        }
      )
    );
    closeNotificationMessage(10000);
  };

  var notice = function(message) {
    $getNotificationContainer().append(
      GS.handlebars.partialContent(
        'notification_bar_message',{
          message: message,
          bootstrapType: 'info'
        }
      )
    );
    closeNotificationMessage(10000);
  };

  var success = function(message) {
    $getNotificationContainer().append(
      GS.handlebars.partialContent(
        'notification_bar_message',{
          message: message,
          bootstrapType: 'success'
        }
      )
    );
    closeNotificationMessage(10000);
  };

  var warning = function(message) {
    $getNotificationContainer().append(
      GS.handlebars.partialContent(
        'notification_bar_message',{
          message: message,
          bootstrapType: 'warning'
        }
      )
    );
    closeNotificationMessage(10000);
  };

  var flash_message = function(type, message) {
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
  var flash_from_hash = function(hash) {
    var type = _.findKey(hash, function(type, messages) {
      return messages.length > 0;
    });
    if (type) {
      GS.notifications.flash_message(type, hash[type][0]);
    }
  };

  var flashMessagesInAjaxResponse = function(response) {
    if (response && response.hasOwnProperty('flash')) {
      return flash_from_hash(response.flash);
    }
  };

  return {
    error: error,
    notice: notice,
    success: success,
    warning: warning,
    flash_message: flash_message,
    flash_from_hash: flash_from_hash,
    flashMessagesInAjaxResponse: flashMessagesInAjaxResponse,
    closeNotificationMessage: closeNotificationMessage
  };
})(jQuery);
jQuery(document).ready(function() {
    GS.notifications.closeNotificationMessage(10000);
});

