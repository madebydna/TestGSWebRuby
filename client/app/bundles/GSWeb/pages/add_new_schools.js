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

  $('form').submit(function(){
    collectGradeLevels();
    if ($('#grade-level-selections').val() <= 0) {
      alert('Please select the grade levels offered at this school before submitting.');
      return false;
    }
    return true;
  });

  $('#pre-k-form').change(function() {
    if(this.checked) {
      $('input[type=checkbox]').prop('checked', false)
      $('.non_pre_k_fields').css('display', 'none');
      $('#pk').prop('checked', true);
      $('#pk-field').val(true)
    }
  });

  $('#k-12-form').change(function() {
    if(this.checked) {
      $('#pk').prop('checked', false);
      $('.non_pre_k_fields').css('display', 'block');
      $('#pk-field').val(false)
    }
  })
  var selectPreKForm = function(){
    if( '<%= @pk %>' == 'true') {
      $('#pk').prop('checked', true);
      $('#pre-k-form').trigger('click');
    }
  };
  selectPreKForm();
});

