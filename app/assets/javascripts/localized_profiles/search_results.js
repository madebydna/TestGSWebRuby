GS.search = GS.search || {};
GS.search.results = GS.search.results || (function() {

    var clickOrTouchType = GS.util.clickOrTouchType || 'click';

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
        });
    };

    var buildQuery = function($form) {
        var queryString = GS.uri.Uri.getQueryStringFromFormElements($form.find('input, .js-distance-select-box'));

        var getParam = GS.uri.Uri.getFromQueryString;
        var urlParamsToPreserve = ['lat', 'lon', 'grades', 'q', 'sort', 'locationSearchString'];
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

    var searchFiltersMenuHandler = function() {
        $(".js-searchFiltersDropdown").on(clickOrTouchType, function() {
            var menu = $('.js-searchFiltersMenu');
            menu.css('display') == 'none' ? menu.show() : menu.hide();
            $('.js-searchFiltersMenuMobile').animate({left: '-300px'});
        });
    };

    var toggleAdvancedFiltersMenuHandler = function() {
        $(".js-advancedFilters").on('click', function () {
            var advancedFiltersMenu = $('.secondaryFiltersColumn');
            if (advancedFiltersMenu.css('display') == 'none') {
                advancedFiltersMenu.show('slow');
                $(this).text('Fewer filters');
            }
            else {
                advancedFiltersMenu.hide('fast');
                $(this).text('More filters');
            }
        });
    };

    var searchFilterMenuMobileHandler = function() {
        $(".js-searchFiltersDropdownMobile").on(clickOrTouchType, function() {
            $('.js-searchFiltersMenuMobile').css('left') == '0px' ? hideFilterMenuMobile() : showFilterMenuMobile();
        });
    };

    var showFilterMenuMobile = function() {
        $('.js-searchFiltersMenu').hide(); //hides desktop menu of screen is resized to mobile and menu is still open
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
        $('html').on(clickOrTouchType, function () {
            $('.js-fitScorePopup').hide();
        });
    };

    var searchResultFitScoreTogglehandler = function() {
        var closeMenuHandlerSet = false;

        $('.js-searchResultDropdown').on(clickOrTouchType, function() {
            var popup = $(this).siblings('.js-fitScorePopup');
            if (popup.css('display') === 'none') {
                var offset = getFitScorePopupOffset.call(this, popup);
                displayFitScorePopup(popup, offset);
            } else {
                popup.hide()
            }
            if (closeMenuHandlerSet === false) {
                closeMenuHandler();
                closeMenuHandlerSet = true;
            }
        });
        stopClickAndTouchstartEventPropogation($('.js-searchResultDropdown'));
        stopClickAndTouchstartEventPropogation($('.js-fitScorePopup'));
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

        var setCompareSchoolButtonHandler = function() {
            $('.js-searchResultsContainer').on('click', '.js-compareSchoolButton', function() {
                var $school = $(this);
                var schoolId = $school.data('schoolid');
                var schoolName = $school.data('schoolname');
                var schoolState = $school.data('schoolstate');
                var schoolRating = $school.data('schoolrating');

                if (schoolsList.listContainsSchoolId(schoolId) === true) {
                    schoolsList.removeSchool(schoolId);
                    toggleGreyCheckMarkSchoolCompareButton(schoolId);
                } else if (schoolsList.numberOfSchoolsInList() < maxNumberOfSchools) {
                    var schoolAdded = schoolsList.addSchool(schoolId, schoolState, schoolName, schoolRating)['success'];
                    if (schoolAdded === true) {
                        toggleGreenCheckmarkSchoolCompareButton(schoolId);
                    } else {
                        //add alert for 'choose only schools from the same state' maybe
                    }
                }
                popupBox.syncPopupBox();
                popupBox.syncSchoolCount();
            });
        };

        var toggleOnCompareSchoolsOnPageLoad = function() {
            var ids = schoolsList.getSchoolIds();

            for (var i = 0; i < ids.length; i++) {
                toggleGreenCheckmarkSchoolCompareButton(ids[i])
            }
        };

        var toggleGreenCheckmarkSchoolCompareButton = function(id) {
            var $school = $('#js-compareSchool' + id);
            //check to see if button is on page
            if ($school.length > 0) {
                $school.find('.iconx16').removeClass('i-16-gray-check-bigger').addClass('i-16-green-check-bigger');
                $school.addClass('btn-border-green')
            }
        };

        var toggleGreyCheckMarkSchoolCompareButton = function(id) {
            var $school = $('#js-compareSchool' + id);
            //check to see if button is on page
            if ($school.length > 0) {
                $school.find('.iconx16').removeClass('i-16-green-check-bigger').addClass('i-16-gray-check-bigger');
                $school.removeClass('btn-border-green')
            }
        };

        var setRemovePopupBoxSchoolsHandler = function() {
            popupBox.setCompareSchoolsRemoveSchoolHandler(function(schoolId) {
                toggleGreyCheckMarkSchoolCompareButton(schoolId);
            });
        };

        var init = function() {
            //schoolslist needs to initialize before popupbox, so popupbox can get the data
            schoolsList = GS.compare.schoolsList;
            popupBox = GS.compare.compareSchoolsPopup;
            maxNumberOfSchools = $('.js-compareSchoolsPopup').data('max-num-of-compare-schools') || 4;
            schoolsList.init(maxNumberOfSchools);
            popupBox.init(schoolsList);
            popupBox.setCompareSchoolsPopupHandler();
            popupBox.syncSchoolCount();
            setRemovePopupBoxSchoolsHandler();
            setCompareSchoolButtonHandler();
            toggleOnCompareSchoolsOnPageLoad();
        };

        return {
            init: init
        }
    }();

    var init = function() {
        searchFiltersFormSubmissionHandler();
        searchFiltersFormSubmissionMobileHandler();
        toggleAdvancedFiltersMenuHandler();
        searchFiltersMenuHandler();
        searchFilterMenuMobileHandler();
        searchResultFitScoreTogglehandler();
        searchSortingSelectTagHandler();
        setSearchFilterMenuMobileOffsetFromTop();
        compareSchools.init();
    };

    return {
        init: init,
        sortBy: sortBy
    };
})();

if (gon.pagename == "SearchResultsPage") {
   $(document).ready(function() {
       GS.search.results.init();
   });
}
