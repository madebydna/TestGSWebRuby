$(function() {
    if (gon.pagename == "DefaultSearchPage") {
        GS.googleMap.addToInitDependencyCallbacks(GS.util.wrapFunction(GS.search.schoolSearchForm.init, this, []));
        GS.search.autocomplete.searchAutocomplete.init();
    }
});