import React from 'react';
import PropTypes from 'prop-types';
import Map from '../../components/map/map';
import { createMarkersFromSchools } from '../../components/map/map_marker';
import School from './school';
import GoogleMapsInitializer from '../../components/map/google_maps_initializer';
import LoadingOverlay from './loading_overlay';
import DefaultMapMarker from 'components/map/default_map_marker';
import MapMarker from 'components/map/map_marker';

const SearchMap = ({ schools, isLoading, locationMarker, ...other }) => (
  <React.Fragment>
    {
      /* would prefer to just not render overlay if not showing it,
    but then loader gif has delay, and we would need to preload it */
      <LoadingOverlay
        visible={isLoading && schools.length > 0}
        numItems={schools.length}
      />
    }
    <div
      style={{ width: '100%', height: '100%' }}
      className={isLoading ? 'loading' : ''}
    >
      <GoogleMapsInitializer>
        {(isInitialized, googleMaps) =>
          isInitialized && (
            <Map googleMaps={googleMaps} changeLocation={() => {}} markerDigest={schools.map(school => school.state + school.id).sort((a,b)=>(a-b)).join('-')} {...other}>
              {({ googleMaps, map, openInfoWindow, fitBounds }) => {
                const markers = createMarkersFromSchools(
                  schools,
                  {},
                  map,
                  null,
                  openInfoWindow,
                  googleMaps
                );
                if (locationMarker) {
                  markers.push(
                    <MapMarker
                      {...{
                        ...locationMarker,
                        type: 'PUBLIC_SCHOOL',
                        svg: true,
                        address: true,
                        animation: googleMaps.Animation.DROP,
                        key: `locationMarkerl${locationMarker.lat}l${
                          locationMarker.lon
                        }`,
                        map,
                        googleMaps
                      }}
                    />
                  );
                }
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
  </React.Fragment>
);

SearchMap.propTypes = {
  schools: PropTypes.arrayOf(PropTypes.shape(School.propTypes)).isRequired,
  isLoading: PropTypes.bool,
  locationMarker: PropTypes.object
};

SearchMap.defaultProps = {
  isLoading: false,
  locationMarker: null
};

export default SearchMap;
