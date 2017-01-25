GS = GS || {}
GS.geoCoder = GS.geoCoder || (function() {
  var init = function (searchInput, callbackFunction) {
    var geocoder = new google.maps.Geocoder();
    if (geocoder && searchInput) {
      var geocodeOptions = {'address': searchInput};
      if (GS.search.stateAbbreviation != null) {
        geocodeOptions['componentRestrictions'] = {'administrativeArea': GS.search.stateAbbreviation.toUpperCase()};
      } else {
        geocodeOptions['componentRestrictions'] = {'country': 'US'};
      }
      geocoder.geocode(geocodeOptions, function (results, status) {
        var GS_geocodeResults = new Array();
        if (status == google.maps.GeocoderStatus.OK && results.length > 0) {
          for (var x = 0; x < results.length; x++) {
            var geocodeResult = new Array();
            geocodeResult['lat'] = results[x].geometry.location.lat().toFixed(7);
            geocodeResult['lon'] = results[x].geometry.location.lng().toFixed(7);
            geocodeResult['normalizedAddress'] = formatNormalizedAddress(results[x].formatted_address).substring(0, 75);
            geocodeResult['type'] = results[x].types.join().substring(0, 50);
            if (results[x].partial_match) {
              geocodeResult['partial_match'] = true;
            } else {
              geocodeResult['partial_match'] = false;
            }
            for (var i = 0; i < results[x].address_components.length; i++) {
              if (results[x].address_components[i].types.contains('administrative_area_level_1')) {
                geocodeResult['state'] = results[x].address_components[i].short_name.substring(0, 30);
              }
              if (results[x].address_components[i].types.contains('country')) {
                geocodeResult['country'] = results[x].address_components[i].short_name.substring(0, 20);
              }
              if (results[x].address_components[i].types.contains('postal_code')) {
                geocodeResult['zipCode'] = results[x].address_components[i].short_name.substring(0, 15);
              }
              if (results[x].address_components[i].types.contains('locality')) {
                geocodeResult['city'] = results[x].address_components[i].long_name.substring(0, 50);
              }
            }
            // http://stackoverflow.com/questions/1098040/checking-if-an-associative-array-key-exists-in-javascript
            if (!('lat' in geocodeResult && 'lon' in geocodeResult &&
                'state' in geocodeResult &&
                'normalizedAddress' in geocodeResult &&
                'country' in geocodeResult) ||
                geocodeResult['country'] != 'US') {
              geocodeResult = null;
            } else if ('type' in geocodeResult && geocodeResult['type'].indexOf('administrative_area_level_1') > -1) {
              geocodeResult = null; // don't allow states to be returned
            } else if (GS.search.stateAbbreviation != null && geocodeResult['state'].toUpperCase() != GS.search.stateAbbreviation.toUpperCase()) {
              geocodeResult = null; // don't allow results outside of state
            }
            if (geocodeResult != null) {
              GS_geocodeResults.push(geocodeResult);
            }
          }
        }
        if (GS_geocodeResults.length == 0) {
          callbackFunction(null);
        }
        else if (GS_geocodeResults.length == 1) {
          GS_geocodeResults[0]['totalResults'] = 1;
          callbackFunction(GS_geocodeResults[0]);
        }
        else {
          // ignore multiple results
          GS_geocodeResults[0]['totalResults'] = GS_geocodeResults.length;
          callbackFunction(GS_geocodeResults[0]);
        }
      });
    }
  };

  var formatNormalizedAddress = function(address) {
    var newAddress = address.replace(", USA", "");
    var zipCodePattern = /(\d\d\d\d\d)-\d\d\d\d/;
    var matches = zipCodePattern.exec(newAddress);
    if (matches && matches.length > 1) {
      newAddress = newAddress.replace(zipCodePattern, matches[1]);
    }
    return newAddress;
  };

  return {
    init: init
  };
})();