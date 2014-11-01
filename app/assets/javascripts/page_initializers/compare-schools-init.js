$(function() {
    if (gon.pagename == GS.compare.compareSchoolsPage.pageName) {
        GS.compare.compareSchoolsPage.init();
        GS.googleMap.addToGetScriptCallback(GS.compare.compareSchoolsPage.initMap);
    }
});