GS.search = GS.search || {};
GS.search.results = GS.search.results || (function() {

    var init = function() {
        $('.js-searchResultsFilterForm').submit(function() {
            var getParam = GS.uri.Uri.getFromQueryString;
            var queryParamters = {};
            var fields = ['lat', 'lon', 'grades', 'distance'];
            for (var i in fields) { getParam(fields[i]) == undefined || (queryParamters[fields[i]] = getParam(fields[i])) }
            GS.uri.Uri.addHiddenFieldsToForm(queryParamters, this)
        });
    };

    var pagination = function(query) {
        //TODO handle ajax later
        GS.uri.Uri.reloadPageWithNewQuery(query);
    };

    var sortBy = function(sort_type, query) {
        var sort = GS.uri.Uri.getFromQueryString('sort', query.substring[1]);
        query = GS.uri.Uri.removeFromQueryString(query, 'sort');
        var argumentKey = (query.length > 1) ? '&sort=' : 'sort=';

        if (/asc/.test(sort)) {
            GS.uri.Uri.reloadPageWithNewQuery(query + argumentKey + sort_type + '_desc');
        } else {
            GS.uri.Uri.reloadPageWithNewQuery(query + argumentKey + sort_type + '_asc');
        }
    };

    var keepSearchResultsFilterMenuOpen = function() {
        stopEventPropagation('#searchResultsFilterMenu');
    };

    var stopEventPropagation = function(selector) {
        $(selector).bind('click', function (e) { e.stopPropagation() });
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
