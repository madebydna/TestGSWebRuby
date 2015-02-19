GS.stateCitySchoolSelectBox = GS.stateCitySchoolSelectBox || (function() {

  var stateSelect = function() {
    $('#state_select').on('change', function() {
      //$('.js-cityListLoader').removeClass( "dn" );
      $.ajax({
        type: 'GET',
        url: "/gsr/ajax/get_cities",
        data: {state: $('#state_select').val()},
        async: true
      }).done(function(data) {
        var city_select = $('#city_select');
        city_select.find('option').remove();
        city_select.append('<option value="">'+'Select city'+'</option>');
        for(i=0; i < data.length; i++){
          city_select.append('<option value="'+data[i]+'">'+data[i]+'</option>');
        }
        //$('.js-cityListLoader').addClass( "dn" );
        $('.js-cityList').removeClass( "dn" );
      });
    });
  };

  var citySelect = function() {
    $('#city_select').on('change', function() {
      //$('.js-schoolListLoader').removeClass( "dn" );
      $.ajax({
        type: 'GET',
        url: "/gsr/ajax/get_schools",
        data: {state: $('#state_select').val(), city: $('#city_select').val()},
        async: true
      }).done(function(data) {
        var school_select = $('#school_select');
        school_select.find('option').remove();
        school_select.append('<option value="">'+'Select school'+'</option>');
        for(i=0; i < data.length; i++){
          school_select.append('<option value="'+data[i].id+'">'+data[i].name+'</option>');
        }
        //$('.js-schoolListLoader').addClass( "dn" );
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
