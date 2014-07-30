GS.search = GS.search || {};
GS.search.results = GS.search.results || (function() {

    var searchFiltersFormSubmissionHandler = function() {
        $('#js-submitSearchFiltersForm').on('click', function(){
//          Todo Refactor to build and submit url, as opposed to building and submitting the form
            var self = $('#js-searchFiltersForm');

            var getParam = GS.uri.Uri.getFromQueryString;
            var queryParamters = {};
            var fields = ['lat', 'lon', 'grades', 'q'];

            for (var i = 0; i < fields.length; i++) { getParam(fields[i]) == undefined || (queryParamters[fields[i]] = getParam(fields[i])) }
            GS.uri.Uri.addHiddenFieldsToForm(queryParamters, self);

            if($("#js-distance-select-box").val()=="") {
                $("#js-distance-select-box").remove();
            }

            var formAction = getQueryPath();
            GS.uri.Uri.changeFormAction(formAction, self);
            self.submit();
        });
    };

    var searchFiltersMenuHandler = function() {
        $(".js-searchFiltersDropdown").on('click', function() {
            var menu = $('.js-searchFiltersMenu');
            menu.css('display') == 'none' ? menu.show() : menu.hide();
        })
    };

    var toggleAdvancedFiltersMenuHandler = function() {
        $(".js-advancedFilters").on('click', function () {
            var advancedFiltersMenu = $('.secondaryFiltersColumn');
            advancedFiltersMenu.css('display') == 'none' ? advancedFiltersMenu.show('slow') : advancedFiltersMenu.hide('fast');
        });
    };

    var sortBy = function(sortType, query) {
        var previousSort = GS.uri.Uri.getFromQueryString('sort', query.substring[1]);
        query = GS.uri.Uri.removeFromQueryString(query, 'sort');
        var argumentKey = (query.length > 1) ? '&sort=' : 'sort=';
        GS.uri.Uri.reloadPageWithNewQuery(query + argumentKey + determineSort(sortType, previousSort));
    };

    var determineSort = function(sortType, previousSort) {
        if (new RegExp(sortType).test(previousSort)) {
            return /asc/.test(previousSort) ? sortType + '_desc' : sortType + '_asc';
        } else {
            switch(sortType) {
                case 'rating': return 'rating_desc';
                case 'distance': return 'distance_asc';
                case 'fit': return 'fit_desc';
            }
        }
    };

    var stopClickEventPropagation = function(selector) {
        $(selector).bind('click', function (e) { e.stopPropagation() });
    };

    var getQueryPath = function() {
        return GS.uri.Uri.getPath();
    };

    return {
        searchFiltersFormSubmissionHandler:searchFiltersFormSubmissionHandler,
        sortBy: sortBy,
        toggleAdvancedFiltersMenuHandler: toggleAdvancedFiltersMenuHandler,
        searchFilterDropdownHandler: searchFiltersMenuHandler
    };
})();

$(document).ready(function() {
    GS.search.results.searchFiltersFormSubmissionHandler();
    GS.search.results.toggleAdvancedFiltersMenuHandler();
    GS.search.results.searchFilterDropdownHandler();
});
