GS.search = GS.search || {};
GS.search.results = GS.search.results || (function() {

    var pagination = function(query) {
        //TODO handle ajax later
        goToPage(query);
    };

    var sortBy = function(sort_type, query) {
        var sort = GS.uri.Uri.getFromQueryString('sort', query.substring[1]);
        query = GS.uri.Uri.removeFromQueryString(query, 'sort');
        var argumentKey = (query.length > 1) ? '&sort=' : 'sort=';

        if (/asc/.test(sort)) {
            goToPage(query + argumentKey + sort_type + '_desc');
        } else {
            goToPage(query + argumentKey + sort_type + '_asc');
        }
    };

    var goToPage = function(query) {
        window.location = GS.uri.Uri.getHref().split('?')[0] + query;
    };

    var keepSearchResultsFilterMenuOpen = function() {
        stopEventPropagation('#searchResultsFilterMenu');
    };

    var stopEventPropagation = function(selector) {
        $(selector).bind('click', function (e) { e.stopPropagation() });
    };

    return {
        pagination: pagination,
        sortBy: sortBy,
        keepSearchResultsFilterMenuOpen: keepSearchResultsFilterMenuOpen
    };
})();

$(document).ready(function() {
    GS.search.results.keepSearchResultsFilterMenuOpen();
});
