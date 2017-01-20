// TODO: import google maps
// These functions require that google maps has already been initialized

export function geocode( searchInput ) {
  var deferred = new jQuery.Deferred();
  var geocoder = new google.maps.Geocoder();
  if (geocoder && searchInput) {
    geocoder.geocode({ 'address': searchInput + ' US'}, function(results, status) {
      var numResults = 0;
      var GS_geocodeResults = new Array();
      if (status == google.maps.GeocoderStatus.OK && results.length > 0) {
        numResults = results.length;
        for (var x = 0; x < numResults; x++) {
          var geocodeResult = new Array();
          geocodeResult['lat'] = results[x].geometry.location.lat();
          geocodeResult['lon'] = results[x].geometry.location.lng();
          geocodeResult['normalizedAddress'] =results[x].formatted_address;
          geocodeResult['type'] = results[x].types.join();
          if (results[x].partial_match) {
            geocodeResult['partial_match'] = true;
          } else {
            geocodeResult['partial_match'] = false;
          }
          for (var i = 0; i < results[x].address_components.length; i++) {
            if (results[x].address_components[i].types.contains('administrative_area_level_1')) {
              geocodeResult['state'] = results[x].address_components[i].short_name;
            }
            if (results[x].address_components[i].types.contains('country')) {
              geocodeResult['country'] = results[x].address_components[i].short_name;
            }
          }
          // http://stackoverflow.com/questions/1098040/checking-if-an-associative-array-key-exists-in-javascript
          if (!('lat' in geocodeResult && 'lon' in geocodeResult &&
            'state' in geocodeResult &&
            'normalizedAddress' in geocodeResult &&
            'country' in geocodeResult) ||
            geocodeResult['country'] != 'US') {
              geocodeResult = null;
            }
          if (geocodeResult != null) {
            GS_geocodeResults.push(geocodeResult);
          }
        }

        if (GS_geocodeResults.length>0)
          deferred.resolve(GS_geocodeResults);
        else
          deferred.reject();
      } else {
        deferred.reject();
      }
    });
  } else {
    deferred.reject();
  }
  return deferred.promise();
}

export function geocodeReverse(lat, lng) {
  var deferred = new jQuery.Deferred();
  var geocoder = new google.maps.Geocoder();
  if (geocoder && lat && lng) {
    geocoder.geocode({location: new google.maps.LatLng(lat, lng)}, function (results, status) {
      if (status=='OK'){
        var GS_geocodeResults = new Array();
        for (var i=0; i<results.length; i++) {
          var result = {};
          result.lat = results[i].geometry.location.lat();
          result.lon = results[i].geometry.location.lng();
          result.normalizedAddress = results[i].formatted_address;
          for (var x=0; x<results[i].address_components.length; x++) {
            if (results[i].address_components[x].types.contains('postal_code')){
              result.zip = results[i].address_components[x].long_name;
            }
          }
          GS_geocodeResults.push(result);
        }
        deferred.resolve(GS_geocodeResults);
      } else {
        deferred.reject();
      }
    });
  } else {
    deferred.reject();
  }
  return deferred.promise();
};
