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
  createAssignedHighlightedPinWithRating
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

    selectPin(rating, color, highlighted, assigned, address) {
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
      address
    ) {
      // svg flag intended to permit backwards compatibility while we decide which assets to use for district boundaries tool
      const position = new googleMaps.LatLng(lat, lon);
      const color = mapPinColor(rating);
      return new googleMaps.Marker({
        position,
        title,
        icon: svg
          ? {
              url: this.selectPin(rating, color, highlighted, assigned, address)
            }
          : this.markerImage(rating),
        zIndex: 1,
        shape: this.shape
      });
    }
  };

  const markerFactories = {
    PUBLIC_SCHOOL: Object.assign(Object.create(markerFactory), {
      iconSheet: publicSchoolPng,
      width: 31,
      height: 40,
      shape: {
        coord: [1, 1, 1, 30, 30, 30, 30, 1],
        type: 'poly'
      }
    }),

    PRIVATE_SCHOOL: Object.assign(Object.create(markerFactory), {
      iconSheet: privateSchoolPng,
      width: 31,
      height: 40,
      shape: {
        coord: [1, 15, 15, 30, 30, 15, 15, 1],
        type: 'poly'
      }
    }),

    DISTRICT: Object.assign(Object.create(markerFactory), {
      iconSheet: districtPng,
      width: 31,
      height: 40,
      shape: {
        coord: [1, 1, 1, 30, 30, 30, 30, 1],
        type: 'poly'
      }
    })
  };

  return {
    createMarker: (type, ...otherArgs) =>
      // ... captures remaining args so they can be passed through to method call below
      markerFactories[type].createMarker(...otherArgs)
  };
}
