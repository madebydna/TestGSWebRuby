var GS = GS || {};
GS.forms = GS.forms || {};

// Updates the custom checkboxes, radio buttons, and pulldowns, based
// on the state of their hidden form fields
GS.forms.updateFormVisualElements = function() {
  // Set initial state of visual checkboxes based on if hidden fields
  // have initial value
  $('input.js-gs-checkbox-value:hidden').each(function() {
    var $this = $(this);
    if ($this.val() !== '') {
      var checkbox = $this.parent().find('.i-24-checkmark-off');
      checkbox.removeClass('i-24-checkmark-off').addClass('i-24-checkmark-on');
      $this.parent().find('.js-gs-checkbox').addClass('active');
    }
  });

    $('input.js-value:hidden').each(function() {
        var $this = $(this);
        var icoValue = $this.parent().data('gs-checkbox-icon-label');
        if ($this.val() !== '') {
            $this.parent().find('.js-icon').removeClass(icoValue+'-off').addClass(icoValue+'-on');
            $this.parent().addClass('active');

        }else {
            $this.parent().find('.js-icon').removeClass(icoValue+'-on').addClass(icoValue+'-off');
            $this.parent().removeClass('active');
        }
    });
  // Set initial state of visual radio buttons based on if hidden fields
  // have initial value
  $('input.js-gs-radio-value:hidden').each(function() {
    var $this = $(this);
    if ($this.val() !== '') {
      $this.parent().find('.js-gs-radio').removeClass('active');
      checkbox = $this.parent().find('.js-gs-radio[data-gs-radio="' + $this.val() + '"]');
      checkbox.addClass('active');
    }
  });
  // For pulldowns, if any child elements are checked, then visually
  // checkmark the pulldown button
  var pulldowns = $('.js-pull-down.js-gs-checkbox');
  pulldowns.each(function() {
    var $parent = $(this).parent();
    if ($parent.find('input.js-gs-checkbox-value:hidden').filter(function() {
      return $(this).val() !== '';
    }).length > 0) {
      $(this).find('.js-icon').removeClass('i-24-checkmark-off').addClass('i-24-checkmark-on');
      $(this).find('.js-icon').parent().addClass('active');
    }
  });

    pulldowns.each(function() {
        var $parent = $(this).parent();
        if ($parent.find('input.js-value:hidden').filter(function() {
            return $(this).val() !== '';
        }).length > 0) {
            $(this).find('.js-icon').removeClass('i-24-checkmark-off').addClass('i-24-checkmark-on');
            $(this).find('.js-icon').parent().addClass('active');
        }
    });
};

$(function() {

    //needs to be ahead of click handlers
    if (gon.pagename === 'GS:GuidedSchoolSearch') {
        FastClick.attach(document.body);
    }

    $('.js-gs-radio').on('click',function(){
        var self = $(this);
        var hidden_field = self.parent().siblings(".js-gs-radio-value");
        var gs_radio = self.data('gs-radio');
        hidden_field.val(gs_radio);
        self.siblings().removeClass('active');
        self.addClass('active');

    });

    $(".js-pull-down").on('click', function(){

        var self=$(this);
        var gs_pull_down = self.data('pull-down-content');
        var pull_down_layer = $(gs_pull_down);
        var pull_down_button = pull_down_layer.siblings('.js-pull-down');
        pull_down_layer.slideToggle();
        var is_pull_down_selected =false;
        pull_down_layer.find('.js-gs-checkbox-value').each(function(){
            if ($(this).val() != ''){
                 is_pull_down_selected = true ;
             }
         });

        pull_down_layer.find('.js-value').each(function(){
            if ($(this).val() != ''){
                is_pull_down_selected = true ;
            }
        });
        if (is_pull_down_selected == true) {
            pull_down_button.find('.js-icon').removeClass('i-24-checkmark-off').addClass('i-24-checkmark-on');
            pull_down_button.find('.btn').addClass('active');

        }else {
            pull_down_button.find('.js-icon').removeClass('i-24-checkmark-off').addClass('i-24-checkmark-on');
            pull_down_button.find('.btn').removeClass('active');
            pull_down_button.find('.js-icon').removeClass('i-24-checkmark-on').addClass('i-24-checkmark-off');

        }

    });

//todo: refactor to make this generic
    $(".js-gs-checkbox").on('click', function(){
        var self=$(this);
        var checkbox = self.children(".js-icon");
        var hidden_field = self.siblings(".js-gs-checkbox-value");
        var gs_checkBox= self.data('gs-checkbox');
        if (hidden_field.val()== '') {
            checkbox.removeClass('i-24-checkmark-off').addClass('i-24-checkmark-on');
            hidden_field.val(gs_checkBox);

        }else {
            checkbox.removeClass('i-24-checkmark-on').addClass('i-24-checkmark-off');
            hidden_field.val('');

        }

    });

    $('.js-gs-checkbox-search').on('click',function(){
        var self=$(this);
        var checkbox = self.children(".js-icon");
        var hidden_field = self.siblings(".js-gs-checkbox-value");
        var gs_checkBox= self.data('gs-checkbox-value');
        var gs_checkBoxCategory= self.data('gs-checkbox-name');
        if (hidden_field.val()== '') {
            checkbox.removeClass('i-grey-unchecked-box').addClass('i-16-blue-check-box');
            hidden_field.attr("value", gs_checkBox).attr("name", gs_checkBoxCategory);
        } else {
            checkbox.removeClass('i-16-blue-check-box').addClass('i-grey-unchecked-box');
            hidden_field.removeAttr("value").removeAttr("name");
        }
    });

    // force checked state. Requires 'this' to be the label.js-gs-checkbox-search
    var checkFancyCheckbox = function() {
        var self = $(this);
        var checkbox = self.children(".js-icon");
        var hidden_field = self.siblings(".js-gs-checkbox-value");
        var gs_checkBox= self.data('gs-checkbox-value');
        var gs_checkBoxCategory= self.data('gs-checkbox-name');
        checkbox.removeClass('i-grey-unchecked-box').addClass('i-16-blue-check-box');
        hidden_field.val(gs_checkBox).attr("name", gs_checkBoxCategory);
    };

    $('.js-gs-checkbox-search-dropdown').on('click',function(){
       var self=$(this);
       var checkbox = self.children(".js-icon");
       var hidden_box = self.siblings(".js-gs-checkbox-search-collapsible-box");
       var children = hidden_box.children('div').children('.js-gs-checkbox-value');

       hidden_box.css('display') == 'none' ? hidden_box.show('slow') : hidden_box.hide('fast');
       toggleCheckboxForCollapsibleBox(checkbox, children);
    });

    $('.js-sportsIconButton').on('click', function(){
        var self = $(this);
        var checkbox = self.children(".js-icon");
        var hidden_field = self.children(".js-value");
        var gs_checkBox= self.data('gs-checkbox-value');
        var gs_checkBoxCategory= self.data('gs-checkbox-category');
        var gs_iconLabel = self.data('gs-checkbox-icon-label');

        if (hidden_field.val()== '') {
            checkbox.removeClass(gs_iconLabel + '-off').addClass(gs_iconLabel + '-on');
            hidden_field.attr("value", gs_checkBox).attr("name", gs_checkBoxCategory);
        } else {
            checkbox.removeClass(gs_iconLabel + '-on').addClass(gs_iconLabel + '-off');
            hidden_field.removeAttr("value").removeAttr("name");
        }
    });

    // force checked state, requires 'this' to be the div.js-sportsIconButton
    var checkSportsIcon = function() {
        var self = $(this);
        var checkbox = self.children(".js-icon");
        var hidden_field = self.children(".js-value");
        var gs_checkBox= self.data('gs-checkbox-value');
        var gs_checkBoxCategory= self.data('gs-checkbox-category');
        var gs_iconLabel = self.data('gs-checkbox-icon-label');
        checkbox.removeClass(gs_iconLabel + '-off').addClass(gs_iconLabel + '-on');
        self.addClass('active');
        hidden_field.val(gs_checkBox).attr("name", gs_checkBoxCategory);
    };

    var toggleCheckboxForCollapsibleBox = function(checkbox, children) {
        if (childCheckboxesAreEmpty(children)) {
            checkbox.removeClass('i-16-blue-check-box').addClass('i-grey-unchecked-box');
        } else {
            checkbox.removeClass('i-grey-unchecked-box').addClass('i-16-blue-check-box');
        }
    };

    var childCheckboxesAreEmpty = function(children) {
        var isEmpty = true;
        $(children).each(function(i) {
            if ($(this).val() !== '') { isEmpty = false }
        });
        return isEmpty
    };

//    ToDo Refactor and combine collapsible box toggling functionality
    var toggleCheckboxForCollapsibleBoxOnLoad = function() {
        $('.js-gs-checkbox-search-dropdown').each(function(i) {
            var self=$(this);
            var checkbox = self.children(".js-icon");
            var hidden_box = self.siblings(".js-gs-checkbox-search-collapsible-box");
            var children = hidden_box.children('div').children('.js-gs-checkbox-value');
            toggleCheckboxForCollapsibleBox(checkbox, children);
        });
    };

    $('.js-guidedSearch').on('submit',function() {
        // prevent submission of form when not on final page (e.g. by pressing 'enter' in address field)
        if (!($('.js-guided-search-submit').is(':visible'))) {
            return false;
        }
        GS.search.schoolSearchForm.findByNameSelector = '#js-guidedQueryString';
        GS.search.schoolSearchForm.findByLocationSelector = '#js-guidedQueryString';
        return GS.search.schoolSearchForm.submitByLocationSearch.call(this, guidedGeocodeCallbackFn);
    });

    var addToArray = function(hash, key, value) {
        if (hash[key] === undefined) {
            hash[key] = [value];
        } else {
            hash[key].push(value);
        }
    };

    var getSelectedFilterValues = function() {
        // Add input names here to opt them out of form serialization
        var EXCLUDE_THESE_INPUTS = ['location', 'distance'];
        var searchOptions = {};
        // values for inputs are iterated here
        $('.js-guidedSearch').find("input").each(function () {
            var $this = $(this);
            var name = $this.attr('name');
            if ($.trim($this.val()) > '' && name !== undefined && !EXCLUDE_THESE_INPUTS.contains(name)) {
                if (name.indexOf('[]') > -1) {
                    var values = $this.val().split("&&");
                    for (var x=0; x < values.length; x++) {
                        addToArray(searchOptions, encodeURIComponent(name), encodeURIComponent(values[x]));
                    }
                } else {
                    searchOptions[encodeURIComponent(name)] = encodeURIComponent($this.val());
                }
            }
        });
        searchOptions['grades'] = encodeURIComponent($('#js-guided-grades').val());
        searchOptions.state = 'DE';
        return searchOptions;
    };

    var guidedGeocodeCallbackFn = function(geocodeResult) {
        var searchOptions = getSelectedFilterValues();
        if (geocodeResult) {
            for (var urlParam in geocodeResult) {
                if (geocodeResult.hasOwnProperty(urlParam)) {
                    searchOptions[urlParam] = encodeURIComponent(geocodeResult[urlParam]);
                }
            }
        }
        searchOptions['locationSearchString'] = encodeURIComponent(GS.search.schoolSearchForm.getSearchQuery());
        // pull values from any selects here
        searchOptions['distance'] = $('#js-guided-distance').val() || 5;
        searchOptions['grades'] = $('#js-guided-grades').val();

        // Not setting a timeout breaks back button
        setTimeout(function() { GS.uri.Uri.goToPage(window.location.protocol + '//' + window.location.host +
            '/search/search.page' +
            GS.uri.Uri.getQueryStringFromObject(searchOptions)); }, 1);
    };

    var sportsToolTip = function(){
        $('[data-toggle="tooltip"]').tooltip({'placement': 'bottom'});
    };

    $('.js-guidedSearchSportsIconsButton').on('click', function(){
        var self = $(this);
        var checkbox = self.children(".js-icon");
        var hidden_field = self.children(".js-value");
        var gs_checkBox= self.data('gs-checkbox-value');
        var gs_iconLabel = self.data('gs-checkbox-icon-label');

        if (hidden_field.val()== '') {
            checkbox.removeClass(gs_iconLabel + '-off').addClass(gs_iconLabel + '-on');
            self.addClass('active');
            hidden_field.val(gs_checkBox);
        } else {
            checkbox.removeClass(gs_iconLabel + '-on').addClass(gs_iconLabel + '-off');
            self.removeClass('active');
            hidden_field.val('');
        }
    });

    var setShowFiltersCookieHandler = function() {
        GS.search.setShowFiltersCookieHandler('.js-guided-search-submit'); //state hub browse city links
    };

    GS.forms.toggleCheckboxForCollapsibleBoxOnLoad = toggleCheckboxForCollapsibleBoxOnLoad;
    GS.forms.sportsToolTip = sportsToolTip;
    GS.forms.setShowFiltersCookieHandler = setShowFiltersCookieHandler;
    GS.forms.checkFancyCheckbox = checkFancyCheckbox;
    GS.forms.checkSportsIcon = checkSportsIcon;
});

GS.forms.elements = (function() {
    var checkboxButtonSelector = ".js-checkboxButton";
    var checkboxButtonKeyDataAttr = "checkbox-button-key";
    var checkboxButtonValueDataAttr = "checkbox-button-value";
    var hiddenInputSelector = "input";
    var disableElementTriggerSelector = ".js-disableTriggerElement";
    var disableElementTargetSelector = ".js-disableTarget";
    var disableTriggerAndTargetParent = ".js-disableTriggerAndTargetParent";
    var responsiveRadioSelector = ".js-responsiveRadio";
    var responsiveRadioGroupSelector = ".js-responsiveRadioGroup";
    var editAutocompleteVal = '.js-editAutocompleteVal';
    var selectedAutocompleteVal = '.js-selectedAutocompleteVal';
    var autocompleteContainer = '.js-autocompleteContainer';
    var autocompleteFieldContainer = '.js-autocompleteFieldContainer';
    var doNotSeeResult = '.js-doNotSeeResult';
    var selectListsContianer = '.js-selectListsContainer';
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

    var setCheckboxButtonHandler = function(parentListenerSelector) {
        $(parentListenerSelector).on(click, checkboxButtonSelector, function() {
            var $self = $(this);
            var $hiddenField = $self.is('input') == true ? $self : $self.find(hiddenInputSelector);

            if ($hiddenField.val() == '') {
                var key = $self.data(checkboxButtonKeyDataAttr);
                var value = $self.data(checkboxButtonValueDataAttr);
                $hiddenField.attr("value", value).attr("name", key);
            } else {
                $hiddenField.removeAttr("value").removeAttr("name");
            }
        })
    };

    var disableElementAndChildInputs = function($elements) {
        toggleElementAndChildInputs($elements, true);
    };

    var enableElementAndChildInputs = function($elements) {
        toggleElementAndChildInputs($elements, false);
    };

    var toggleElementAndChildInputs = function($elements, bool) {
        if (typeof $elements == 'string') $elements = $($elements);

        $elements.attr('disabled', bool);
        $elements.find(hiddenInputSelector).attr('disabled', bool)
    };

    var toggleTriggerElementAndChildInputs = function($trigger, disableWhenActive) {
        disableWhenActive = disableWhenActive || false;
        var $parent = $trigger.closest(disableTriggerAndTargetParent);
        var $targets = $parent.find(disableElementTargetSelector);

        $trigger.hasClass('active') == disableWhenActive ? disableElementAndChildInputs($targets) : enableElementAndChildInputs($targets);
        //The logic above should be if active == true.
        //However bootstrap js seems to executes after this code does, so the active class doesn't get set till after
        //I don't like this solution, but am open to suggestions
    };

    var setEnableDisableElementsAndInputsHandler = function(sectionContainer) {
        $(sectionContainer).on(click, disableElementTriggerSelector, function() {
            var $trigger = $(this);
            toggleTriggerElementAndChildInputs($trigger, false);
        });
    };

    //exceptions could be '.btn' (single), '.btn.btn-toggle' (element with those two classes) '.btn,.btn-toggle' (multiple)
    var clearAllChildActiveClasses = function($element, exceptions) {
        exceptions = exceptions || '';
        if (typeof $element == 'string') $element = $($element);

        $element.find('.active:not(' + exceptions + ')' ).removeClass('active')
    };

    var disableTargetElementsIfTriggerActive = function() {
        var $triggers = $(disableElementTriggerSelector + '.active');
        $triggers.each(function() {
            var $self = $(this);
            //var $parent = $self.closest(disableTriggerAndTargetParent);

            toggleTriggerElementAndChildInputs($self, true);
            //clearAllChildActiveClasses($parent, disableElementTriggerSelector)
        });
    };

    var setResponsiveRadioHandler = function(sectionContainer) {
        $(sectionContainer).on(click, responsiveRadioSelector, function() {
            var $self = $(this);
            var value = $self.data('value');
            var $group = $self.closest(responsiveRadioGroupSelector);

            //Remove active class from other radios
            $group.find(responsiveRadioSelector).not('[data-value=' + value + "]").removeClass('active');
            //Toggle on other(desktop/mobile) button
            $group.find(responsiveRadioSelector + '[data-value=' + value + "]").not(this).button('toggle');
        });
    };

    var setCustomSubmitHandler = function(submitTrigger, formName, sectionContainer, callback) {
        $(sectionContainer).on(click, submitTrigger, function(e) {
            var $form = $('form[name=' + formName + ']');
            if (typeof callback === 'function') callback.call(this, e, $form);
            $form.submit();
        });
    };

    //AUTOCOMPLETE BEGIN
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
            var $selectListsContainer = $autocompleteContainer.find(selectListsContianer);
            var $autocompleteFieldContainer = $autocompleteContainer.find(autocompleteFieldContainer);

            if ($self.text().trim() == $self.data(dataNoResultText)) {
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

    var setStateSelectHandler = function() {
        $(stateSelect).on(change, function() {
            var $stateSelect = $(this);
            var $autocompleteContainer = $stateSelect.closest(autocompleteContainer);
            var state = $stateSelect.val();
            loadCities(state, $autocompleteContainer);
        });

    };

    var showStateSelect = function(state, $autocompleteContainer) {
        var $autocompleteContainer = $(this).closest(autocompleteContainer);
        var $stateSelect = $autocompleteContainer.find(stateSelect);
        var $autocompleteFieldContainer = $autocompleteContainer.find(autocompleteFieldContainer);
        var $selectListsContainer = $autocompleteContainer.find(selectListsContianer);

        $autocompleteFieldContainer.addClass('dn')
        $stateSelect.removeClass('dn');
        $selectListsContainer.removeClass('dn');

    };


    //Call with call or apply on js-dontSeeResult link
    var loadCities = function(state, $autocompleteContainer) {
        var $autocompleteFieldContainer = $autocompleteContainer.find(autocompleteFieldContainer);
        var $selectListsContainer = $autocompleteContainer.find(selectListsContianer);
        var $citySelect = $autocompleteContainer.find(citySelect);
        var $doNotSeeResult = $autocompleteContainer.find(doNotSeeResult);
        $doNotSeeResult.data(dataState, state);

        $.ajax({
            type: 'GET',
            url: "/gsr/ajax/get_cities",
            data: {state: state},
            async: true
        }).done(function(data) {
            $citySelect.find('option').remove();
            $citySelect.append('<option>'+'Select city'+'</option>');
            for(i=0; i < data.length; i++){
                $citySelect.append('<option data-value="'+data[i]+'">'+data[i]+'</option>');
            }
            $autocompleteFieldContainer.addClass('dn')
            $citySelect.removeClass('dn');
            $selectListsContainer.removeClass('dn');
        });
    };

    var setCitySelectedHandler = function() {
        $(autocompleteContainer).on(change, citySelect, function() {
            var $self = $(this);
            var $doNotSeeResult = $self.closest(autocompleteContainer).find(doNotSeeResult);
            var $schoolSelect = $self.siblings(schoolSelect + ':first');
            var state = $doNotSeeResult.data(dataState);
            var city = $self.find(':selected').data('value');
            $doNotSeeResult.data(dataCity, city);
            loadSchools(state, city, $schoolSelect);
        });
    };

    var loadSchools = function(state, city, $schoolSelect) {
        $.ajax({
            type: 'GET',
            url: "/gsr/ajax/get_schools",
            data: {state: state, city: city},
            async: true
        }).done(function(data) {
            $schoolSelect.find('option').remove();
            $schoolSelect.append('<option>'+'Select school'+'</option>');
            for(i=0; i < data.length; i++){
                $schoolSelect.append('<option data-id="'+data[i].id+'" data-value="'+data[i].name+'">'+data[i].name+'</option>');
            }
            $schoolSelect.removeClass('dn');
        });
    };

    var setSchoolSelectedHandler = function() {
        $(autocompleteContainer).on(change, schoolSelect, function() {
            var $self = $(this);
            var schoolName = $self.find(':selected').data('value');
            setAutocompleteVal(schoolName, $(this).closest(selectListsContianer))
        });
    };

    var setSchoolSelectedOspLandingPageHandler = function() {
        $(autocompleteContainer).on(change, schoolSelect, function() {
             $self = $(this);
             schoolId = $self.find(':selected').data('id');
            var $doNotSeeResult = $self.closest(autocompleteContainer).find(doNotSeeResult);
            var state = $doNotSeeResult.data(dataState);
            var city = $doNotSeeResult.data(dataCity);

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

    //AUTOCOMPLETE END

    //AJAX EMAIL VALIDATION START

    var ajaxEmailValidation = function(emailField){
        $.ajax({
            type: 'GET',
            url: "/gsr/validations/email_available",
            data: { email: $('#user_email').val()},
            async: true

        }).done(function( response ) {
            if(response == 'true'){
                $(emailField).addClass('dn');
            } else {
                $(emailField).removeClass('dn');
            }
        });
    };

    var initOspAjaxEmailValidation = function(errorMessage, emailField){
        $(errorMessage).on('change', function(){
            ajaxEmailValidation(emailField);
        });
    };

    //AJAX EMAIL VALIDATION END

    var setConditionalQuestionHandler = function(conditionalQuestionContainer) {
        $(conditionalQuestionContainer).on(keyup, disableElementTriggerSelector, function() {
            toggleDisable($(this), conditionalQuestionContainer);
        });
    }

    var disableTargetElementsIfTriggerEmpty = function(parentContainer) {
        var $triggers = $(disableElementTriggerSelector + '[type=text]');
        $triggers.each(function() {
            toggleDisable($(this), parentContainer);
        });
    };

    var toggleDisable = function($self, parentContainer) {
        var $disableTarget = $self.closest(parentContainer).find(disableElementTargetSelector);
        var $childElements = $self.closest(parentContainer).children(disableElementTriggerSelector);
        var val = '';
        $.each( $childElements, function(){
            if (val !='') {
                return ;
            } else {
                val = $(this).val();
            }
        });
        val === '' ? disableElementAndChildInputs($disableTarget) : enableElementAndChildInputs($disableTarget);
    }


    return {
        setCheckboxButtonHandler: setCheckboxButtonHandler,
        setEnableDisableElementsAndInputsHandler: setEnableDisableElementsAndInputsHandler,
        disableElementAndChildInputs: disableElementAndChildInputs,
        enableElementAndChildInputs: enableElementAndChildInputs,
        disableTargetElementsIfTriggerActive: disableTargetElementsIfTriggerActive,
        setResponsiveRadioHandler: setResponsiveRadioHandler,
        setCustomSubmitHandler: setCustomSubmitHandler,
        setEditAutocompleteHandler: setEditAutocompleteHandler,
        initOspPageAutocomplete: initOspPageAutocomplete,
        initOspLandingPageAutocomplete: initOspLandingPageAutocomplete,
        initOspAjaxEmailValidation: initOspAjaxEmailValidation,
        setConditionalQuestionHandler: setConditionalQuestionHandler,
        disableTargetElementsIfTriggerEmpty: disableTargetElementsIfTriggerEmpty
    }

})();

$(document).ready(function() {
    GS.forms.toggleCheckboxForCollapsibleBoxOnLoad();
    GS.forms.sportsToolTip();
    GS.forms.setShowFiltersCookieHandler();
});
