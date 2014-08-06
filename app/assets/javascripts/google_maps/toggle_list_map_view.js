$(document).ready(function () {
    var listViewHighlighted = 'i-16-blue-list-view';
    var listViewNormal =      'i-16-grey-list-view';
    var mapViewHighlighted =  'i-16-blue-map-view';
    var mapViewNormal =       'i-16-grey-map-view';
    var elemMapCanvas =      $('#js-map-canvas');
    var elemListViewToggle = $('.js-search-list-view');
    var elemMapViewToggle =  $('.js-search-map-view');
    var elemMapViewMobileToggle =  $('.js-search-toggle-map-view');

    var addActiveToggleStateFor = function (toggleType) {
        if (toggleType == 'list') {
            elemListViewToggle.find('span').addClass(listViewHighlighted).removeClass(listViewNormal);
            elemListViewToggle.addClass('brand-primary');
        }
        else if (toggleType == 'map') {
            elemMapViewToggle .find('span').addClass(mapViewHighlighted).removeClass(mapViewNormal);
            elemMapViewToggle.addClass('brand-primary');
        }
    };
    var removeActiveToggleStateFor = function (toggleType) {
        if (toggleType == 'list') {
            elemListViewToggle.find('span').addClass(listViewNormal)    .removeClass(listViewHighlighted);
            elemListViewToggle.removeClass('brand-primary');
        }
        else if (toggleType == 'map') {
            elemMapViewToggle .find('span').addClass(mapViewNormal)      .removeClass(mapViewHighlighted);
            elemMapViewToggle.removeClass('brand-primary');
        }
    };
    var initAndShowMap = function () {
        GS.search.googleMap.init();
        var map = GS.search.googleMap.getMap();
        var center = map.getCenter();
        google.maps.event.trigger(map, 'resize');
        map.setCenter(center);
    };
    var hideMapView = function() {
        elemMapCanvas.hide('fast');
        addActiveToggleStateFor('list');
        removeActiveToggleStateFor('map');
        $.cookie('map_view', 'false', { path: '/' });
    };
    var showMapView = function() {
        elemMapCanvas.show('slow',initAndShowMap);
        addActiveToggleStateFor('map');
        removeActiveToggleStateFor('list');
        $.cookie('map_view', 'true', { path: '/' });
    };
    elemListViewToggle.on("click", hideMapView);
    elemListViewToggle.hover(
        function () { addActiveToggleStateFor('list') },
        function () {
            if($.cookie('map_view') === 'true') {
                removeActiveToggleStateFor('list');
            }
        }
    );
    elemMapViewToggle.on("click", showMapView);
    elemMapViewToggle.hover(
        function () { addActiveToggleStateFor('map') },
        function () {
            if($.cookie('map_view') === 'false') {
                removeActiveToggleStateFor('map');
            }
        }
    );
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
    else {
        showMapView();
    }
});
