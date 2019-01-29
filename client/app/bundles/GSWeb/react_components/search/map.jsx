import React from 'react';
import PropTypes from 'prop-types';
import Map from '../../components/map/map';
import { createMarkersFromSchools } from '../../components/map/map_marker';
import School from './school';
import GoogleMapsInitializer from '../../components/map/google_maps_initializer';
import LoadingOverlay from './loading_overlay';
import DefaultMapMarker from 'components/map/default_map_marker';
import MapMarker from 'components/map/map_marker';
import createInfoWindow from '../../components/map/info_window';
import SavedSchoolContext from './saved_school_context';
import { debounce } from 'lodash';

const loadMoreSchools = (schools, markers, style, map) => {

}

const SearchMap = ({ schools, isLoading, locationMarker, locationLabel, ...other }) => {
  return <React.Fragment>
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
          <SavedSchoolContext.Consumer>
            {({ saveSchoolCallback, tempFindMoreSchools }) => (
              isInitialized && (
                <Map googleMaps={googleMaps} heartClickCallback={saveSchoolCallback} changeLocation={() => {}} markerDigest={schools.filter(s=>s.schoolType).map(school => school.state + school.id).sort((a,b)=>(a-b)).join('-')} {...other}>
                  {({ googleMaps, map, openInfoWindow, fitBounds, zoomLevel }) => {
                    const style = zoomLevel >= 15 ? 'large' : 'small';
                    const markers = createMarkersFromSchools(
                      schools,
                      {},
                      map,
                      null,
                      openInfoWindow,
                      googleMaps,
                      style,
                      saveSchoolCallback
                    );
                    // event listener for changing bounds
                    if(style && style === 'large'){
                      map.addListener('bounds_changed', () => {
                        if (style === 'large'){
                          const a = map.getBounds();
                          const seen = markers
                            .filter(m => {
                              const b = new googleMaps.LatLng(m.props.lat, m.props.lon)
                              return a.contains(b);
                            })
                            .map(s => [schools[0].state.toLowerCase(),s.props.schoolId])
                          tempFindMoreSchools(seen)
                        }
                      })
                    }
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
                            onClick: m => {
                              openInfoWindow(`${locationLabel.replace(', USA', '')}`, m);
                            },
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
            )}
          </SavedSchoolContext.Consumer>
        }
      </GoogleMapsInitializer>
    </div>
  </React.Fragment>
};

SearchMap.propTypes = {
  schools: PropTypes.arrayOf(PropTypes.object).isRequired,
  isLoading: PropTypes.bool,
  locationMarker: PropTypes.object
};

SearchMap.defaultProps = {
  isLoading: false,
  locationMarker: null
};

export default SearchMap;
