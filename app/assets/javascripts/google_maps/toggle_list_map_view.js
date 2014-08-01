$(document).ready(function () {
    var listViewHighlighted = 'i-16-blue-list-view';
    var listViewNormal =      'i-16-grey-list-view';
    var mapViewHighlighted =  'i-16-blue-map-view';
    var mapViewNormal =       'i-16-grey-map-view';
    var elemMapCanvas =      $('#js-map-canvas');
    var elemListViewToggle = $('.js-search-list-view');
    var elemMapViewToggle =  $('.js-search-map-view');
    var elemMapViewMobileToggle =  $('.js-search-toggle-map-view');

    var hideMapView = function() {
        elemMapCanvas.hide('fast');
        elemListViewToggle.find('span').addClass(listViewHighlighted).removeClass(listViewNormal);
        elemMapViewToggle .find('span').addClass(mapViewNormal)      .removeClass(mapViewHighlighted);
        $.cookie('map_view', 'false', { path: '/' });
    };
    var initAndShowMap = function () {
        GS.search.googleMap.init();
        var map = GS.search.googleMap.getMap();
        var center = map.getCenter();
        google.maps.event.trigger(map, 'resize');
        map.setCenter(center);
    };
    var showMapView = function() {
        elemMapCanvas.show('slow',initAndShowMap);
        elemMapViewToggle .find('span').addClass(mapViewHighlighted).removeClass(mapViewNormal);
        elemListViewToggle.find('span').addClass(listViewNormal)    .removeClass(listViewHighlighted);
        $.cookie('map_view', 'true', { path: '/' });
    };
    elemListViewToggle.on("click", hideMapView);
    elemMapViewToggle.on("click", showMapView);
    elemMapViewMobileToggle.on("click", function() {
        var currentlyVisible = (elemMapCanvas.filter(":visible").length == 1);
        if (currentlyVisible) {
            hideMapView();
        } else {
            showMapView();
        }
    });
    if ($.cookie('map_view') === 'false') {
        hideMapView();
    }
});
