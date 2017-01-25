var GS_MAP_TAB_NAME = "mapTab";
var GS_SEARCH_TAB_NAME = "searchTab";
var GS_HELP_TAB_NAME = "helpTab";

function showMapTab() {
  showTab(GS_MAP_TAB_NAME);
  hideTab(GS_SEARCH_TAB_NAME);
  hideTab(GS_HELP_TAB_NAME);
  checkResize();
}

function showSearchTab() {
  hideTab(GS_MAP_TAB_NAME);
  hideTab(GS_HELP_TAB_NAME);
  showTab(GS_SEARCH_TAB_NAME);
}

function showHelpTab() {
  hideTab(GS_MAP_TAB_NAME);
  hideTab(GS_SEARCH_TAB_NAME);
  showTab(GS_HELP_TAB_NAME);
}

function closeHelpTab() {
  hideTab(GS_HELP_TAB_NAME);
  showTab(GS_MAP_TAB_NAME);
}

function showTab(tabId) {
  var tabElem = document.getElementById(tabId);
  var tabBodyElem = document.getElementById(tabId + 'Body');
  if (tabElem) {
    tabElem.className = "selected";
  }
  if (tabBodyElem) {
    tabBodyElem.className = "tabBody selected";
  }
}

function hideTab(tabId) {
  var tabElem = document.getElementById(tabId);
  var tabBodyElem = document.getElementById(tabId + 'Body');
  if (tabElem) {
    tabElem.className = "";
  }
  if (tabBodyElem) {
    tabBodyElem.className = "tabBody";
  }
}

function textSwitch(el, target, replace) {
  if (el.value == replace) {
    el.value = target;
  }
}

function toggleFilter(levelCode, checked, searchQuery) {
  document.getElementById('filter_' + levelCode + '_value').value = checked;
  document.getElementById('searchInput').value = searchQuery;

  var noneChecked =
      !document.getElementById('filter_e').checked &&
      !document.getElementById('filter_m').checked &&
      !document.getElementById('filter_h').checked;
  if (document.getElementById('filter_p') != null) {
    noneChecked =
        noneChecked && !document.getElementById('filter_p').checked;
  }

  document.getElementById('zoom').value = GS_map.getZoom();
  document.getElementById('lat').value = GS_map.getCenter().lat();
  document.getElementById('lon').value = GS_map.getCenter().lng();

  if (noneChecked) {
    clearMarkers();
  } else {
    document.forms['searchForm'].submit();
  }

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


String.prototype.trim = function () {
  return this.replace(/^\s*/, "").replace(/\s*$/, "");
}

waitForGeocode = true;

function submitSearch() {
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

  var lat = document.getElementById('lat').value;
  var lon = document.getElementById('lon').value;
  if (lat != 0 && lon != 0) {        // only reset zoom if this is a user-entered search,
    // not an automatic submission after client-side geocoding
    document.getElementById('zoom').value = 0;
  }

  var searchQuery = document.getElementById('searchInput').value;
  searchQuery = searchQuery.trim();
  document.getElementById('searchInput').value = searchQuery;
  if (searchQuery != '' &&
      searchQuery != 'Enter city & state or zip code') {
    gsGeocode(searchQuery, function(geocodeResult) {
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