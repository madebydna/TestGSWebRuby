GS.stateCitySchoolSelectBox = GS.stateCitySchoolSelectBox || (function() {

  var stateSelect = function() {
    $('#state_select').on('change', function() {
      $.ajax({
        type: 'GET',
        url: "/gsr/ajax/get_cities",
        data: {state: $('#state_select').val()},
        async: true
      }).done(function() {
        $('.js-cityList').removeClass( "dn" );
      });
    });
  };

  var citySelect = function() {
    $('#city_select').on('change', function() {
      $.ajax({
        type: 'GET',
        url: "/gsr/ajax/get_schools",
        data: {state: $('#state_select').val(), city: $('#city_select').val()},
        async: true
      }).done(function() {
        $('.js-schoolList').removeClass( "dn" );
      });
    });
  };

  var stateCitySchoolSubmit = function() {
    $('#state_city_school_submit_btn').on('click', function() {
      var state_val = $('#state_select').val();
      var city_val = $('#city_select').val();
      var school_val = $('#school_select').val();
      if(state_val === '') {
        alert('Please select a state');
        return false;
      } else if (city_val === ''){
        alert('Please select a city');
        return false;
      } else if(school_val === ''){
        alert('Please select a school');
        return false;
      }
    });
  };

  return {
    stateSelect: stateSelect,
    citySelect: citySelect,
    stateCitySchoolSubmit: stateCitySchoolSubmit
  };

})();
