$(function() {
  if (gon.pagename == "Write a school review | GreatSchools") {
    GS.search.autocomplete.selectAutocomplete.init(null, GS.search.autocomplete.display.schoolResultsNoLinkMarkup, schoolReviewsCallback);

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
    var show_drop_downs_text = $('#js_show_drop_downs_text').text().trim();
    var show_input_box_text = $('#js_show_input_box_text').text().trim();
    if($(this).data('cta-text-toggle') === "show drop downs"){
      $(this).text(show_input_box_text);
      $(this).data('cta-text-toggle',"show text box");
      $('#scoop_text_select').addClass('dn');
      $('#scoop_state_city_school_select').removeClass('dn');
    }else{
      $(this).text(show_drop_downs_text);
      $(this).data('cta-text-toggle',"show drop downs");
      $('#scoop_text_select').removeClass('dn');
      $('#scoop_state_city_school_select').addClass('dn');
    }
  });
});

//TODO: Move to final location of topical review javascript

var buildQueryStringsAnchors = function () {
    var queryStringAnchor = "";
    queryStringAnchor += morganStanleyQueryString();
    queryStringAnchor += topicAnchor();
    return queryStringAnchor;
}

var morganStanleyQueryString = function () {
    var queryString = "";
    if (gon.morganstanley) {
        queryString = "?morganstanley=1";
    }
    return queryString;
}

var topicAnchor = function () {
    var topicAnchor = "";
    if (gon.topic_id) {
        topicAnchor += "#topic" + gon.topic_id;
    }
    return topicAnchor;
}

var schoolReviewsCallback =  function (event, suggestion, dataset) {
    var queryStringsAnchors = buildQueryStringsAnchors();
    GS.uri.Uri.goToPage(suggestion['url']+"reviews/" + queryStringsAnchors);
};
