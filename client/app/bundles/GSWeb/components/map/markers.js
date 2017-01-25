import publicSchoolPng from '../../../../../../app/assets/images/icons/google_map_pins/school-pins.png';
import privateSchoolPng from '../../../../../../app/assets/images/icons/google_map_pins/school-pins.png';
import districtPng from '../../../../../../app/assets/images/icons/google_map_pins/district_markers.png';

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
      iconSheet: districtPng,
      width: 45,
      height: 57,
      shape: {
        coord: [1,0, 29,0, 29,31, 1,31],
        type: 'poly'
      }
    }),

    DISTRICT: Object.assign(Object.create(markerFactory), {
      iconSheet: districtPng,
      width: 45,
      height: 57,
      shape: {
        coord: [8,4, 37,4, 37,33, 32,33, 23,42, 14,33, 8,33],
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
