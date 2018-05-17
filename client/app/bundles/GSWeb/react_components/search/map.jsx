import React from 'react';
import PropTypes from 'prop-types';
import Map from '../../components/map/map';
import Legend from '../../components/map/legend';
import SpinnyOverlay from '../spinny_overlay';
import { createMarkersFromSchools } from '../../components/map/map_marker';
import School from './school';
import GoogleMapsInitializer from '../../components/map/google_maps_initializer';

const SearchMap = ({ schools, isLoading, ...other }) => (
  <SpinnyOverlay spin={isLoading}>
    {({ createContainer, spinny }) =>
      createContainer(
        <div style={{ width: '100%', height: '100%' }}>
          {spinny}
          <GoogleMapsInitializer>
            {(isInitialized, googleMaps) =>
              isInitialized && (
                <Map
                  googleMaps={googleMaps}
                  markers={createMarkersFromSchools(schools, {}, null)}
                  changeLocation={() => {}}
                  {...other}
                />
              )
            }
          </GoogleMapsInitializer>
          <Legend content={<div>ASSETS/COPY HERE!</div>} />
        </div>
      )
    }
  </SpinnyOverlay>
);

SearchMap.propTypes = {
  schools: PropTypes.arrayOf(PropTypes.shape(School.propTypes)).isRequired,
  isLoading: PropTypes.bool
};

SearchMap.defaultProps = {
  isLoading: false
};

export default SearchMap;
