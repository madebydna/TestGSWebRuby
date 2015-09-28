// Initialize school picker on page init to use
// Schoolpicker defaults with setting school as value in form
// To customize schoolpicker pass in a custom autoCompleteSchoolCallback
// and a custom schoolSelectCallback
//
// To create a schoolpicker that navigates to url on school selection
// build a schoolpicker module with a schoolSelectUrlCallback that takes a
// school object and an onAutocompleteSchoolSelectCallback
// Then your schoolPickerNavigateUrl module by passing your school picker module 
// into the GS.schoolPicker.navigateToUrl.builder function
// this will return a module with the customSchoolSelectCallback 

GS = GS || {};
GS.schoolPicker = GS.schoolPicker ||  (function() {

  var autocompleteContainer = '.js-autocompleteContainer';
  var autocompleteFieldContainer = '.js-autocompleteFieldContainer';
  var selectListsContainer = '.js-selectListsContainer';
  var stateSelect = '.js-stateSelect';
  var citySelect = '.js-citySelect';
  var schoolSelect = '.js-schoolSelect';
  var typeahead = '.typeahead';
  var change = "change";
  var keyup = 'keyup';
  var click = "click";
  var dataReturnToSearchText = 'return-to-search-text';

  var schoolSelectUrlCallback;
  var schoolSelectCallback;
  var autocompleteSchoolSelectCallback;

  var STATE;

// selectors for toggling to not see results
  var doNotSeeResult = '.js-doNotSeeResult';
  var dataNoResultText = 'no-result-text';

// selectors for default action of setting value in form
  var selectedAutocompleteVal = '.js-selectedAutocompleteVal';
  var editAutocompleteVal = '.js-editAutocompleteVal';
  var dataResponseKey = 'response-key';

  var initSchoolpickerAndAutocomplete = function(customAutocompleteSchoolSelectCallback, customSchoolSelectCallback) {
    setSchoolSelectCallback(customSchoolSelectCallback);
    setAutocompleteSchoolSelectCallback(customAutocompleteSchoolSelectCallback);
    setupEventHandlers();
    autoCompleteInit();
  };

// SETTERS TO SAVE CUSTOM CALLBACKS OR SET TO DEFAULT 
  var setSchoolSelectCallback = function (customSchoolSelectCallback) {
    if (customSchoolSelectCallback) {
    schoolSelectCallback = customSchoolSelectCallback;
    } else {
      schoolSelectCallback = defaultSchoolSelectCallback;
    }
  };

  var setAutocompleteSchoolSelectCallback = function (customAutocompleteSchoolSelectCallback) {
    if ( customAutocompleteSchoolSelectCallback) {
      autocompleteSchoolSelectCallback = customAutocompleteSchoolSelectCallback;
    } else {
      autocompleteSchoolSelectCallback = defaultAutocompleteSchoolSelectCallback;
    }
  };

// Default school selected Callback is to set selected school as value in form
  var defaultSchoolSelectCallback = function () {
    var $self = $(this);
    var schoolName = $self.find(':selected').data('value');
    setSchoolSelectVal(schoolName, $self)
    setEditAutocompleteHandler($self);
    setEditAutocompleteHandler($self);
  };

// Default autocomplete school selected callback sets school value in form
  var defaultAutocompleteSchoolSelectCallback = function (event, suggestion, dataset) {
    setSchoolSelectVal(suggestion['school_name'], $(this));
    setEditAutocompleteHandler($(this));
  };

  var setEditAutocompleteHandler = function(self) {
    var $autocompleteContainer = getClosestAutocompleteContainer(self);
    $autocompleteContainer.on(click, editAutocompleteVal, function() {
      var $self = $(this);
      var $autocompleteContainer = getClosestAutocompleteContainer($self);
      var $doNotSeeResults = getClosest($self, doNotSeeResult);
      var doNotShowText = $doNotSeeResults.data(dataNoResultText);

      $doNotSeeResults.text(doNotShowText);
      hideClosest($self, selectedAutocompleteVal);
      showClosest($self, doNotSeeResult);
      showClosest($self, autocompleteFieldContainer);
      $self.siblings('input').removeAttr('name').removeAttr('value')
    });
  };

  var setSchoolSelectVal = function(text, self) {
    var $autocompleteContainer = getClosestAutocompleteContainer(self);
    var $val = $autocompleteContainer.find(selectedAutocompleteVal + ':hidden:first');
    var $input = $val.find('input');
    var keyName = $input.data(dataResponseKey);

    hideClosest(self, selectListsContainer);
    hideClosest(self, autocompleteFieldContainer);
    hideClosest(self, doNotSeeResult);
    $input.val(text);
    $input.attr('name', keyName);
    $val.find('span').text(text);
    $val.removeClass('dn');
  };

  // GETS STATE SELECTION FROM URL AND SAVES IT
  // if state is set schoolpicker only asks for city and schools
  var getAndSaveState = function () {
    var stateFromParams = GS.uri.Uri.getFromQueryString('state', GS.uri.Uri.getQueryStringFromURL());
    STATE = stateFromParams;
  };

  var setupEventHandlers = function () {
    getAndSaveState();
    if (STATE) {
      setDoNotSeeResultHandlers(loadCities);
    } else {
       setStateSelectHandler();
      setDoNotSeeResultHandlers(showStateSelect);
    }
  };

  var autoCompleteInit = function () {
    GS.search.autocomplete.selectAutocomplete.init(gon.state_name, GS.search.autocomplete.display.schoolResultsNoLinkMarkup, autocompleteSchoolSelectCallback);
  };

// Setup handlers to toggle between state/city/school picker & autocomplete search bar
  var setDoNotSeeResultHandlers = function(dontSeeResultCallback) {
    setShowDoNotSeeResultsHandler();
    setToggleDoNotSeeResultsHandler(dontSeeResultCallback)
  };

  var setShowDoNotSeeResultsHandler = function() {
   var autocompleteContainer = getAutocompleteContainer();
   autocompleteContainer.on(keyup, typeahead, function(){
      var $self = $(this);
      if ($self.val().length >= 3) {
        showClosest($self, doNotSeeResult);
      }
    });
  };

   var setToggleDoNotSeeResultsHandler = function(dontSeeResultCallback) {
    getAutocompleteContainer().on('click', doNotSeeResult, function(){
      var $self = $(this);
      if (originalSearchIsVisible($self)) {
        // If state is NOT passed as a params then callback is showStateSelect
        // If state IS passed as params it is saved to STATE then callback is loadCities
        var test;
        // dontSeeResultCallback.call(STATE, $self, this);
        dontSeeResultCallback($self, STATE);
        $self.text($self.data(dataReturnToSearchText));
      } else {
        hideClosest($self, selectListsContainer);
        showClosest($self, autocompleteFieldContainer);
        $self.text($self.data(dataNoResultText));
      }
    });
  };

  var originalSearchIsVisible = function ($self) {
    return $self.text().trim() == $self.data(dataNoResultText);
  };

// show the state select form is tiggered when state not passed as params
  var showStateSelect = function(self) {
    var $self = self;
    hideClosest($self, autocompleteFieldContainer);
    showClosest($self, stateSelect);
    showClosest($self, selectListsContainer);
  };

// Handler for the State Select form when State is not set in params
// States are loaded on the page server side and not loaded via ajax like the
// cities and schools 
  var  setStateSelectHandler = function() {
    $(stateSelect).on(change, function() {
      var $self = $(this);
      var state = $self.val();
      loadCities($self, state);
    });
  };

  var  setCitySelectHandler = function(state) {
    getAutocompleteContainer().on(change, citySelect, function() {
      var $self = $(this);
      var $schoolSelect = $self.siblings(schoolSelect + ':first');
      var city = $self.find(':selected').data('value');
      loadSchools($self, state, city);
    });
  };

  var setSchoolSelectHandler = function(state, city) {
    $(autocompleteContainer).on(change, schoolSelect,{state: state, city: city}, schoolSelectCallback)
  };

// AJAX CALLBACKS FOR LOADING CITY AND SCHOOL DATA INTO SELECT FORMS
  //  loadCities is used as callback for doNotSeeToggler when state is set 
  //  and is used as callback for stateSelectHandler when state selected by user
  var loadCities = function(self, state) {
    var $citySelect = getClosest(self, citySelect);
    $.ajax({
      type: 'GET',
      url: "/gsr/ajax/get_cities",
      data: {state: state},
      async: true
    }).done(function(data) {
      addDataToSelectForm(data, $citySelect, buildCitiesOptions);
      hideClosest(self, autocompleteFieldContainer);
      showClosest(self, selectListsContainer);
      setCitySelectHandler(state);
    });
  };

  var loadSchools = function(self, state, city) {
    $schoolSelect = getClosest(self, schoolSelect);
    $.ajax({
      type: 'GET',
      url: "/gsr/ajax/get_schools",
      data: {state: state, city: city},
      async: true
    }).done(function(data) {
      addDataToSelectForm(data, $schoolSelect, buildSchoolsOptions);
      setSchoolSelectHandler(state, city);
    });
  };

  // Adds Data to the Select Form; REQUIRES build OptionsCallback
  var addDataToSelectForm = function (data, $selectForm, buildOptionsCallback) {
    removeFormOptions($selectForm); 
    buildOptionsCallback(data, $selectForm);
    showSelectForm($selectForm);
  };

  var showSelectForm = function($selectForm) {
    $selectForm.removeClass('dn');
  };

  var removeFormOptions = function ($selectForm) {
    $selectForm.find('option').remove(); 
  };

  // CALLBACK FOR BUILDING SCHOOLS AND CITES FORM LIST
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

  var addOptionLabel = function ($selectForm, formOption) {
    var optionString = formOption.toString();
    var optionLabelMarkup= '<option>' + 'Select ' + optionString  + '</option';
    $selectForm.append(optionLabelMarkup);
  };

// FUNCTIONS TO GET, HIDE AND SHOW ELEMENTS
 var getAutocompleteContainer = function () {
    return $(autocompleteContainer);
  };

  var getClosestAutocompleteContainer = function (self) {
    return self.closest(autocompleteContainer);
  };

  var getClosestAutocompleteFieldContainer = function (self) {
    return getClosest(self, autocompleteFieldContainer);
  };

  var getClosest = function (self, element) {
    return getClosestAutocompleteContainer(self).find(element);
  };

  var hideClosest = function (self, element) {
    getClosest(self, element).addClass('dn');
  };

  var showClosest = function (self, element) {
    getClosest(self, element).removeClass('dn');
  };

  return {
    initSchoolpickerAndAutocomplete: initSchoolpickerAndAutocomplete,
  }

})(); 

GS.schoolPicker.navigateToUrl = (function() {

  var schoolSelectUrlCallback;

  var builder = function (modal) {
    setSchoolSelectUrlCallback(modal);
    modal.customSchoolSelectCallback = schoolSelectCallback;
    return modal;
  };

// school pickers use url callback if they navigate user to url
   var setSchoolSelectUrlCallback = function (modal) {
      schoolSelectUrlCallback = modal.schoolSelectUrlCallback;
  };

   var schoolSelectCallback = function(event) {
     var $self = $(this);
     var schoolId = $self.find(':selected').data('id');
     var schoolObject = {};
     schoolObject.state = event.data.state;
     schoolObject.city = event.data.city;
     schoolObject.id = schoolId;
     var url =  schoolSelectUrlCallback.call(this, schoolObject);
     GS.uri.Uri.goToPage(url);
   };

   return {
    builder: builder
  }
})();

GS.schoolPicker.reviewsChooser = GS.schoolPicker.reviewsChooser || (function() {

  var getSchoolProfileUrlString = '/gsr/ajax/get_school_and_forward?';

  var onAutocompleteSchoolSelectCallback = function (event, suggestion, dataset) {
    var url = suggestion['url'];
    url = url + 'reviews/';
    GS.uri.Uri.goToPage(addParamsAndAnchorToUrl(url));
  };

//  schoolSelectUrlCallback for the state city and school picer
  var schoolSelectUrlCallback = function(schoolObject) {
    schoolObject.school_id = schoolObject.id.toString();
    var url = GS.uri.Uri.putParamObjectIntoQueryString(getSchoolProfileUrlString, schoolObject);
    return addParamsAndAnchorToUrl(url);
  };

// Code to adding Query Params to Callback URL
  var addParamsAndAnchorToUrl = function (url) {
    url = addMorganStanley(url);
    url = GS.I18n.preserveLanguageParam(url);
    return addTopicAnchor(url);
  };

  var addMorganStanley = function (url) {
    if (gon.morganstanley) {
    url = GS.uri.Uri.addQueryParamToUrl('morganstanley', '1', url);
     }
    return url;
  };

  var addTopicAnchor = function (url) {
    var topicAnchor = "";
    if (gon.topic_id) {
      topicAnchor += "#topic" + gon.topic_id;
    }
    return url + topicAnchor;
  };

 return {
    onAutocompleteSchoolSelectCallback: onAutocompleteSchoolSelectCallback,
    schoolSelectUrlCallback: schoolSelectUrlCallback
  }

})();

GS.schoolPicker.ospLandingPage = GS.schoolPicker.ospLandingPage || (function() {

  var onAutocompleteSchoolSelectCallback = function (event, suggestion, dataset) {
    var schoolObject = {};
    schoolObject.state = suggestion['state'];
    schoolObject.city = suggestion['city_name'];
    schoolObject.id = suggestion['id'];
    GS.uri.Uri.goToPage(schoolSelectUrlCallback(schoolObject));
  };

  var schoolSelectUrlCallback = function(schoolObject) {
    var link = '/official-school-profile/register.page?state=' + schoolObject.state + '&schoolId=' + schoolObject.id + '&city=' + schoolObject.city;
    return link;
  };

  return {
    onAutocompleteSchoolSelectCallback: onAutocompleteSchoolSelectCallback,
    schoolSelectUrlCallback: schoolSelectUrlCallback
  }

})();

