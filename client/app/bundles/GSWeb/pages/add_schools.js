$(function(){
  let collectGradeLevels = function(){
    let gradeSelectionsArray = [];
    $('input:checkbox').each(function() {
      let checkBox = $(this);
      if ( checkBox.is(':checked') ) {
        gradeSelectionsArray.push(checkBox.attr('data-grade'));
      }
    });
    $('#grade-level-selections').val(gradeSelectionsArray.join());
  };

  let handleMailingAddress = function() {
    if ($('#same-address').is(':checked')) {
      let physicalAddress = $('#new_school_submission_physical_address').val();
      let physicalCity = $('#new_school_submission_physical_city').val();
      let physicalZip = $('#new_school_submission_physical_zip_code').val();
      $('#new_school_submission_mailing_address').val(physicalAddress);
      $('#new_school_submission_mailing_city').val(physicalCity);
      $('#new_school_submission_mailing_zip_code').val(physicalZip);
    }
  };

  // Checks the pk box and sets the hidden field for persisting the user's selection of pre-k or k-12 forms.
  let setPkToTrue = function() {
    $('#pk').prop('checked', true);
    $('#pk-field').val('true')
  }

  let checkPkFormSelection = function() {
    if ($('#pre-k-form').is(':checked')) {
      setPkToTrue();
    }
  };

  $('form').submit(function(){
    checkPkFormSelection();
    handleMailingAddress();
    collectGradeLevels();
    if ($('#grade-level-selections').val().length <= 0 && $('#k-12-form').prop('checked') == true) {
      alert('Please select the grade levels offered at this school before submitting.');
      return false;
    }
    return true;
  });

  $('#pre-k-form').change(function() {
    if(this.checked) {
      $('input[type=checkbox]').prop('checked', false);
      $('.non_pre_k_fields').css('display', 'none');
      setPkToTrue();
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

