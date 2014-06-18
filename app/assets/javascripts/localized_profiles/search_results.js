GS.search = GS.search || {};
GS.search.results = GS.search.results || (function() {

    var pagination = function(query) {
        //TODO handle ajax later
        goToPage(query);
    }

    var goToPage = function(query) {
        console.log(window.location.host + query);
        window.location = "http://" + window.location.host + query;
    };

    return {
        pagination: pagination
    };
})();

//$(document).ready(function() {
//});
