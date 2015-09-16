$(function() {
    if (gon.pagename == GS.compare.compareSchoolsPage.pageName) {
        GS.compare.compareSchoolsPage.init();
        GS.googleMap.addToInitDependencyCallbacks(GS.util.wrapFunction(GS.compare.compareSchoolsPage.initMap, this, []));
    }
});