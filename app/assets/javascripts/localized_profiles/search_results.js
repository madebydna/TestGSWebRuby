GS.search = GS.search || {};
GS.search.results = GS.search.results || (function() {

//  Todo Refactor to build and submit url, as opposed to building and submitting the form
    var searchFiltersFormSubmissionHandler = function() {
        $('.js-submitSearchFiltersForm').on('click', function(){
            var form = $('.js-searchFiltersFormParent').children('.js-searchFiltersForm');
            buildAndSendFiltersForm($(form))
        });
    };

    var searchFiltersFormSubmissionMobileHandler = function() {
        $('.js-submitSearchFiltersFormMobile').on('click', function(){
            var form = $('.js-searchFiltersFormParentMobile').children('.js-searchFiltersForm');
            buildAndSendFiltersForm($(form))
        });
    };

    var buildAndSendFiltersForm = function(form) {
        var getParam = GS.uri.Uri.getFromQueryString;
        var queryParamters = {};
        var fields = ['lat', 'lon', 'grades', 'q', 'sort', 'locationSearchString'];

        for (var i = 0; i < fields.length; i++) { getParam(fields[i]) == undefined || (queryParamters[fields[i]] = getParam(fields[i])) }
        GS.uri.Uri.addHiddenFieldsToForm(queryParamters, form);

        $(".js-distance-select-box").each(function(i) {
            if ($(this).val() == "") {
                $(this).remove();
            }
        });

        var formAction = getQueryPath();
        GS.uri.Uri.changeFormAction(formAction, form);
        form.submit();
    };

    var searchFiltersMenuHandler = function() {
        $(".js-searchFiltersDropdown").on('click', function() {
            var menu = $('.js-searchFiltersMenu');
            menu.css('display') == 'none' ? menu.show() : menu.hide();
            $('.js-searchFiltersMenuMobile').animate({left: '-300px'});
        })
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
        $(".js-searchFiltersDropdownMobile").click(function() {
            $('.js-searchFiltersMenuMobile').css('left') == '0px' ? hideFilterMenuMobile() : showFilterMenuMobile();
        });
    };

    var showFilterMenuMobile = function() {
        $('.js-searchfiltersmenu').hide(); //hides desktop menu of screen is resized to mobile and menu is still open
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

    var searchFilterMenuMobileCloseWindowHandler = function() {
        $(".js-searchFiltersCloseWindow").on('click', function() {
            $('.js-searchFiltersMenuMobile').animate({left: '-300px'}, 'slow');
        });
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

    var stopClickEventPropagation = function(selector) {
        $(selector).bind('click', function (e) { e.stopPropagation() });
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
        searchFilterMenuMobileCloseWindowHandler: searchFilterMenuMobileCloseWindowHandler,
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
        GS.search.results.searchFilterMenuMobileCloseWindowHandler();
        GS.search.results.searchSortingSelectTagHandler();
        GS.search.results.setSearchFilterMenuMobileOffsetFromTop();
    }
});
