GS.search = GS.search || {};
GS.search.autocomplete = GS.search.autocomplete || {};

GS.search.autocomplete.handlers = GS.search.autocomplete.handlers || (function() {

    var setOnUpKeyedCallback = function() {
        var isAddress = GS.search.schoolSearchForm.isAddress;
        GS.search.autocomplete.onUpKeyedCallback = function(query) {
            if (isAddress(query)) {
                this.dropdown.close();
            } else if (this.dropdown.isEmpty && query.length >= this.minLength) {
                this.dropdown.update(query);
                this.dropdown.open();
            } else {
                this.dropdown.moveCursorUp();
                this.dropdown.open();
            }
        }
    };

    var setOnDownKeyedCallback = function() {
        var isAddress = GS.search.schoolSearchForm.isAddress;
        GS.search.autocomplete.onDownKeyedCallback = function(query) {
            if (isAddress(query)) {
                this.dropdown.close();
            } else if (this.dropdown.isEmpty && query.length >= this.minLength) {
                this.dropdown.update(query);
                this.dropdown.open();
            } else {
                this.dropdown.moveCursorDown();
                this.dropdown.open();
            }
        }
    };

    var setOnQueryChangedCallback = function() {
        var isAddress = GS.search.schoolSearchForm.isAddress;
        GS.search.autocomplete.onQueryChangedCallback = function(query) {
            this.input.clearHintIfInvalid();
            if (isAddress(query) || query.length == 0 ) {
                this.dropdown.close();
            } else if (query.length >= this.minLength) {
                this.dropdown.update(query);
                this.dropdown.open();
                this._setLanguageDirection();
            }
        }
    };

    return {
        setOnUpKeyedCallback: setOnUpKeyedCallback,
        setOnQueryChangedCallback: setOnQueryChangedCallback,
        setOnDownKeyedCallback: setOnDownKeyedCallback
    }
})();
