function hideFeedback(){
  $('#userNotFound').addClass('dn');
  $('#userVerification').addClass('dn');
  $('#userResetPassword').addClass('dn');
  $('#allGoodResetPassword').addClass('dn');
  $('#emailSent').addClass('dn');
  $('#emailSendFailed').addClass('dn');
  $('#ajaxFailed').addClass('dn');
}

$('.sendUserEmail').on('click', function() {
  $.ajax({
    type: 'POST',
    url: $(this).data('url'),
    data: {email: $('.email').val()},
    dataType: 'json',
    async: true
  }).done(function (data) {
    if (data['email_sent']) {
      $('#emailLink').html(data['email_link']);
      $('#emailSent').removeClass('dn');
    } else {
      $('#emailSendFailed').removeClass('dn');
    }
  }).fail(function() {
    $('#ajaxFailed').removeClass('dn');
  });
});

$('#js_userHelpForm').on('submit', function() {
  hideFeedback();
  $.ajax({
    type: 'GET',
    url: "/gsr/user/user-status",
    data: {email: $('.email').val()},
    dataType: 'json',
    async: true
  }).done(function (data) {
    switch(data['user_status']) {
      case 'no_user':
        $('#userNotFound').removeClass('dn');
        break;
      case 'verification_missing':
        $('#userVerification').removeClass('dn');
        break;
      case 'password_missing':
        $('#userResetPassword').removeClass('dn');
        break;
      case 'user_complete':
        $('#allGoodResetPassword').removeClass('dn');
    }
  }).fail(function() {
    $('#ajaxFailed').removeClass('dn');
  });
  return false;
});