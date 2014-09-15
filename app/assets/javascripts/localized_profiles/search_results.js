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
        var maxNumberOfSchools = 4;

        var schoolsList = (function() {
            var schools = []; //is an array of school objects {id, name, rating}
            var state = '';

            var addSchool = function(id, name, rating) {
                for (var i = 0; i < schools.length; i++ ) {
                    if (schools[i]['id'] == parseInt(id)) {
                        return false;
                    }
                }

                schools.push({
                    id: parseInt(id),
                    name: name,
                    rating: rating.toString()
                });
                syncDataWithCookies();
            };

            var syncDataWithCookies = function() {
                $.cookie('compareSchools', JSON.stringify(schools), {path:'/'});
            };

            var removeSchool = function(id) {
                for (var i = schools.length; i > 0; i-- ) {
                    if (schools[i-1]['id'] == parseInt(id)) {
                        schools.splice(i-1, 1);
                    }
                }
                syncDataWithCookies();
            };

            var getSchools = function() {
                return schools;
            };

            var getSchoolIds = function() {
                var ids = [];
                for(var i = 0; i < schools.length; i++) {
                    ids.push(schools[i]['id'])
                }
                return ids;
            };

            var isInSchoolsList = function(id) {
                for (var i = 0; i < schools.length; i++ ) {
                    if (schools[i]['id'] == parseInt(id)) {
                        return true;
                    }
                }
                return false;
            };

            var getState = function() {
                return state
            };

            var numberOfSchoolsInList = function() {
                return schools.length;
            };

            var getSchoolById = function(id) {
                for (var i = 0; i < schools.length; i++ ) {
                    if (schools[i]['id'] == parseInt(id)) {
                        return schools[i];
                    }
                }
                return false;
            };

            var getDataFromCookies = function() {
                //if compareSchoolsState cookie == state on page that way we know the ids in the cookies apply to this state
                var compareSchoolSchools = $.cookie('compareSchools');
                var compareSchoolsState = $.cookie('compareSchoolsState');
                var stateHubCookie = $.cookie('hubState');

                if (compareSchoolSchools != undefined && compareSchoolsState == stateHubCookie) {
                    state = compareSchoolsState;
                    schools = JSON.parse(compareSchoolSchools);
                } else {
                    state = stateHubCookie;
                    $.cookie('compareSchoolsState', stateHubCookie, {path:'/'});
                }
            };

            var init = function() {
                getDataFromCookies();
            };


            return {
                init: init,
                addSchool: addSchool,
                removeSchool: removeSchool,
                numberOfSchoolsInList: numberOfSchoolsInList,
                getSchoolById: getSchoolById,
                isInSchoolsList: isInSchoolsList,
                getState: getState,
                getSchools: getSchools,
                getSchoolIds: getSchoolIds

            }

        })();

        var popupBox = (function() {

            var syncPopupBox = function() {
                //show all elements with data objects
                //hide all elements that don't have data objects

                var schoolIds = schoolsList.getSchoolIds();
                var popupIds = getCompareSchoolsPopupIds();

                for (var i = 0; i < popupIds.length; i++) {
                    var schoolId = parseInt(popupIds[i]);
                    var matchIndex = $.inArray(schoolId, schoolIds);
                    //if matchIndex is less than zero that means school is not displayed
                    if (matchIndex < 0) {
                        removeSchool(schoolId)
                    } else {
                        schoolIds.splice(matchIndex, 1)
                    }
                }

                if (schoolIds.length > 0) {
                    for (var x = 0; x < schoolIds.length; x++) {
                        var school = schoolsList.getSchoolById(schoolIds[x]);
                        addSchool(school);
                    }
                }

                if (schoolsList.numberOfSchoolsInList() == 0) {
                    $('.js-compareSchoolsPopup').hide();
                }
            };

            var getCompareSchoolsPopupIds = function() {
                var popupIds = [];

                $('.js-compareSchoolsPopupSchool').each(function() {
                    var id = $(this).data('schoolid').toString();
                    if (id.length > 0) {
                        popupIds.push(id)
                    }
                });
                return popupIds;
            };

            var addSchool = function(schoolObject) {
                //checks to see if there is space to add school
                var $schoolElement = $($('.js-compareSchoolsPopupSchool.dn')[0]);
                if ($schoolElement.length > 0) {
                    var $schoolRatingElement = $schoolElement.find('.js-compareSchoolsPopupSchoolRating');
                    var $schoolNameElement = $schoolElement.find('.js-compareSchoolsPopupSchoolName');

                    $schoolRatingElement.addClass('i-24-new-ratings-' + schoolObject['rating']);
                    $schoolRatingElement.data('schoolrating', schoolObject['rating']);
                    $schoolNameElement.text(schoolObject['name']);
                    $schoolElement.data('schoolid', schoolObject['id'].toString());
                    $schoolElement.show('slow');
                    $schoolElement.removeClass('dn');
                }
            };

            var removeSchool = function(schoolId) {
                //iterates through each school element to see if the id matches
                $('.js-compareSchoolsPopupSchool').each(function() {
                    var $schoolElement = $(this);
                    if ($schoolElement.data('schoolid') == schoolId) {
                        var $schoolRatingElement = $schoolElement.find('.js-compareSchoolsPopupSchoolRating');
                        var $schoolNameElement = $schoolElement.find('.js-compareSchoolsPopupSchoolName');
                        var schoolRating = $schoolRatingElement.data('schoolrating');

                        $schoolElement.hide();
                        $schoolElement.addClass('dn');
                        $schoolElement.data('schoolid', '');
                        $schoolNameElement.text('');
                        $schoolRatingElement.data('schoolrating', '');
                        $schoolRatingElement.removeClass('i-24-new-ratings-' + schoolRating);
                    }
                });
            };

            var setCompareSchoolsPopupHandler = function() {
                $('.js-compareSchoolsPopupButton').on(clickOrTouchType, function() {
                    if (schoolsList.numberOfSchoolsInList() > 0) {
                        var $popup = $(this).siblings('.js-compareSchoolsPopup');
                        var $container = $('.js-compareSchoolsPopupContainer');
                        if ($popup.css('display') === 'none') {
                            var offset = getPopupOffset($container, $popup);
                            displayPopup($popup, offset);
                        } else {
                            $popup.hide();
                        }
                    }
                });
            };

            var getPopupOffset = function($container, $popup) {
    //          if ($(document).width() <= GS.window.sizing.maxMobileWidth) {
                return $popup.width() - $($container).width(); //parent width

                //ToDo Code below will center the popup box to the button
                //ToDO when we add in Save Schools Button uncommend code below and above
    //          } else {
    //              var parentCenter = $($container).width() / 2;
    //              var popupCenter = $popup.width() / 2;
    //              return popupCenter - parentCenter;
    //          }
            };

            var displayPopup = function($popup, offset) {
                $popup.css('left', '-' + offset + 'px');
                $popup.show();
            };

            var setCompareSchoolsRemoveSchoolHandler = function() {
                $('.js-compareSchoolsPopup').on('click', '.js-compareSchoolsPopupRemoveSchool', function() {
                    var schoolId = $(this).parents('.js-compareSchoolsPopupSchool').data('schoolid');
                    schoolsList.removeSchool(schoolId);
                    syncSchoolCount();
                    toggleOffCompareSchoolButton(schoolId);
                    popupBox.syncPopupBox();
                });
            };

            var setCompareSchoolsRemoveSchoolHoverHandler = function() {
                $('.js-compareSchoolsPopup').on({
                    mouseenter: function () {
                        $(this).removeClass('i-16-blue-x-circle').addClass('i-16-active-x-circle');
                    },
                    mouseleave: function () {
                        $(this).removeClass('i-16-active-x-circle').addClass('i-16-blue-x-circle');
                    }
                }, '.js-compareSchoolsPopupRemoveSchool')
            };

            var init = function() {
                setCompareSchoolsPopupHandler();
                setCompareSchoolsRemoveSchoolHandler();
                setCompareSchoolsRemoveSchoolHoverHandler();
                syncPopupBox();
            };


            return {
                init: init,
                syncPopupBox: syncPopupBox
            }
        })();

        var setCompareSchoolButtonHandler = function() {
            $('.js-searchResultsContainer').on('click', '.js-compareSchoolButton', function() {
                var $school = $(this);
                var schoolId = $school.data('schoolid');
                var schoolName = $school.data('schoolname');
                var schoolRating = $school.data('schoolrating');

                if (schoolsList.isInSchoolsList(schoolId) == true) {
                    schoolsList.removeSchool(schoolId);
                    toggleOffCompareSchoolButton(schoolId);
                } else if (schoolsList.numberOfSchoolsInList() < maxNumberOfSchools) {
                    schoolsList.addSchool(schoolId, schoolName, schoolRating);
                    toggleOnCompareSchoolButton(schoolId);
                }
                popupBox.syncPopupBox();
                syncSchoolCount();
            });
        };

        var toggleOnCompareSchoolsOnPageLoad = function() {
            var ids = schoolsList.getSchoolIds();

            for (var i = 0; i < ids.length; i++) {
                toggleOnCompareSchoolButton(ids[i])
            }
        };

        var toggleOnCompareSchoolButton = function(id) {
            var $school = $('#js-compareSchool' + schoolsList.getState().toUpperCase() + id);
            //check to see if button is on page
            if ($school.length > 0) {
                $school.find('.iconx16').removeClass('i-16-gray-check-bigger').addClass('i-16-green-check-bigger');
                $school.addClass('btn-border-green')
            }
        };

        var toggleOffCompareSchoolButton = function(id) {
            var $school = $('#js-compareSchool' + schoolsList.getState().toUpperCase() + id);
            //check to see if button is on page
            if ($school.length > 0) {
                $school.find('.iconx16').removeClass('i-16-green-check-bigger').addClass('i-16-gray-check-bigger');
                $school.removeClass('btn-border-green')
            }
        };

        var syncSchoolCount = function() {
            var numOfSchools = schoolsList.numberOfSchoolsInList();
            var $schoolCountElement = $('.js-compareSchoolsCount');
            $schoolCountElement.text(numOfSchools);
            numOfSchools > 0 ? $schoolCountElement.addClass('brand-primary') : $schoolCountElement.removeClass('brand-primary')
        };

        var setCompareSchoolsSubmitHandler = function() {
            $('.js-compareSchoolsSubmit').on('click', function() {
                var ids = schoolsList.getSchoolIds();
                var url = '/gsr/school-comparison-tool/results.page?school_ids=' + ids.toString();

                GS.uri.Uri.goToPage(url);
            });
        };

        var init = function() {
            //schoolslist needs to initialize before popupbox, so popupbox can get the data
            schoolsList.init();
            popupBox.init();
            syncSchoolCount();
            setCompareSchoolButtonHandler();
            setCompareSchoolsSubmitHandler();
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

$(document).ready(function() {
    if($('.js-submitSearchFiltersForm').length > 0){
        GS.search.results.init();
    }
});
