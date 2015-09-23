GS.search = GS.search || {};
GS.search.autocomplete = GS.search.autocomplete || {};

//Hooks into the Autocomplete library for various events
//EX. onUpKeyedCallback will execute when the users key is finished clicking
GS.search.autocomplete.handlers = GS.search.autocomplete.handlers || (function() {

    var setOnUpKeyedCallback = function(callback) {
        GS.search.autocomplete.onUpKeyedCallback = callback;
    };

    var setOnDownKeyedCallback = function(callback) {
        GS.search.autocomplete.onDownKeyedCallback = callback;
    };

    var setOnQueryChangedCallback = function(callback) {
        GS.search.autocomplete.onQueryChangedCallback = callback;
    };

    return {
        setOnUpKeyedCallback: setOnUpKeyedCallback,
        setOnQueryChangedCallback: setOnQueryChangedCallback,
        setOnDownKeyedCallback: setOnDownKeyedCallback
    }
})();
