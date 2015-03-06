GS.search = GS.search || {};

GS.search.setShowFiltersCookieHandler = GS.search.setShowFiltersCookieHandler || function(className) {
    $('body').on('click', className, function() {
        $.cookie('showFiltersMenu', 'true', {path: '/'});
    });
};

GS.search.results = GS.search.results || (function(state_abbr) {
    var stateSwitchLink = '.js-changeSearchState';

    var searchFiltersFormSubmissionHandler = function() {
        var $button = $('.js-submitSearchFiltersForm');
        var $form = $('.js-searchFiltersFormParent').find('.js-searchFiltersForm');
        formSubmissionHandler($button, $form)
    };

    var searchFiltersFormSubmissionMobileHandler = function() {
        var $button = $('.js-submitSearchFiltersFormMobile');
        var $form = $('.js-searchFiltersFormParentMobile').find('.js-searchFiltersForm');
        formSubmissionHandler($button, $form)
    };

    var formSubmissionHandler = function($button, $form) {
        $button.on('click', function(){
            var path = getQueryPath();
            var query = buildQuery($form);
            GS.uri.Uri.goToPage(path + query)
            var custom_link = 'search_submit_filters';
            if ($form.selector.indexOf('Mobile') > -1) {
              custom_link = custom_link + '_mobile';
            }
            GS.track.sendCustomLink(custom_link);
        });
    };

    var filtersQueryString = function($form) {
        return GS.uri.Uri.getQueryStringFromFormElements($form.find('input, .js-distance-select-box, .js-grades-select-box'));
    };

    var buildQuery = function($form) {
        var queryString = filtersQueryString($form);

        var getParam = GS.uri.Uri.getFromQueryString;
        var urlParamsToPreserve = ['lat', 'lon', 'q', 'locationSearchString', 'locationType', 'normalizedAddress'];
        if (shouldPreserveSortParam($form, getParam('sort'))) { urlParamsToPreserve.push('sort'); }
        for (var i = 0; i < urlParamsToPreserve.length; i++) {
            if (getParam(urlParamsToPreserve[i]) != undefined) {
                queryString += '&' + urlParamsToPreserve[i] + '=' + encodeURIComponent(getParam(urlParamsToPreserve[i]));
            }
        }

        if (queryString.length > 0) {
            queryString = '?' + queryString.slice(1, queryString.length)
        }

        return queryString
    };

    var softFiltersSelected = function ($form) {
        var filters = filtersQueryString($form);
        var filterObj = GS.uri.Uri.getQueryData(filters);
        var softFilters = gon.soft_filter_keys;
        for (var i = 0; i < softFilters.length; i++) {
            var filter = softFilters[i];
            var filterWithBrackets = [filter, filter+'%5B%5D', filter+'[]'];
            for (var j = 0; j < filterWithBrackets.length; j++) {
                var filterParam = filterWithBrackets[j];
                if (_.contains(_.keys(filterObj), filterParam)) {
                    return true;
                }
            }
        }
        return false;
    };

    var shouldPreserveSortParam = function ($form, sortParam) {
        if (_.contains(sortParam, 'fit')) {
            return softFiltersSelected($form);
        }
        else {
            return true;
        }
    };

    var searchFiltersMenuHandler = function() {
        $(".js-searchFiltersDropdown").on('click', function() {
            var menu = $('.js-searchFiltersMenu');
            if (menu.css('display') == 'none') {
                GS.popup.closeOtherPopups();
                menu.show();
                GS.track.sendCustomLink('search_open_filters');
            } else {
                menu.hide();
                GS.track.sendCustomLink('search_close_filters');
            }
        });
        GS.popup.registerCloseHandler(function() {$('.js-searchFiltersMenu').hide();});
    };

    var toggleAdvancedFiltersMenuHandler = function() {
        $(".js-advancedFilters").on('click', function () {
            var advancedFiltersMenu = $('.secondaryFiltersColumn');
            if (advancedFiltersMenu.css('display') == 'none') {
                advancedFiltersMenu.show('slow');
                $(this).text('Fewer filters');
                GS.track.sendCustomLink('search_expand_advanced_filters');
            }
            else {
                advancedFiltersMenu.hide('fast');
                $(this).text('More filters');
                GS.track.sendCustomLink('search_collapse_advanced_filters');
            }
        });
    };

    var showOrHideAdvancedFiltersToggle = function() {
        if ($('.secondaryFiltersColumn').length == 0) {
            $(".js-advancedFilters").addClass('dn');
        }
    };

    var searchFilterMenuMobileHandler = function() {
        $(".js-searchFiltersDropdownMobile").on('click', function() {
            if($('.js-searchFiltersMenuMobile').css('left') == '0px') {
              hideFilterMenuMobile();
              GS.track.sendCustomLink('search_close_filters_mobile');
            } else {
              showFilterMenuMobile();
              GS.track.sendCustomLink('search_open_filters_mobile');
            }
        });
        GS.popup.registerCloseHandler(hideFilterMenuMobile);
    };

    var showFilterMenuMobile = function() {
        GS.popup.closeOtherPopups();
        $('.js-searchFiltersMenuMobile').animate({left: '0'}, 'slow');
    };
    var hideFilterMenuMobile = function() {
        $('.js-searchFiltersMenuMobile').animate({left: '-300px'}, 'slow');
    };

    var setSearchFilterMenuMobileOffsetFromTop = function() {
        var filterToolbarHeight = 45;
        if ($('.js-mobileFiltersToolbar').length > 0) {
            var offset = $('.js-mobileFiltersToolbar').offset().top + filterToolbarHeight;
            $('.js-searchFiltersMenuMobile').css('top', offset + 'px');
        }
    };


    var closeMenuHandler = function() {
        $('html').on('click', function () {
            closeFitScorePopup();
        });
    };

    var closeFitScorePopup = function() {
        $('.js-fitScorePopup').hide();
    };

    var searchResultFitScoreTogglehandler = function($optionalParentElement) {
        var closeMenuHandlerSet = false;

        var $searchResultDropdown;
        var $fitScorePopup;
        if ($optionalParentElement) {
            $searchResultDropdown = $optionalParentElement.find('.js-searchResultDropdown');
            $fitScorePopup = $optionalParentElement.find('.js-fitScorePopup');
        } else {
            $searchResultDropdown = $('.js-searchResultDropdown');
            $fitScorePopup = $('.js-fitScorePopup');
        }

        $searchResultDropdown.on('click', function() {
            var popup = $(this).siblings('.js-fitScorePopup');
            if (popup.css('display') === 'none') {
                var offset = getFitScorePopupOffset.call(this, popup);
                GS.popup.closeOtherPopups();
                displayFitScorePopup(popup, offset);
            } else {
                popup.hide()
            }
            if (closeMenuHandlerSet === false) {
                GS.popup.registerCloseHandler(closeFitScorePopup);
                closeMenuHandler();
                closeMenuHandlerSet = true;
            }
        });
        stopClickAndTouchstartEventPropogation($searchResultDropdown);
        stopClickAndTouchstartEventPropogation($fitScorePopup);
    };

    var getFitScorePopupOffset = function(popup) {
        if ($(document).width() <= GS.window.sizing.maxMobileWidth) {
            return popup.width() - $(this).width(); //parent width
        } else {
            var parentCenter = $(this).width() / 2;
            var popupCenter = popup.width() / 2;
            return popupCenter - parentCenter;
        }
    };

    var displayFitScorePopup = function(popup, offset) {
        popup.css('left', '-' + offset + 'px');
        popup.show()
    };

    var sortBy = function(sortType) {
        var query = window.location.search || '';
        if (query.length > 0) {
            query = query.substring(1);
        }

        query = GS.uri.Uri.removeFromQueryString(query, 'sort');
        if (sortType == 'relevance') {
            GS.uri.Uri.reloadPageWithNewQuery(query);
        }
        else {
            var argumentKey = (query.length > 1) ? '&sort=' : 'sort=';
            GS.uri.Uri.reloadPageWithNewQuery(query + argumentKey + determineSort(sortType));
        }
    };

    var determineSort = function(sortType, previousSort) {
        switch(sortType) {
            case 'rating': return 'rating_desc';
            case 'distance': return 'distance_asc';
            case 'fit': return 'fit_desc';
        }
//        if (new RegExp(sortType).test(previousSort)) {
//            return /asc/.test(previousSort) ? sortType + '_desc' : sortType + '_asc';
//        } else {
//            switch(sortType) {
//                case 'rating': return 'rating_desc';
//                case 'distance': return 'distance_asc';
//                case 'fit': return 'fit_desc';
//            }
//        }
    };

    var searchSortingSelectTagHandler = function() {
        $('.js-searchSortingSelectTag').change(function() {
            var sortType = $(this).val();
            if (sortType != "") {
                sortBy(sortType);
            }
        });
    };

    var stopClickAndTouchstartEventPropogation = function(selector) {
        $(selector).bind('click touchstart', function (e) { e.stopPropagation() });
    };

    var getQueryPath = function() {
        return GS.uri.Uri.getPath();
    };

    var compareSchools = function() {
        //max number defined in _compare_schools_popup_.html.erb
        var schoolsList;
        var popupBox;
        var maxNumberOfSchools;
        var minNumberOfSchools;
        var allowCompareSchoolsSelect = true;

        var setCompareSchoolButtonHandler = function() {
            $('.js-searchResultsContainer').on('click', '.js-compareSchoolButton', function() {
                if (allowCompareSchoolsSelect === true ) {
                    allowCompareSchoolsSelect = false; //prevent user from double clicking for animation purposes

                    var $school = $(this);
                    var schoolId = $school.data('schoolid');
                    var schoolName = $school.data('schoolname');
                    var schoolState = $school.data('schoolstate');
                    var schoolRating = $school.data('schoolrating');
                    removeCompareErrorMessages();

                    if (schoolsList.listContainsSchoolId(schoolId) === true) {
                        schoolsList.removeSchool(schoolId);
                        unselectCompareSchool(schoolId);
                    } else if (schoolsList.addSchool(schoolId, schoolState, schoolName, schoolRating)['success']) {
                        selectCompareSchool(schoolId);
                    }
                    else {
                        var schoolAdded = schoolsList.addSchool(schoolId, schoolState, schoolName, schoolRating);
                        var errorMessage = $('.js-compareSchoolsErrorMessage').clone();
                        var that = this;
                        var errorCode = schoolAdded['errorCode'];
                        var state = schoolAdded['data'];
                        var errorMessageText = getCompareErrorMessageText(errorCode, state);
                        var errorKlass = 'js-' + errorCode + 'CompareError';

                        errorMessage.addClass(errorKlass);

                        if (noErrorMessageForCompareButton(that, errorKlass)) {
                            errorMessage.find('.js-compareSchoolErrorText').html(errorMessageText);
                            $(that).parents('.js-schoolSearchResultCompareErrorMessage').before(errorMessage);
                            errorMessage.show('slow');
                        }
                        allowCompareSchoolsSelect = true;
                    }
                    popupBox.setCompareSchoolsSubmitHandler();
                    popupBox.syncPopupBox();
                    popupBox.syncSchoolCount();
                }
            });
        };

        var noErrorMessageForCompareButton = function (compare_button, errorKlass) {
           return $(compare_button).parents('.js-schoolSearchResultCompareErrorMessage').prev(errorKlass).length == 0
        }

        var removeCompareErrorMessages = function () {
            var wrongStateErrors = $('.js-wrongStateCompareError');
            var tooManySchoolsPresentErrors =  $('.js-tooManySchoolsCompareError')
            wrongStateErrors.remove();
            tooManySchoolsPresentErrors.remove();
        };

        var capitalizeState = function(name) {
            if (name === "washington dc") {
                return "Washington DC";
            }
            return name.replace(/(?:^|\s)\S/g, function(c) { return c.toUpperCase(); });
        };

        var getCompareErrorMessageText = function (error_code, state) {
            if (error_code === 'wrongState') {
                var longState = GS.states.name(state);
                var capitalLongState = capitalizeState(longState);
                var wrongStateText = '<strong>' + 'You&#39re currently comparing schools in&nbsp' + capitalLongState + '</strong>' +
                    '<a class="pointer js-compareSchoolsSubmit">' + '&nbspcompare schools now&nbsp' +
                    '</a>' + 'or' +
                    '<a class="pointer js-clearSchoolsSubmit" data-dismiss="alert">' + '&nbspclear schools&nbsp' +
                    '</a>' + '<strong>' +
                    'to compare in this location.' + '</strong>';
                return wrongStateText;
            }
            else if (error_code === 'tooManySchools') {
                var tooManySchoolsText = '<strong>' + 'You&#39ve already selected 4 schools to compare.&nbsp' + '</strong>' +
                    '<a class="pointer js-compareSchoolsSubmit">' + '&nbspCompare schools.' + '</a>';
                return tooManySchoolsText;
            }
        };

        var setCompareRemoveAllSchoolsHandler = function () {
            $('.js-searchResultsContainer').on('click', '.js-clearSchoolsSubmit', function() {
                schoolsList.clearAllSchools();
                schoolsList.setCompareListState(gon.state_abbr);
                popupBox.syncPopupBox();
                popupBox.syncSchoolCount();
                removeCompareErrorMessages();
            });
        };

        var toggleOnCompareSchools = function() {
            var ids = schoolsList.getSchoolIds();

            for (var i = 0; i < ids.length; i++) {
                selectCompareSchool(ids[i]);
            }
        };

        var selectCompareSchool = function(id) {
            var $school = $('.js-compareSchoolButton[data-schoolid=' + id + ']');
            //check to see if button is on page
            if ($school.length > 0) {
                selectCompareSchoolButton($school);
            }
        };

        var selectCompareSchoolButton = function($school, callback) {
            $school.find('.iconx16').removeClass('i-16-check-bigger-off').addClass('i-16-check-bigger-on');
            //$school.addClass('btn-border-green');
            $school.find('.js-compareSchoolsButtonText').text('');
            $school.animate({width: '0px', paddingLeft: '8px'}, 500, function() {
                var $schoolText = $school.siblings('.js-compareSchoolsText');
                $schoolText.addClass('js-buttonSelected');
                syncCompareSchoolsText();
                $schoolText.show();
                allowCompareSchoolsSelect = true;
            });
        };

        var unselectCompareSchool = function(id) {
            var $school = $('.js-compareSchoolButton[data-schoolid=' + id + ']');
            //check to see if button is on page
            if ($school.length > 0) {
                unselectCompareSchoolButton($school);
            }
        };

        var unselectCompareSchoolButton = function($school) {
            var $schoolText = $school.siblings('.js-compareSchoolsText');
            $schoolText.hide();
            $schoolText.removeClass('js-buttonSelected');
            $school.animate({width: '150px', paddingLeft: '20px'},500, function() {
                $school.find('.iconx16').removeClass('i-16-check-bigger-on').addClass('i-16-check-bigger-off');
                $school.removeClass('btn-border-green');
                $school.find('.js-compareSchoolsButtonText').text('Compare');
                syncCompareSchoolsText();
                allowCompareSchoolsSelect = true;
            });
        };

        var syncCompareSchoolsText = function() {
            $('.js-compareSchoolsText.js-buttonSelected').each(function() {
                var $self = $(this);
                if (schoolsList.numberOfSchoolsInList() >= minNumberOfSchools) {
                    $self.find('.js-compareSchoolsSelectMoreSchoolsText').hide();
                    $self.find('.js-compareSchoolsSubmit').show();
                } else {
                    $self.find('.js-compareSchoolsSubmit').hide();
                    $self.find('.js-compareSchoolsSelectMoreSchoolsText').show();
                }
            });
        };

        var setRemovePopupBoxSchoolsHandler = function() {
            popupBox.setCompareSchoolsRemoveSchoolHandler(function(schoolId) {
                unselectCompareSchool(schoolId);
            });
        };

        var init = function() {
            //schoolslist needs to initialize before popupbox, so popupbox can get the data
            schoolsList = GS.compare.schoolsList;
            popupBox = GS.compare.compareSchoolsPopup;
            minNumberOfSchools = $('.js-compareSchoolsPopup').data('min-num-of-compare-schools') || 2;
            maxNumberOfSchools = $('.js-compareSchoolsPopup').data('max-num-of-compare-schools') || 4;
            schoolsList.init(maxNumberOfSchools);
            popupBox.init(schoolsList, minNumberOfSchools);
            popupBox.setCompareSchoolsPopupHandler();
            popupBox.syncSchoolCount();
            setRemovePopupBoxSchoolsHandler();
            setCompareSchoolButtonHandler();
            toggleOnCompareSchools();
            setCompareRemoveAllSchoolsHandler();
        };

        return {
            init: init,
            toggleOnCompareSchools: toggleOnCompareSchools
        }
    }();

    var setShowFiltersHandler = function() {
        GS.search.setShowFiltersCookieHandler('.js-nearbyCity'); //nearby city links
    };

    var setSavedSearchOpenPopupHandler = function() {
        $(".js-savedSearchPopupButton").on('click', function() {
            var $popup = $('.js-savedSearchPopup');
            if ($popup.css('display') == 'none') {
                GS.popup.closeOtherPopups();
                $popup.show();
            } else {
                $popup.hide();
            }
        });

        var closeHandler = function () {
            $('.js-savedSearchPopup').hide();
        };
        GS.popup.registerCloseHandler(closeHandler);
        $('html').on('click', closeHandler);
        GS.popup.stopClickAndTouchstartEventPropogation($('.js-savedSearchPopup'));
        GS.popup.stopClickAndTouchstartEventPropogation($('.js-savedSearchPopupButton'));
    };

    var setSavedSearchSubmitHandler = function() {
        $('.js-savedSearchSubmitButton').on('click', function() {
            attemptSaveSearch();
        })
    };

    var setSavedSearchClosePopupHandler = function() {
        $(".js-savedSearchClosePopup").on('click', function() {
            $('.js-savedSearchPopup').hide();
        });
    };

    var savedSearchParams = function() {
        var params = {
            search_name: $('.js-savedSearchText').val(),
            search_string: $('#js-schoolResultsSearch').val(),
            num_results: $('.js-numOfSchoolsFound').data('num-of-schools-found'),
            url: GS.uri.Uri.getPath() + location.search
        };
        return state_abbr !== undefined ? _.assign(params, {state: state_abbr , city : gon.city_name}) : params
    };

    var attemptSaveSearch = function() {
        var params = savedSearchParams();
        if (saveSearchValid(params) === true) {
            saveSearch(params);
        }
    };

    var saveSearchValid = function(params) {
        if (params['search_name'] === '') {
            displaySaveSearchValidationError('Please name your search');
            return false
        } else {
            return true
        }
    };

    var saveSearch = function(params) {

        var $deferred = $.post( '/gsr/ajax/saved_search', params);

        $deferred.done(function(response) {
            var error = response['error'];
            var redirect = response['redirect'];

            if (typeof error === 'string' && error !== '' ) {
                displaySaveSearchFailedSaveError(error);   //error
            } else if (redirect != undefined) {
                GS.uri.Uri.goToPage(redirect);    //redirect
            } else {
                disableSavedSearch();             //success
                changeSavedSearchText();
            }
        });

        $deferred.fail(function(response){
            displaySaveSearchFailedSaveError('Currently we are unable to save your search. Please try again later'); //error
        });
    };

    var displaySaveSearchValidationError = function(errorMessage) {
        var $popup = $('.js-savedSearchPopup');
        $popup.find('.js-savedSearchFormGroup').addClass('has-error');
        $popup.find('.js-savedSearchErrorMessage').text(errorMessage).show('');
    };

    var displaySaveSearchFailedSaveError = function(errorMessage) {
        var errorCSSClass = 'js-saveSearchFailedSaveError';

        if ($('.' + errorCSSClass).length === 0) {
            var $markup = $(getErrorMarkupFullWidth(errorMessage, errorCSSClass));
            $('.js-savedSearchPopup').parents('.js-sortingToolbar').before($markup);
        }
    };

    var getErrorMarkupFullWidth = function(errorMessage, errorCSSClass) {
        if (typeof errorMessage === 'string') {
            return '<div class="' + (errorCSSClass || '') + ' limit-width-1200 alert-dismissable alert alert-danger oh mbl">' +
                       '<div class="pull-left mts" style="width: 90%;">' +
                           '<div>' +
                               errorMessage +
                           '</div>' +
                       '</div>' +
                       '<button class="close mtm" type="button" data-dismiss="alert" aria-hidden="true">×</button>' +
                   '</div>'
        }
    };

    var disableSavedSearch = function() {
        $('.js-savedSearchText').text('');
        $('.js-savedSearchPopup').hide();
        $(".js-savedSearchPopupButton").off();
        $(".js-savedSearchSubmitButton").off()
    };

    var changeSavedSearchText = function() {
        $('.js-savedSearchPopupButtonText').fadeOut(200, function() {
            $(this).text('Saved!').fadeIn(200);
        });
    };

    var disableSavedSearchOnLoad = function() {
        if ($.cookie('saved_search') === 'success') {
            disableSavedSearch();
            changeSavedSearchText();
            $.removeCookie("saved_search", { path: '/' });
        }
    };

    //needs to be before click handlers
    var setFastClickHandler = function() {
        FastClick.attach(document.body);
    };

    var setStatePickerHandler = function() {
        $(stateSwitchLink).on('click', function() {
            GS.search.stateAbbreviation = $(this).data().abbreviation;
            GS.search.autocomplete.searchAutocomplete.detachAutocomplete();
            GS.search.autocomplete.searchAutocomplete.init(GS.search.stateAbbreviation);
            $('.js-currentLocationText').html($(this).text());
            GS.track.sendCustomLink('search_change_state');
        });
    };

    var init = function() {
        setFastClickHandler(); //needs to be ahead of click handlers
        searchFiltersFormSubmissionHandler();
        searchFiltersFormSubmissionMobileHandler();
        toggleAdvancedFiltersMenuHandler();
        searchFiltersMenuHandler();
        searchFilterMenuMobileHandler();
        searchResultFitScoreTogglehandler();
        searchSortingSelectTagHandler();
        setSearchFilterMenuMobileOffsetFromTop();
        compareSchools.init();
        GS.search.autocomplete.searchAutocomplete.init(state_abbr);
        setShowFiltersHandler();
        setSavedSearchSubmitHandler();
        setSavedSearchOpenPopupHandler();
        setSavedSearchClosePopupHandler();
        disableSavedSearchOnLoad();
        showOrHideAdvancedFiltersToggle();
        setStatePickerHandler();
    };

    return {
        init: init,
        sortBy: sortBy,
        searchResultFitScoreTogglehandler: searchResultFitScoreTogglehandler,
        toggleOnCompareSchools: compareSchools.toggleOnCompareSchools,
        setStatePickerHandler: setStatePickerHandler
    };
})(gon.state_abbr);

if (gon.pagename == "SearchResultsPage") {
   $(document).ready(function() {
       GS.search.results.init();
   });
}
