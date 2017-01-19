GS = GS || {}
GS.widget = GS.widget || (function() {

  var GS_MAP_TAB_NAME = "mapTabBody";
  var GS_SEARCH_TAB_NAME = "searchTabBody";
  var GS_HELP_TAB_NAME = "helpTabBody";
  var waitForGeocode = true;

  String.prototype.trim = function () {
    return this.replace(/^\s*/, "").replace(/\s*$/, "");
  }

  // http://www.bytemycode.com/snippets/snippet/406/
  String.prototype.escapeHTML = function ()  {
    return(
        this.replace(/&/g,'&amp;').
        replace(/>/g,'&gt;').
        replace(/</g,'&lt;').
        replace(/"/g,'&quot;')
    );
  };

      // also in customizeSchoolSearchWidget.js
// http://stackoverflow.com/questions/237104/javascript-array-containsobj
  Array.prototype.contains = function(obj) {
    var i = this.length;
    while (i--) {
      if (this[i] === obj) {
        return true;
      }
    }
    return false;
  }

  var init = function(){
    calculateMapHeight();

    $(".gs_tab").on("click", function () {
      $(this).siblings().removeClass('active');
      $(this).addClass('active');
      var value = $(this).data('name');
      if (value == 'tabMap') {
        showMapTab();
      } else {
        showSearchTab();
      }
    });

    $('.question_mark').on('click', function () {
      showHelpTab();
    });
  };
  var calculateMapHeight = function(){
    var mapCanvas = $("#js-map-canvas");
    var mapTabHeight = $("#"+GS_MAP_TAB_NAME).outerHeight(true);
    var mapContainerHeight = $(".js-mapContainer").height();
    var mapCanvasHeight = mapCanvas.height();
    mapCanvas.height(mapCanvasHeight + (mapContainerHeight - mapTabHeight));
  };

  var showMapTab = function() {
    showTab(GS_MAP_TAB_NAME);
    hideTab(GS_SEARCH_TAB_NAME);
    hideTab(GS_HELP_TAB_NAME);
    GS.googleMap.checkResize();
  }

  var showSearchTab= function() {
    hideTab(GS_MAP_TAB_NAME);
    hideTab(GS_HELP_TAB_NAME);
    showTab(GS_SEARCH_TAB_NAME);
  }

  var showHelpTab = function() {
    hideTab(GS_MAP_TAB_NAME);
    hideTab(GS_SEARCH_TAB_NAME);
    showTab(GS_HELP_TAB_NAME);
  }

  var closeHelpTab = function() {
    hideTab(GS_HELP_TAB_NAME);
    showTab(GS_MAP_TAB_NAME);
  }

  var showTab = function(tabId) {
    $('#'+tabId).removeClass('dn');
  }

  var hideTab = function(tabId) {
    $('#'+tabId).addClass('dn');
  }


  function toggleFilter(levelCode, checked, searchQuery) {
    // sq = document.getElementById('searchQuery');
    document.getElementById('filter_' + levelCode + '_value').value = checked;
    // document.getElementById('searchInput').value = sq;

    var noneChecked =
        !document.getElementById('filter_e').checked &&
        !document.getElementById('filter_m').checked &&
        !document.getElementById('filter_h').checked;

    document.getElementById('zoom').value = GS.googleMap.getMap().getZoom();
    document.getElementById('lat').value = GS.googleMap.getMap().getCenter().lat();
    document.getElementById('lon').value = GS.googleMap.getMap().getCenter().lng();

    if (noneChecked) {
      GS.googleMap.removeAllMapMarkers();
    } else {
      document.forms['searchForm'].submit();
    }

  }

  var submitSearch = function() {
    if (!waitForGeocode) {
      return true;
    }

    var noneChecked =
        !document.getElementById('filter_e').checked &&
        !document.getElementById('filter_m').checked &&
        !document.getElementById('filter_h').checked;
    if (document.getElementById('filter_p') != null) {
      noneChecked =
          noneChecked && !document.getElementById('filter_p').checked;
    }
    var newSearch =
        document.getElementById(GS_SEARCH_TAB_NAME) != null &&
        (document.getElementById(GS_SEARCH_TAB_NAME).className == "selected");
    if (noneChecked || newSearch) {
      if (document.getElementById('filter_p_value') != null) {
        document.getElementById('filter_p_value').value = 'true';
      }
      document.getElementById('filter_e_value').value = 'true';
      document.getElementById('filter_m_value').value = 'true';
      document.getElementById('filter_h_value').value = 'true';
    }
    var zoomLevel = GS.googleMap.getMap().getZoom();
    document.getElementById('zoom').value = zoomLevel;

    if (zoomLevel < 10) {        // only reset zoom if this is a user-entered search,
      // not an automatic submission after client-side geocoding
       document.getElementById('zoom').value = 12;
    }

    var searchQuery = document.getElementById('searchInput').value;
    searchQuery = searchQuery.trim();
    document.getElementById('searchInput').value = searchQuery;
    if (searchQuery != '' &&
        searchQuery != 'Enter city & state or zip code') {
      GS.geoCoder.init(searchQuery, function(geocodeResult) {
        if (geocodeResult != null) {
          document.getElementById('lat').value = geocodeResult['lat'];
          document.getElementById('lon').value = geocodeResult['lon'];
          document.getElementById('cityName').value = geocodeResult['city'];
          document.getElementById('state').value = geocodeResult['state'];
          document.getElementById('normalizedAddress').value = geocodeResult['normalizedAddress'];

          waitForGeocode = false;
          return document.forms['searchForm'].submit();
        } else {
          if (document.getElementById('searchInput') != null) {
            document.getElementById('noResultsSearchQuery').innerHTML = document.getElementById('searchInput').value.escapeHTML();
          }
          document.getElementById('noQuery').style.display = 'hidden';
          document.getElementById('noResults').style.display = 'block';
        }
      });
    } else {
      document.getElementById('noQuery').style.display = 'block';
      document.getElementById('noResults').style.display = 'hidden';
    }

    return false;
  }
  return {
    init: init,
    submitSearch: submitSearch,
    toggleFilter: toggleFilter,
    closeHelpTab: closeHelpTab
  }

})();

$(function() {
  GS.widget.init();
});

function textSwitch(el, target, replace) {
  if (el.value == replace) {
    el.value = target;
  }
}
