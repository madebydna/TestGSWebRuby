$(function() {
  if (gon.pagename == "Write a school review | GreatSchools") {
    GS.search.autocomplete.selectAutocomplete.init();
  }

  $('#js-schoolResultsSearch').on('keyup',function(){
    if($('#js-schoolResultsSearch').val().length >= 3){
      $('.js-scoop_search_type_div').removeClass('dn');
    }
  });

  $('.js-scoop_search_type_link').on('click', function(event){
    current_text = $(this).text();
    if(current_text.indexOf("Don't see") >= 0){
      $(this).text('Return to original search');
      $('#scoop_text_select').addClass('dn');
      $('#scoop_state_city_school_select').removeClass('dn');
    }else{
      $(this).text("Don't see your school?");
      $('#scoop_text_select').removeClass('dn');
      $('#scoop_state_city_school_select').addClass('dn');
    }


  });

  $('#state_select').on('change', function() {
    $('.js-cityListLoader').removeClass( "dn" );
    $.ajax({
      type: 'GET',
      url: "/gsr/ajax/get_cities",
      data: {state: $('#state_select').val()},
      async: true
    }).done(function() {
      $('.js-cityListLoader').addClass( "dn" );
      $('.js-cityList').removeClass( "dn" );
    });
  });

  $('#city_select').on('change', function() {
    $('.js-schoolListLoader').removeClass( "dn" );
    $.ajax({
      type: 'GET',
      url: "/gsr/ajax/get_schools",
      data: {state: $('#state_select').val(), city: $('#city_select').val()},
      async: true
    }).done(function() {
      $('.js-schoolListLoader').addClass( "dn" );
      $('.js-schoolList').removeClass( "dn" );
    });
  });
  $('.js-schoolList').on('change', function() {
      $('.js-goList').removeClass( "dn" );
  });

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

    return true;
  });


});