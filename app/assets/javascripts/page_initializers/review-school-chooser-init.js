$(function() {
  if (gon.pagename == "ReviewSchoolChooser") {
    GS.search.autocomplete.selectAutocomplete.init();
  }

  $('#state_select').on('change', function() {
    $.ajax({
      type: 'GET',
      url: "/gsr/ajax/get_cities",
      data: {state: $('#state_select').val()},
      async: false
    }).done(function (data) {

    });
  });

  $('#city_select').on('change', function() {
    $.ajax({
      type: 'GET',
      url: "/gsr/ajax/get_schools",
      data: {state: $('#state_select').val(), city: $('#city_select').val()},
      async: false
    }).done(function (data) {

    });
  });

});