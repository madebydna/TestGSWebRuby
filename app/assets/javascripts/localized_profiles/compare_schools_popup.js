GS.compare = GS.compare || {};

GS.compare.compareSchoolsPopup = GS.compare.compareSchoolsPopup || (function () {
    var schoolsList;
    var minNumberOfSchools;
    var popupHtmlClass = '.js-compareSchoolsPopup';
    var popupButtonHtmlClass = '.js-compareSchoolsPopupButton';
    var popupSchoolHtmlClass = '.js-compareSchoolsPopupSchool';
    var popupSchoolSelectedHtmlClass = '.js-compareSchoolsPopupSchool.js-selected';
    var popupSchoolUnselectedHtmlClass = '.js-compareSchoolsPopupSchool.js-unselected';
    var popupRatingHtmlClass = '.js-compareSchoolsPopupSchoolRating';
    var popupSchoolNameHtmlClass = '.js-compareSchoolsPopupSchoolName';
    var popupContainerHtmlClass = '.js-compareSchoolsPopupContainer';
    var popupRemoveSchoolHtmlClass = '.js-compareSchoolsPopupRemoveSchool';
    var popupSubmitSchoolsHtmlClass = '.js-compareSchoolsSubmit';
    var schoolCountHtmlClass = '.js-compareSchoolsCount';
    var ratingsSpriteHtmlClassRegex = /i-24-new-ratings-\w{1,2}/;

    //show all elements with data objects
    //hide all elements that don't have data objects
    var syncPopupBox = function() {

        var schoolIdsFromList = schoolsList.getSchoolIds();
        var popupIds = getCompareSchoolsPopupIds();

        //hide popup if there are not schools to show and set compareListState to current page's state
        if (schoolIdsFromList.length === 0) {
            schoolsList.setCompareListState(gon.state_abbr);
            $(popupHtmlClass).hide();
        }

        //iterate through popupIds to either remove schools from popup or do nothing
        for (var i = 0; i < popupIds.length; i++) {
            var schoolId = parseInt(popupIds[i]);
            var matchIndex = $.inArray(schoolId, schoolIdsFromList);
            if (matchIndex < 0) {
                //if matchIndex is less than zero that means school is not displayed
                removeSchool(schoolId)
            } else {
                //remove matching school from schoolid array
                //if any schools remaining at the end of the loop,
                //then there are schools that exist in the list that need to be added to the popup
                schoolIdsFromList.splice(matchIndex, 1)
            }
        }

        //add schools that are in list (and not popup) into popup
        if (schoolIdsFromList.length > 0) {
            for (var x = 0; x < schoolIdsFromList.length; x++) {
                var school = schoolsList.getSchoolById(schoolIdsFromList[x]);
                addSchool(school);
            }
        }
    };

    var getCompareSchoolsPopupIds = function() {
        var popupIds = [];

        $(popupSchoolSelectedHtmlClass).each(function() {
            var id = $(this).data('schoolid').toString();
            if (id.length > 0) {
                popupIds.push(id)
            }
        });
        return popupIds;
    };

    var addSchool = function(schoolObject) {
        //checks to see if there is space to add school
        var $schoolElements = $(popupSchoolUnselectedHtmlClass);
        if ($schoolElements.length > 0) {
            var $schoolElement = $($schoolElements[0]);
            var $schoolRatingElement = $schoolElement.find(popupRatingHtmlClass);
            var $schoolNameElement = $schoolElement.find(popupSchoolNameHtmlClass);
            var previousRatingHtmlClass = $schoolRatingElement.attr('class').match(ratingsSpriteHtmlClassRegex);
            if (previousRatingHtmlClass instanceof Array) {
                $schoolRatingElement.removeClass(previousRatingHtmlClass[0]);
            }

            $schoolRatingElement.addClass('i-24-new-ratings-' + schoolObject['rating']);
            $schoolRatingElement.data('schoolrating', schoolObject['rating']);
            $schoolNameElement.text(schoolObject['name']);
            $schoolElement.data('schoolid', schoolObject['id'].toString());
            $schoolElement.show('slow');
            $schoolElement.removeClass('js-unselected');
            $schoolElement.addClass('js-selected');
        }
    };

    var removeSchool = function(schoolId) {
        //iterates through each school element to see if the id matches
        $(popupSchoolHtmlClass).each(function() {
            var $schoolElement = $(this);
            if ($schoolElement.data('schoolid') == schoolId) {
                $schoolElement.hide('slow');
                $schoolElement.addClass('js-unselected');
                $schoolElement.removeClass('js-selected');
            }
        });
    };

    var setCompareSchoolsPopupHandler = function(offsetFunction) {
        var $poupButton = $(popupButtonHtmlClass);
        $poupButton.on('click', function() {
            if (schoolsList.numberOfSchoolsInList() > 0) {
                var $popup = $(this).siblings(popupHtmlClass);
                var $container = $(popupContainerHtmlClass);
                if ($popup.css('display') === 'none') {
                    var offset = typeof offsetFunction === 'function' ? offsetFunction: getPopupOffset($container, $popup);
                    displayPopup($popup, offset);
                } else {
                    $popup.hide();
                }
            }
        });

        var closeHandler = function () {
            $(popupHtmlClass).hide();
        };
        GS.popup.registerCloseHandler(closeHandler);

        $('html').on('click', closeHandler);
        GS.popup.stopClickAndTouchstartEventPropogation($(popupHtmlClass));
        GS.popup.stopClickAndTouchstartEventPropogation($poupButton);
    };

    var getPopupOffset = function($container, $popup) {
        //          if ($(document).width() <= GS.window.sizing.maxMobileWidth) {
        return Math.abs($popup.width() - $($container).width()); //parent width

        //ToDo Code below will center the popup box to the button
        //ToDO when we add in Save Schools Button uncommend code below and above
        //          } else {
        //              var parentCenter = $($container).width() / 2;
        //              var popupCenter = $popup.width() / 2;
        //              return popupCenter - parentCenter;
        //          }
    };

    var displayPopup = function($popup, offset) {
        GS.popup.closeOtherPopups();
        $popup.css('left', '-' + offset + 'px');
        $popup.show();
    };

    var syncSchoolCount = function() {
        var numOfSchools = schoolsList.numberOfSchoolsInList();
        var $schoolCountElement = $(schoolCountHtmlClass);
        $schoolCountElement.text(numOfSchools);
        numOfSchools >= minNumberOfSchools ? $schoolCountElement.addClass('brand-primary') : $schoolCountElement.removeClass('brand-primary')
    };

    var setCompareSchoolsRemoveSchoolHandler = function(removeSchoolHandlerFunction) {
        $(popupHtmlClass).on('click', popupRemoveSchoolHtmlClass, function() {
            var schoolId = $(this).parents(popupSchoolHtmlClass).data('schoolid');
            schoolsList.removeSchool(schoolId);
            if (typeof removeSchoolHandlerFunction === 'function'){
                removeSchoolHandlerFunction(schoolId);
            }
            syncSchoolCount();
            syncPopupBox();
        });
    };

    var setCompareSchoolsRemoveSchoolHoverHandler = function() {
        $(popupHtmlClass).on({
            mouseenter: function () {
                $(this).removeClass('i-16-blue-x-circle').addClass('i-16-active-x-circle');
            },
            mouseleave: function () {
                $(this).removeClass('i-16-active-x-circle').addClass('i-16-blue-x-circle');
            }
        }, popupRemoveSchoolHtmlClass)
    };

    var setCompareSchoolsSubmitHandler = function() {
        $(popupSubmitSchoolsHtmlClass).on('click', function() {
            var ids = schoolsList.getSchoolIds();
            var state = schoolsList.getState();
            var searchUrl = encodeURIComponent(GS.uri.Uri.getPath() + location.search);

            if (ids.length > 0 && state.length > 0) {
                var url = GS.compare.schoolsList.buildCompareURL(searchUrl);
                GS.compare.schoolsList.setComparingSchoolsFlag();
                GS.uri.Uri.goToPage(url);
            }
        });
    };

    //optionally call this method to change jquery selector classes declared at the top
    //elementClasses == {schoolCountElement: '.js-compareSchoolsCount' etc...}
    var setJqueryElementClasses = function(elementClasses) {
        var varNames = Object.keys(elementClasses);
        for (var i = 0; i < varNames.length; i++) {
            var varName = varNames[i];
            //prevent overwriting anything but strings in this case html classes
            if (this.hasOwnProperty(varName) && typeof this[varName] === 'string') {
                this[varName] = elementClasses[varName];
            }
        }
    };

    var init = function(schoolsListObject, minNumOfSchools) {
        schoolsList = schoolsListObject;
        minNumberOfSchools = minNumOfSchools;
        setCompareSchoolsRemoveSchoolHoverHandler();
        setCompareSchoolsSubmitHandler();
        syncPopupBox();
    };

    return {
        init: init,
        syncPopupBox: syncPopupBox,
        setCompareSchoolsRemoveSchoolHandler: setCompareSchoolsRemoveSchoolHandler,
        setCompareSchoolsPopupHandler: setCompareSchoolsPopupHandler,
        setCompareSchoolsSubmitHandler: setCompareSchoolsSubmitHandler,
        syncSchoolCount: syncSchoolCount,
        setJqueryElementClasses: setJqueryElementClasses //optional
    }

})();
