$(function() {
  if (gon.pagename == "ReviewSchoolChooser") {
    GS.search.autocomplete.selectAutocomplete.init();
  }

  $('#scoop_search_type_link').on('click', function(event){
    current_text = $(this).text();
    if(current_text === "Don't see your school?"){
      $(this).text('Return to original search');
    }else{
      $(this).text("Don't see your school?");
    }

    $('#scoop_text_select').toggleClass('no_display');
    $('#scoop_state_city_school_select').toggleClass('no_display');
  });

  $('#state_select').on('change', function() {
    $.ajax({
      type: 'GET',
      url: "/gsr/ajax/get_cities",
      data: {state: $('#state_select').val()},
      async: false
    })
  });

  $('#city_select').on('change', function() {
    $.ajax({
      type: 'GET',
      url: "/gsr/ajax/get_schools",
      data: {state: $('#state_select').val(), city: $('#city_select').val()},
      async: false
    })
  });

});