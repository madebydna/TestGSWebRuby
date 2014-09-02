GS.search = GS.search || {};
GS.search.results = GS.search.results || (function() {

    var clickOrTouchType = GS.util.clickOrTouchType || 'click';

    var searchFiltersFormSubmissionHandler = function() {
        $('.js-submitSearchFiltersForm').on('click', function(){
            var path = getQueryPath();
            var form = $('.js-searchFiltersFormParent').children('.js-searchFiltersForm');
            var query = buildQuery(form);
            GS.uri.Uri.goToPage(path + query)
        });
    };

    var searchFiltersFormSubmissionMobileHandler = function() {
        $('.js-submitSearchFiltersFormMobile').on('click', function(){
            var path = getQueryPath();
            var form = $('.js-searchFiltersFormParentMobile').children('.js-searchFiltersForm');
            var query = buildQuery(form);
            GS.uri.Uri.goToPage(path + query)
        });
    };

    var buildQuery = function(form) {
        var getParam = GS.uri.Uri.getFromQueryString;
        var distanceSelectBox = form.find('.js-distance-select-box');
        var fields = ['lat', 'lon', 'grades', 'q', 'sort', 'locationSearchString'];
        var queryString = '';

        for (var i = 0; i < fields.length; i++) {
            getParam(fields[i]) == undefined || (queryString += '&' + fields[i] + '=' + getParam(fields[i]));
        }

        queryString += GS.uri.Uri.getQueryStringFromFormElements(form.find('input'));

        if (distanceSelectBox.length > 0) {
            queryString += GS.uri.Uri.getQueryStringFromFormElements(distanceSelectBox)
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

    var closeMenuHandlerSet = false;

    var closeMenuHandler = function() {
        $('html').on(clickOrTouchType, function () {
            $('.js-fitScorePopup').hide();
        });
    };

    var searchResultFitScoreTogglehandler = function() {
        $('.js-searchResultDropdown').on(clickOrTouchType, function() {
            var popup = $(this).siblings('.js-fitScorePopup');
            if (popup.css('display') === 'none') {
                offset = getFitScorePopupOffset.call(this, popup);
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

    var sortBy = function(sortType, query) {
        query = GS.uri.Uri.removeFromQueryString(query, 'sort');
        if (sortType == 'relevance') {
            GS.uri.Uri.reloadPageWithNewQuery(query);
        }
        else {
            var previousSort = GS.uri.Uri.getFromQueryString('sort', query.substring[1]);
            var argumentKey = (query.length > 1) ? '&sort=' : 'sort=';
            GS.uri.Uri.reloadPageWithNewQuery(query + argumentKey + determineSort(sortType, previousSort));
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
            var queryString = $(this).data('query-string');
            var sortType = $(this).val();
            if (sortType != "") {
                sortBy(sortType, queryString);
            }
        });
    };

    var stopClickAndTouchstartEventPropogation = function(selector) {
        $(selector).bind('click touchstart', function (e) { e.stopPropagation() });
    };

    var getQueryPath = function() {
        return GS.uri.Uri.getPath();
    };

    return {
        searchFiltersFormSubmissionHandler:searchFiltersFormSubmissionHandler,
        searchFiltersFormSubmissionMobileHandler: searchFiltersFormSubmissionMobileHandler,
        sortBy: sortBy,
        toggleAdvancedFiltersMenuHandler: toggleAdvancedFiltersMenuHandler,
        searchFilterDropdownHandler: searchFiltersMenuHandler,
        searchFilterMenuMobileHandler: searchFilterMenuMobileHandler,
        searchResultFitScoreTogglehandler: searchResultFitScoreTogglehandler,
        searchSortingSelectTagHandler: searchSortingSelectTagHandler,
        setSearchFilterMenuMobileOffsetFromTop: setSearchFilterMenuMobileOffsetFromTop
    };
})();

$(document).ready(function() {
    if($('.js-submitSearchFiltersForm').length > 0){
        GS.search.results.searchFiltersFormSubmissionHandler();
        GS.search.results.searchFiltersFormSubmissionMobileHandler();
        GS.search.results.toggleAdvancedFiltersMenuHandler();
        GS.search.results.searchFilterDropdownHandler();
        GS.search.results.searchFilterMenuMobileHandler();
        GS.search.results.searchResultFitScoreTogglehandler();
        GS.search.results.searchSortingSelectTagHandler();
        GS.search.results.setSearchFilterMenuMobileOffsetFromTop();
    }
});
