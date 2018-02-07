$(function(){
  var collectGradeLevels = function(){
    var gradeSelectionsArray = [];
    $('input:checkbox').each(function() {
      var checkBox = $(this);
      if ( checkBox.is(':checked') ) {
        gradeSelectionsArray.push(checkBox.attr('data-grade'));
      }
    });
    $('#grade-level-selections').val(gradeSelectionsArray);
  };

  var handleMailingAddress = function() {
    if ($('#same-address').is(':checked')) {
      let physicalAddress = $('#new_school_submission_physical_address').val();
      let physicalCity = $('#new_school_submission_physical_city').val();
      let physicalZip = $('#new_school_submission_physical_zip_code').val();
      $('#new_school_submission_mailing_address').val(physicalAddress);
      $('#new_school_submission_mailing_city').val(physicalCity);
      $('#new_school_submission_mailing_zip_code').val(physicalZip);
    }
  };

  $('form').submit(function(){
    collectGradeLevels();
    handleMailingAddress();
    if ($('#grade-level-selections').val() <= 0 && $('#k-12-form').prop('checked') == true) {
      alert('Please select the grade levels offered at this school before submitting.');
      return false;
    }
    return true;
  });

  $('#pre-k-form').change(function() {
    if(this.checked) {
      $('input[type=checkbox]').prop('checked', false);
      $('#pk').prop('checked', true);
      $('.non_pre_k_fields').css('display', 'none');
      $('#pk-field').val('true')
    }
  });

  $('#k-12-form').change(function() {
    if(this.checked) {
      $('#pk').prop('checked', false);
      $('.non_pre_k_fields').css('display', 'block');
      $('#pk-field').val('');
    }
  });

  $('#same-address').change(function() {
    if(this.checked) {
      $('.mailing').val('');
      $('.mailing').css('display', 'none');
    }
  });

  $('#different-address').change(function() {
    if(this.checked) {
      $('.mailing').css('display', 'block')
    }
  });

});

