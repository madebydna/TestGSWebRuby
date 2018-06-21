import React from 'react';
import PropTypes from 'prop-types';
import Map from '../../components/map/map';
import { createMarkersFromSchools } from '../../components/map/map_marker';
import School from './school';
import GoogleMapsInitializer from '../../components/map/google_maps_initializer';

const SearchMap = ({ schools, isLoading, ...other }) => (
  <div style={{ width: '100%', height: '100%' }}>
    <GoogleMapsInitializer>
      {(isInitialized, googleMaps) =>
        isInitialized && (
          <Map googleMaps={googleMaps} changeLocation={() => {}} {...other}>
            {({ googleMaps, map, openInfoWindow, fitBounds }) => {
              const markers = createMarkersFromSchools(
                schools,
                {},
                map,
                null,
                openInfoWindow,
                googleMaps
              );
              if (fitBounds) {
                fitBounds(markers);
              }
              return markers;
            }}
          </Map>
        )
      }
    </GoogleMapsInitializer>
  </div>
);

SearchMap.propTypes = {
  schools: PropTypes.arrayOf(PropTypes.shape(School.propTypes)).isRequired,
  isLoading: PropTypes.bool
};

SearchMap.defaultProps = {
  isLoading: false
};

export default SearchMap;
