$(function() {
  if (gon.pagename == "Write a school review | GreatSchools") {
    GS.search.autocomplete.selectAutocomplete.init();

    GS.stateCitySchoolSelectBox.stateSelect();
    GS.stateCitySchoolSelectBox.citySelect();
    GS.stateCitySchoolSelectBox.stateCitySchoolSubmit();
  }

  $('#js-schoolResultsSearch').on('keyup',function(){
    if($('#js-schoolResultsSearch').val().length >= 3){
      $('.js-scoop_search_type_div').removeClass('dn');
    }
  });

  $('.js-schoolList').on('change', function() {
         $('.js-goList').removeClass( "dn" );
  });

  $('.js-scoop_search_type_link').on('click', function(event){
    current_text = $(this).text();
    if(current_text === $(this).data('cta-text')){
      $(this).text($(this).data('return-text'));
      $('#scoop_text_select').addClass('dn');
      $('#scoop_state_city_school_select').removeClass('dn');
    }else{
      $(this).text($(this).data('cta-text'));
      $('#scoop_text_select').removeClass('dn');
      $('#scoop_state_city_school_select').addClass('dn');
    }

  });
});