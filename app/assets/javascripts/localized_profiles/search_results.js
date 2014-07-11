GS.search = GS.search || {};
GS.search.results = GS.search.results || (function() {

    var init = function() {
        $('.js-searchResultsFilterForm').submit(function() {
            var getParam = GS.uri.Uri.getFromQueryString;
            var queryParamters = {};
            var fields = ['lat', 'lon', 'grades', 'distance', 'q'];

            for (var i in fields) { getParam(fields[i]) == undefined || (queryParamters[fields[i]] = getParam(fields[i])) }
            GS.uri.Uri.addHiddenFieldsToForm(queryParamters, this);

            var formAction = getQueryPath();
            GS.uri.Uri.changeFormAction(formAction, this);
        });
    };

    var pagination = function(query) {
        //TODO handle ajax later
        GS.uri.Uri.reloadPageWithNewQuery(query);
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
        pagination: pagination,
        sortBy: sortBy,
        keepSearchResultsFilterMenuOpen: keepSearchResultsFilterMenuOpen
    };
})();

$(document).ready(function() {
    GS.search.results.init();
    GS.search.results.keepSearchResultsFilterMenuOpen();
});
