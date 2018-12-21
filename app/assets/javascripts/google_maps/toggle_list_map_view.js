GS.search = GS.search || {};
GS.search.toggleListMapView = GS.search.toggleListMapView || (function () {
        var listViewHighlighted = 'i-16-blue-list-view';
        var listViewNormal = 'i-16-grey-list-view';
        var mapViewHighlighted = 'i-16-blue-map-view';
        var mapViewNormal = 'i-16-grey-map-view';
        var elemMapCanvas = '#js-map-canvas';
        var elemListViewToggle = '.js-search-list-view';
        var elemMapViewToggle = '.js-search-map-view';
        var elemMapViewMobileToggle = '.js-search-toggle-map-view';

        var addActiveToggleStateFor = function (toggleType) {
            if (toggleType == 'list') {
                $(elemListViewToggle).find('span').addClass(listViewHighlighted).removeClass(listViewNormal);
                $(elemListViewToggle).addClass('brand-primary-dark');
            }
            else if (toggleType == 'map') {
                $(elemMapViewToggle).find('span').addClass(mapViewHighlighted).removeClass(mapViewNormal);
                $(elemMapViewToggle).addClass('brand-primary-dark');
            }
        };
        var removeActiveToggleStateFor = function (toggleType) {
            if (toggleType == 'list') {
                $(elemListViewToggle).find('span').addClass(listViewNormal).removeClass(listViewHighlighted);
                $(elemListViewToggle).removeClass('brand-primary-dark');
            }
            else if (toggleType == 'map') {
                $(elemMapViewToggle).find('span').addClass(mapViewNormal).removeClass(mapViewHighlighted);
                $(elemMapViewToggle).removeClass('brand-primary-dark');
            }
        };

        var moveScreenToFilters = function () {
            $('html, body').animate({
                scrollTop: $(".js-mobileFiltersToolbar").offset().top
            }, 700);
        };

        var hideMapView = function () {
            $(elemMapCanvas).hide('fast');
            addActiveToggleStateFor('list');
            removeActiveToggleStateFor('map');
            switchListMapViewTextForMobile('list', 'map');
            Cookies.set('map_view', 'false', { path: '/' });
        };

        var showMapView = function () {
            GS.googleMap.setHeightForMap($(document).width() <= GS.window.sizing.maxMobileWidth ? mapHeightForMobile() : 400);
            moveScreenToFilters();
            $(elemMapCanvas).show('slow', GS.googleMap.initAndShowMap);
            addActiveToggleStateFor('map');
            removeActiveToggleStateFor('list');
            switchListMapViewTextForMobile('map', 'list');
            Cookies.set('map_view', 'true', { path: '/' });
        };

        var mapHeightForMobile = function () {
            toolbarHeight = $(".js-mapContainer").offset().top - $(".js-mobileFiltersToolbar").offset().top - 10; //10 for padding
            return $(window).height() - toolbarHeight;
        };

        var switchListMapViewTextForMobile = function (oldText, newText) {
            var text = $(".js-toggle-list-map-view-text");
            text.siblings('span').removeClass('i-16-white-' + oldText + '-view').addClass('i-16-white-' + newText + '-view');
            text.text(newText.charAt(0).toUpperCase() + newText.slice(1));
        };


    var init = function () {
        if (Cookies.get('map_view') == 'undefined') {
            Cookies.set('map_view', 'false', { path: '/' });
        }
        $(elemListViewToggle).on('click', function() {
            hideMapView();
        });
        $(elemListViewToggle).hover(
            function () {
                addActiveToggleStateFor('list')
            },
            function () {
                if (Cookies.get('map_view') === 'true') {
                    removeActiveToggleStateFor('list');
                }
            }
        );
        $(elemMapViewToggle).on('click', function() {
            showMapView();
        });
        $(elemMapViewToggle).hover(
            function () {
                addActiveToggleStateFor('map')
            },
            function () {
                if (Cookies.get('map_view') === 'false') {
                    removeActiveToggleStateFor('map');
                }
            }
        );
        $(elemMapViewMobileToggle).on('click', function () {
            var currentlyVisible = ($(elemMapCanvas).filter(":visible").length == 1);
            if (currentlyVisible) {
                hideMapView();
            } else {
                showMapView();
            }
        });

        if ($(elemMapCanvas).length > 0) {
            if ( Cookies.get('map_view') === 'true' && $(document).width() > GS.window.sizing.maxMobileWidth) {
                showMapView();
            }
            else {
                hideMapView();
            }
        }
    };

    return {
        init: init
    };

})();
