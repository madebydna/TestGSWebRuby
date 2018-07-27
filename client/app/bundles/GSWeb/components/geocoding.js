// TODO: import google maps
// These functions require that google maps has already been initialized

export function geocode(searchInput) {
  const deferred = new jQuery.Deferred();
  const geocoder = new google.maps.Geocoder();
  if (geocoder && searchInput) {
    geocoder.geocode({ address: `${searchInput} US` }, (results, status) => {
      let numResults = 0;
      const GS_geocodeResults = new Array();
      if (status == google.maps.GeocoderStatus.OK && results.length > 0) {
        numResults = results.length;
        for (let x = 0; x < numResults; x++) {
          let geocodeResult = new Array();
          geocodeResult.lat = results[x].geometry.location.lat();
          geocodeResult.lon = results[x].geometry.location.lng();
          geocodeResult.normalizedAddress = results[x].formatted_address;
          geocodeResult.type = results[x].types.join();
          if (results[x].partial_match) {
            geocodeResult.partial_match = true;
          } else {
            geocodeResult.partial_match = false;
          }
          for (let i = 0; i < results[x].address_components.length; i++) {
            if (results[x].address_components[i].types.contains('locality')) {
              geocodeResult.city = results[x].address_components[i].short_name;
            }
            if (
              results[x].address_components[i].types.contains('postal_code')
            ) {
              geocodeResult.zip = results[x].address_components[i].short_name;
            }
            if (
              results[x].address_components[i].types.contains(
                'administrative_area_level_1'
              )
            ) {
              geocodeResult.state = results[x].address_components[i].short_name;
            }
            if (results[x].address_components[i].types.contains('country')) {
              geocodeResult.country =
                results[x].address_components[i].short_name;
            }
          }
          // http://stackoverflow.com/questions/1098040/checking-if-an-associative-array-key-exists-in-javascript
          if (
            !(
              'lat' in geocodeResult &&
              'lon' in geocodeResult &&
              'state' in geocodeResult &&
              'normalizedAddress' in geocodeResult &&
              'country' in geocodeResult
            ) ||
            geocodeResult.country != 'US'
          ) {
            geocodeResult = null;
          }
          if (geocodeResult != null) {
            GS_geocodeResults.push(geocodeResult);
          }
        }

        if (GS_geocodeResults.length > 0) deferred.resolve(GS_geocodeResults);
        else deferred.reject();
      } else {
        deferred.reject();
      }
    });
  } else {
    deferred.reject();
  }
  return deferred.promise();
}

export function reverseGeocode(lat, lng) {
  const deferred = new jQuery.Deferred();
  const geocoder = new google.maps.Geocoder();
  if (geocoder && lat && lng) {
    geocoder.geocode(
      { location: new google.maps.LatLng(lat, lng) },
      (results, status) => {
        if (status == 'OK') {
          const GS_geocodeResults = new Array();
          for (let i = 0; i < results.length; i++) {
            const result = {};
            result.lat = results[i].geometry.location.lat();
            result.lon = results[i].geometry.location.lng();
            result.normalizedAddress = results[i].formatted_address;
            const stateComponent = results[i].address_components.filter(
              comp => comp.types[0] == 'administrative_area_level_1'
            )[0];
            if (stateComponent) {
              result.state = stateComponent.short_name;
            }
            for (let x = 0; x < results[i].address_components.length; x++) {
              if (
                results[i].address_components[x].types.contains('postal_code')
              ) {
                result.zip = results[i].address_components[x].long_name;
              }
            }
            GS_geocodeResults.push(result);
          }
          deferred.resolve(GS_geocodeResults);
        } else {
          deferred.reject();
        }
      }
    );
  } else {
    deferred.reject();
  }
  return deferred.promise();
}
