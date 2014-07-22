GS.search = GS.search || {};
GS.search.results = GS.search.results || (function() {

    var init = function() {
        $('.js-searchResultsFilterForm').submit(function() {
            var getParam = GS.uri.Uri.getFromQueryString;
            var queryParamters = {};
            var fields = ['lat', 'lon', 'grades', 'q'];

            for (var i in fields) { getParam(fields[i]) == undefined || (queryParamters[fields[i]] = getParam(fields[i])) }
            GS.uri.Uri.addHiddenFieldsToForm(queryParamters, this);

            if($("#js-distance-select-box").val()=="") {
                $("#js-distance-select-box").remove();
            }

            var formAction = getQueryPath();
            GS.uri.Uri.changeFormAction(formAction, this);
        });
    };

    var advancedFiltersMenuOpen = false;

    var toggleAdvancedFiltersMenuHandler = function() {
        $("#advancedFilters").on('click', function () {
            if (advancedFiltersMenuOpen) {
                advancedFiltersMenuOpen = false;
                closeAdvancedFiltersMenu();
            } else {
                advancedFiltersMenuOpen = true;
                openAdvancedFiltersMenu();
            }
        });
    };

//    ToDo Refactor to be able to handle multiple col sizes dynamically
//    ToDo Add Detection for viewport size
    var openAdvancedFiltersMenu = function() {
        $('#searchResultsFilterMenu').css('width', '768px');
        $('.primaryFiltersColumn').removeClass('col-md-12');
        $('.primaryFiltersColumn').addClass('col-md-4');
        $('.secondaryFiltersColumn').removeClass('dn');
    };

    var closeAdvancedFiltersMenu = function() {
        $('#searchResultsFilterMenu').css('width', '256px');
        $('.primaryFiltersColumn').removeClass('col-md-4');
        $('.primaryFiltersColumn').addClass('col-md-12');
        $('.secondaryFiltersColumn').addClass('dn');
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

    var keepSearchResultsFilterMenuOpen = function() {
        stopClickEventPropagation('#searchResultsFilterMenu');
    };

    var stopClickEventPropagation = function(selector) {
        $(selector).bind('click', function (e) { e.stopPropagation() });
    };

    var getQueryPath = function() {
        return GS.uri.Uri.getPath();
    };

    return {
        init:init,
        sortBy: sortBy,
        keepSearchResultsFilterMenuOpen: keepSearchResultsFilterMenuOpen,
        advancedFiltersMenuOpen: advancedFiltersMenuOpen,
        toggleAdvancedFiltersMenuHandler: toggleAdvancedFiltersMenuHandler
    };
})();

$(document).ready(function() {
    GS.search.results.init();
    GS.search.results.keepSearchResultsFilterMenuOpen();
    GS.search.results.toggleAdvancedFiltersMenuHandler();
});
