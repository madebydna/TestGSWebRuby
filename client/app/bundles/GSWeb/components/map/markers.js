import publicSchoolPng from 'icons/google_map_pins/public_school_markers.png';
import privateSchoolPng from 'icons/google_map_pins/private_school_markers.png';
import districtPng from 'icons/google_map_pins/district_markers.png';
import { t } from '../../util/i18n';
import {
  mapPinColor,
  createDefaultPinWithRating,
  createHighlightedPinWithRating,
  createAssignedPinWithRating,
  createPinWithoutRating,
  createAssignedPinWithoutRating,
  addressPin,
  createAssignedHighlightedPinWithRating,
  createSmallPinMarker
} from './map_pin_assets';

export const PUBLIC_SCHOOL = 'PUBLIC_SCHOOL';
export const PRIVATE_SCHOOL = 'PRIVATE_SCHOOL';
export const DISTRICT = 'DISTRICT';

export default function createMarkerFactory(googleMaps) {
  const markerFactory = {
    iconOrigin(rating) {
      let offset = this.width * 10;
      if (rating && rating > 0 && rating < 11) {
        offset = this.width * (rating - 1);
      }
      return new googleMaps.Point(offset, 0);
    },

    markerImage(rating) {
      return new googleMaps.MarkerImage(
        this.iconSheet,
        new googleMaps.Size(this.width, this.height),
        this.iconOrigin(rating, this.height),
        new googleMaps.Point(this.width / 2, this.height)
      );
    },

    selectPin(rating, color, highlighted, assigned, address, zoomLevel, locationQuery, propertiesCount) {
      if (propertiesCount === 6 || (locationQuery && zoomLevel < 15)){
        return createSmallPinMarker(rating);
      }
      if(locationQuery){
        return createDefaultPinWithRating(rating, color, assigned);
      }
      if (assigned && rating && !highlighted) {
        return createAssignedPinWithRating(rating, color);
      }
      if (assigned && rating && highlighted) {
        return createAssignedHighlightedPinWithRating(rating, color);
      }
      if (rating && highlighted) {
        return createHighlightedPinWithRating(rating, color);
      }
      if (rating) {
        return createDefaultPinWithRating(rating, color, assigned);
      }
      if (address) {
        return addressPin;
      }
      if (assigned) {
        return createAssignedPinWithoutRating(highlighted);
      }
      return createPinWithoutRating(highlighted);
    },

    createMarker(
      title,
      rating,
      lat,
      lon,
      highlighted,
      svg = true,
      assigned,
      address,
      zoomLevel,
      locationQuery,
      propertiesCount
    ) {
      // svg flag intended to permit backwards compatibility while we decide which assets to use for district boundaries tool
      const position = new googleMaps.LatLng(lat, lon);
      const color = mapPinColor(rating);
      let size = null;
      // We know that the light weight pins have less information
      if ((locationQuery && zoomLevel < 15) || propertiesCount === 6){
        size = new googleMaps.Size(15,15);
      }else if(locationQuery){
        size = new googleMaps.Size(40, 50);
      }else if(address){
        size = new googleMaps.Size(25, 34); // address pin
      } else if (assigned && rating) {
        size = new googleMaps.Size(59, 75);
      } else if (assigned && !rating) {
        size = new googleMaps.Size(59, 58);
      } else if (!assigned && rating) {
        size = new googleMaps.Size(40, 50);
      }else if (!assigned && !rating) {
        size = new googleMaps.Size(26, 33);
      }
      let zIndex = 1;
      if (assigned) {
        zIndex = 10;
      }
      return new googleMaps.Marker({
        position,
        title,
        optimized: false,
        icon: svg
          ? {
              url: this.selectPin(
                rating,
                color,
                highlighted,
                assigned,
                address,
                zoomLevel,
                locationQuery,
                propertiesCount
              ),
              scaledSize: size
            }
          : this.markerImage(rating),
        zIndex: zIndex,
        shape: this.shape
      });
    }
  };

  const markerFactories = {
    PUBLIC_SCHOOL: Object.assign(Object.create(markerFactory), {
      iconSheet: publicSchoolPng,
      width: 31,
      height: 40
    }),

    PRIVATE_SCHOOL: Object.assign(Object.create(markerFactory), {
      iconSheet: privateSchoolPng,
      width: 31,
      height: 40
    }),

    DISTRICT: Object.assign(Object.create(markerFactory), {
      iconSheet: districtPng,
      width: 31,
      height: 40
    })
  };

  return {
    createMarker: (type, ...otherArgs) => {
      // ... captures remaining args so they can be passed through to method call below
      return markerFactories[type].createMarker(...otherArgs)
    }
  };
}
