if (gon.pagename == "CompareSchoolsPage") {

    $(document).ready(function () {
        var elemMapCanvas = $('#js-map-canvas');
        GS.search.googleMap.setHeightForMap(200);
        elemMapCanvas.show('fast', GS.search.googleMap.initAndShowMap);
    });
}