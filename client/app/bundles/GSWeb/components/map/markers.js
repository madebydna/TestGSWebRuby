import publicSchoolPng from 'icons/google_map_pins/public_school_markers.png';
import privateSchoolPng from 'icons/google_map_pins/private_school_markers.png';
import districtPng from 'icons/google_map_pins/district_markers.png';

export const PUBLIC_SCHOOL = 'PUBLIC_SCHOOL';
export const PRIVATE_SCHOOL = 'PRIVATE_SCHOOL';
export const DISTRICT = 'DISTRICT';

export default function createMarkerFactory(googleMaps) {

  const markerFactory = {
    iconOrigin: function(rating) {
      var offset = this.width * 10;
      if (rating && rating > 0 && rating < 11) {
        offset = this.width * (rating - 1);
      }
      return new googleMaps.Point(offset, 0);
    },

    markerImage: function(rating) {
      return new googleMaps.MarkerImage(
        this.iconSheet,
        new googleMaps.Size(this.width, this.height),
        this.iconOrigin(rating, this.height),
        new googleMaps.Point(this.width/2, this.height)
      );
    },

    createMarker: function(title, rating, lat, lon) {
      let position = new googleMaps.LatLng(lat, lon);
      return new googleMaps.Marker({
        position: position,
        title: title,
        icon: this.markerImage(rating),
        shape: this.shape,
        zIndex: 1
      });
    }
  };

  const markerFactories = {
    PUBLIC_SCHOOL: Object.assign(Object.create(markerFactory), {
      iconSheet: publicSchoolPng,
      width: 31,
      height: 40,
      shape: {
        coord: [1,1, 1,30, 30,30, 30,1],
        type: 'poly'
      }
    }),

    PRIVATE_SCHOOL: Object.assign(Object.create(markerFactory), {
      iconSheet: privateSchoolPng,
      width: 31,
      height: 40,
      shape: {
        coord: [1,15, 15,30, 30,15, 15,1],
        type: 'poly'
      }
    }),

    DISTRICT: Object.assign(Object.create(markerFactory), {
      iconSheet: districtPng,
      width: 31,
      height: 40,
      shape: {
        coord: [1,1, 1,30, 30,30, 30,1],
        type: 'poly'
      }
    })
  };

  return {
    createMarker: (type, ...otherArgs) => { 
      // ... captures remaining args so they can be passed through to method call below
      return markerFactories[type].createMarker(...otherArgs)
    }
  }
}
