$(function() {
  $('#submitOspSearch').on('click', function(){
    var state = $('#states option:selected').text() || "";
    var schoolId = $('#schoolId').val() || "";
    var memberId = $('#memberId').val() || "";
    var memberEmail = $('#memberEmail').val() || "";
    var url = window.location.origin + "/admin/gsr/osp-search"
    var queryParameters = "?state="+state+"&school_id="+schoolId+"&member_id="+memberId+"&email="+memberEmail
    window.location.href = url + queryParameters
  });

  const collectOspMembershipIds = function(){
  //    If box is checked, create tuple in format [id, notes]
    let ospMemberArray = [];
    $('.osp-member').each(function() {
      var $this = $(this);
      if ($this.is(':checked')) {
        ospMemberArray.push([$this.attr('id'), $this.closest('tr').find('textarea.osp-notes').val()]);
      }
    });
    return ospMemberArray;
  };


  $('.submit-osp-membership').find('button').on('click', function(){
    var status = $(this).attr('data-id');
    var memberArray = collectOspMembershipIds();
  //    Don't fire ajax call unless user has selected osp-members to update
    if (memberArray.length > 0) {
      $.ajax({
        method: 'POST',
        url: '/admin/gsr/osp-moderation',
        data: {member_array: memberArray, status: status},
        success: function () {
          location.reload();
        },
        error: function(){
          alert('A problem occurred while trying to process your request. Try refreshing the page and submitting again. Contact support if you continue to receive this message.')
        }
      });
    } else {
      alert('Please check at least one box before clicking the buttons!');
    }
  });

  const paramInputMap = {
    'state': $('#states'),
    'school_id': $('#schoolId'),
    'member_id': $('#memberId'),
    'email': $('#memberEmail')
  }

  // Add query parameters to OSP Search inputs so user can see what current search is
  location.queryString = {};
  location.search.substr(1).split("&").forEach(function (pair) {
    if (pair === "") return;
    var parts = pair.split("=");
    location.queryString[parts[0]] = parts[1] &&
      decodeURIComponent(parts[1].replace(/\+/g, " "));
  });
  Object.keys(location.queryString).forEach(function(key) {
    paramInputMap[key].val(location.queryString[key])
  });

  const allChecked = function() {
    return ($('#tou').is(':checked') && $('#payment').is(':checked'))
  }

  $('form#new_api_account').submit(function(){
    // The form is used by admins and users. Users must check two boxes before submitting form.
    if ($('#tou').length && !allChecked()) {
      alert('Please review and agree to the Terms of Use and payment conditions before submitting your request.');
      return false;
    }
    return true;
  });

});


