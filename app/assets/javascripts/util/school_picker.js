var GS = GS || {};

GS.schoolPicker =  GS.schoolPicker || (function() {

    var editAutocompleteVal = '.js-editAutocompleteVal';
    var selectedAutocompleteVal = '.js-selectedAutocompleteVal';
    var autocompleteContainer = '.js-autocompleteContainer';
    var autocompleteFieldContainer = '.js-autocompleteFieldContainer';
    var doNotSeeResult = '.js-doNotSeeResult';
    var selectListsContainer = '.js-selectListsContainer';
    var stateSelect = '.js-stateSelect';
    var citySelect = '.js-citySelect';
    var schoolSelect = '.js-schoolSelect';
    var typeahead = '.typeahead';
    var click = "click";
    var change = "change";
    var keyup = 'keyup';
    var dataState = 'state';
    var dataCity = 'city';
    var dataNoResultText = 'no-result-text';
    var dataReturnToSearchText = 'return-to-search-text';
    var dataResponseKey = 'response-key';
    var getSchoolProfileUrlString = '/gsr/ajax/get_school_and_forward?';

    var setEditAutocompleteHandler = function(sectionContainer) {
        $(sectionContainer).on(click, editAutocompleteVal, function() {
            var $self = $(this);
            var $autocompleteContainer = $self.closest(autocompleteContainer);
            var $autocompleteFieldContainer = $autocompleteContainer.find(autocompleteFieldContainer);
            var $doNotSeeResults = $autocompleteContainer.find(doNotSeeResult);
            var doNotShowText = $doNotSeeResults.data(dataNoResultText);

            $doNotSeeResults.text(doNotShowText);
            $self.closest(selectedAutocompleteVal).addClass('dn')
            $doNotSeeResults.removeClass('dn');
            $autocompleteFieldContainer.removeClass('dn');
            $self.siblings('input').removeAttr('name').removeAttr('value')
        });
    };

    var setAutocompleteVal = function(text, $elementToHide) {
        var $autocompleteContainer = $elementToHide.closest(autocompleteContainer);
        var $doNotSeeResults = $autocompleteContainer.find(doNotSeeResult);
        var $val = $autocompleteContainer.find(selectedAutocompleteVal + ':hidden:first');
        var $input = $val.find('input');
        var keyName = $input.data(dataResponseKey);

        $elementToHide.addClass('dn')
        $doNotSeeResults.hide();
        $input.val(text);
        $input.attr('name', keyName);
        $val.find('span').text(text);
        $val.removeClass('dn');
    };

    var setDoNotSeeResultHandlers = function(dontSeeResultCallback) {
        setShowDoNotSeeResultsHandler();
        setToggleDoNotSeeResultsHandler(dontSeeResultCallback)
    };

    var setShowDoNotSeeResultsHandler = function() {
        $(autocompleteContainer).on(keyup, typeahead, function(){
            var $self = $(this);
            if ($self.val().length >= 3) {
                var $doNotSeeResult = $self.closest(autocompleteContainer).find(doNotSeeResult);
                $doNotSeeResult.removeClass('dn');
            }
        });
    };

    var setToggleDoNotSeeResultsHandler = function(dontSeeResultCallback) {
        $(autocompleteContainer).on('click', doNotSeeResult, function(){
            var $self = $(this);
            var $autocompleteContainer = $self.closest(autocompleteContainer);
            var $selectListsContainer = $autocompleteContainer.find(selectListsContainer);
            var $autocompleteFieldContainer = $autocompleteContainer.find(autocompleteFieldContainer);
            if (originalSearchVisible($self)) {
                var state = $self.data(dataState);
                dontSeeResultCallback.call(this, state, $autocompleteContainer);
                $self.text($self.data(dataReturnToSearchText));
            } else {
                $selectListsContainer.addClass('dn');
                $autocompleteFieldContainer.removeClass('dn');
                $self.text($self.data(dataNoResultText));
            }
        });
    };

  var originalSearchVisible = function ($self) {
     return $self.text().trim() == $self.data(dataNoResultText);
  }
// States are loaded on the page server side and not loaded via ajax like the
// cities and states are
    var setStateSelectHandler = function() {
        $(stateSelect).on(change, function() {
            var $stateSelect = $(this);
            var $autocompleteContainer = $stateSelect.closest(autocompleteContainer);
            var state = $stateSelect.val();
            loadCities(state, $autocompleteContainer);
        });
    };

    var showStateSelect = function(state, $autocompleteContainer) {
        var $stateSelect = $autocompleteContainer.find(stateSelect);

        hideAutocompleteFieldContainer($autocompleteContainer);
        $stateSelect.removeClass('dn');
        showSelectListsContainer($autocompleteContainer);
    };

    var saveStateData = function (state, $autocompleteContainer) {
        var $doNotSeeResult = $autocompleteContainer.find(doNotSeeResult);
        $doNotSeeResult.data(dataState, state);
    };

    var loadCities = function(state, $autocompleteContainer) {
        var $citySelect = $autocompleteContainer.find(citySelect);
        saveStateData(state, $autocompleteContainer);

        $.ajax({
            type: 'GET',
            url: "/gsr/ajax/get_cities",
            data: {state: state},
            async: true
        }).done(function(data) {
            addDataToSelectForm(data, $citySelect, buildCitiesOptions);
            hideAutocompleteFieldContainer($autocompleteContainer);
            showSelectListsContainer($autocompleteContainer);
        });
    };

    var setCitySelectedHandler = function() {
        $(autocompleteContainer).on(change, citySelect, function() {
            var $self = $(this);
            var $autocompleteContainer = $self.closest(autocompleteContainer);
            var $schoolSelect = $self.siblings(schoolSelect + ':first');
            var state =  getStateData($autocompleteContainer);
            var city = $self.find(':selected').data('value');
            saveCityData(city, $autocompleteContainer);
            loadSchools(state, city, $schoolSelect);
        });
    };

    var getStateData = function($autocompleteContainer) {
      var $doNotSeeResult = $autocompleteContainer.find(doNotSeeResult);
      return $doNotSeeResult.data(dataState);
    };

    var getCityData = function($autocompleteContainer) {
      var $doNotSeeResult = $autocompleteContainer.find(doNotSeeResult);
      return $doNotSeeResult.data(dataCity);
    };

    var saveCityData = function (city, $autocompleteContainer) {
      var $doNotSeeResult = $autocompleteContainer.find(doNotSeeResult);
      $doNotSeeResult.data(dataCity, city);
    };

    var loadSchools = function(state, city, $schoolSelect) {
        $.ajax({
            type: 'GET',
            url: "/gsr/ajax/get_schools",
            data: {state: state, city: city},
            async: true
        }).done(function(data) {
            addDataToSelectForm(data, $schoolSelect, buildSchoolsOptions);
        });
    };

    var addDataToSelectForm = function (data, $selectForm, buildOptionsCallback, $autocompleteContainer) {
      clearFormOptions($selectForm); 
      buildOptionsCallback(data, $selectForm);
      showSelectForm($selectForm);
    };

    var showSelectForm = function($selectForm) {
      $selectForm.removeClass('dn');
    };

    var hideAutocompleteFieldContainer = function ($autocompleteContainer) {
      var $autocompleteFieldContainer = $autocompleteContainer.find(autocompleteFieldContainer);
        $autocompleteFieldContainer.addClass('dn');
    };

    var showSelectListsContainer = function ($autocompleteContainer) {
      var $selectListsContainer = $autocompleteContainer.find(selectListsContainer);
        $selectListsContainer.removeClass('dn');
    };

    var addOptionLabel = function ($selectForm, formOption) {
      var optionString = formOption.toString();
      var optionLabelMarkup= '<option>' + 'Select ' + optionString  + '</option';
      $selectForm.append(optionLabelMarkup);
    };

    var clearFormOptions = function ($selectForm) {
      $selectForm.find('option').remove(); 
    };

    var buildSchoolsOptions = function (data, $schoolSelect) {
      var optionLabel = 'school';
      addOptionLabel($schoolSelect, optionLabel);
      for(i=0; i < data.length; i++){
        $schoolSelect.append('<option data-id="'+data[i].id+'" data-value="'+data[i].name+'">'+data[i].name+'</option>');
      }
    };

    var buildCitiesOptions = function (data, $citySelect) {
      var optionLabel = 'city';
      addOptionLabel($citySelect, optionLabel);
      for(i=0; i < data.length; i++){
        $citySelect.append('<option data-value="'+data[i]+'">'+data[i]+'</option>');
      }
    };

    var setSchoolSelectedHandler = function() {
        $(autocompleteContainer).on(change, schoolSelect, function() {
            var $self = $(this);
            var schoolName = $self.find(':selected').data('value');
            setAutocompleteVal(schoolName, $(this).closest(selectListsContainer))
        });
    };

    var setSchoolSelectedOspLandingPageHandler = function() {
      $(autocompleteContainer).on(change, schoolSelect, function() {
        $self = $(this);
        schoolId = $self.find(':selected').data('id');
        var $autocompleteContainer = $self.closest(autocompleteContainer);
        var $doNotSeeResult = $autocompleteContainer.find(doNotSeeResult);
        var state = getStateData($autocompleteContainer); 
        var city = getCityData($autocompleteContainer); 

        goToRegistrationPage(state, city, schoolId)
      });
    };

    var onSchoolSelectedCallback =  function (event, suggestion, dataset) {
        goToRegistrationPage(suggestion['state'], suggestion['city_name'], suggestion['id'])
    };

    var goToRegistrationPage = function(state, city, id) {
        var link = '/official-school-profile/register.page?state=' + state + '&schoolId=' + id + '&city=' + city;
        GS.uri.Uri.goToPage(link)
    };

    var initOspLandingPageAutocomplete = function(parentContainer) {
        setStateSelectHandler();
        setDoNotSeeResultHandlers(showStateSelect);
        setCitySelectedHandler();
        setSchoolSelectedOspLandingPageHandler();
        var markup = GS.search.autocomplete.display.schoolResultsNoLinkMarkup;
        GS.search.autocomplete.selectAutocomplete.init(gon.state_name, markup, onSchoolSelectedCallback);
    };

    var initOspPageAutocomplete = function(parentContainer) {
        setEditAutocompleteHandler(parentContainer);
        setDoNotSeeResultHandlers(loadCities);
        setCitySelectedHandler();
        setSchoolSelectedHandler();

        var markup = GS.search.autocomplete.display.schoolResultsNoLinkMarkup;
        GS.search.autocomplete.selectAutocomplete.init(gon.state_name, markup, function(event, suggestion, dataset) {
            setAutocompleteVal(suggestion['school_name'], $(this).closest(autocompleteFieldContainer));
        });
    };

    var setSchoolSelectedReviewSchoolChooserPageHandler = function() {
        $(autocompleteContainer).on(change, schoolSelect, function() {
             $self = $(this);
             schoolId = $self.find(':selected').data('id').toString();
            var $doNotSeeResult = $self.closest(autocompleteContainer).find(doNotSeeResult);
            var schoolObject = {};
            schoolObject.state = $doNotSeeResult.data(dataState);
            schoolObject.city = $doNotSeeResult.data(dataCity);
            schoolObject.school_id = schoolId;
            getSchoolProfileUrl(schoolObject);

        });
    };

    var schoolReviewsCallback =  function (event, suggestion, dataset) {
      var url = suggestion['url'];
      url = url + 'reviews/';
      goToReviewsPageUrl(url);
    };

   var goToReviewsPageUrl = function (url) {
        var queryStringsAnchors = buildQueryStringsAnchors();
        url = url + queryStringsAnchors;
        url = GS.uri.Uri.copyParam('lang', GS.uri.Uri.getHref(), url);
        GS.uri.Uri.goToPage(url)
   };

    var getSchoolProfileUrl = function(schoolObject) {
        var url = GS.uri.Uri.putParamObjectIntoQueryString(getSchoolProfileUrlString, schoolObject);
        goToReviewsPageUrl(url);
    };

    var initReviewSchoolChooserPageAutocomplete = function(parentContainer) {
        setStateSelectHandler();
        setDoNotSeeResultHandlers(showStateSelect);
        setCitySelectedHandler();
        setSchoolSelectedReviewSchoolChooserPageHandler();

    GS.search.autocomplete.selectAutocomplete.init(null, GS.search.autocomplete.display.schoolResultsNoLinkMarkup, schoolReviewsCallback);
    };


    var buildQueryStringsAnchors = function () {
      var queryStringAnchor = "";
      queryStringAnchor += morganStanleyQueryString();
      queryStringAnchor += topicAnchor();
      return queryStringAnchor;
    };

    var morganStanleyQueryString = function () {
      var queryString = "";
      if (gon.morganstanley) {
        queryString = "?morganstanley=1";
      }
      return queryString;
    };

    var topicAnchor = function () {
      var topicAnchor = "";
      if (gon.topic_id) {
        topicAnchor += "#topic" + gon.topic_id;
      }
      return topicAnchor;
    };

    return {
        setEditAutocompleteHandler: setEditAutocompleteHandler,
        initOspPageAutocomplete: initOspPageAutocomplete,
        initOspLandingPageAutocomplete: initOspLandingPageAutocomplete,
        initReviewSchoolChooserPageAutocomplete: initReviewSchoolChooserPageAutocomplete,
    }

})();

