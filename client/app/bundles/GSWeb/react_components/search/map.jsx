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
            {({ saveSchoolCallback, tempFindMoreSchools, removeInfoWindowOnStartUp }) => (
              isInitialized && (
                <Map googleMaps={googleMaps} 
                  heartClickCallback={saveSchoolCallback} 
                  tempFindMoreSchools={tempFindMoreSchools} 
                  removeInfoWindowOnStartUp={removeInfoWindowOnStartUp} 
                  changeLocation={() => {}} 
                  markerDigest={schools.filter(s=>s.schoolType).map(school => school.state + school.id).sort((a,b)=>(a-b)).join('-')} {...other}>
                  {({ googleMaps, map, openInfoWindow, fitBounds, zoomLevel }) => {
                    let style;
                      if (zoomLevel > 14){
                        style = 'large';
                      }else if(zoomLevel > 12){
                        style = 'medium';
                      }else{
                        style = 'small';
                      }
                    const markers = createMarkersFromSchools(
                      schools,
                      {},
                      map,
                      null,
                      openInfoWindow,
                      googleMaps,
                      style,
                      saveSchoolCallback,
                      tempFindMoreSchools
                    );
                    // event listener for changing bounds
                    if(style && style === 'large'){
                      map.addListener('bounds_changed', (style) => {
                        const a = map.getBounds();
                        const seen = markers
                          .filter(m => {
                            const b = new googleMaps.LatLng(m.props.lat, m.props.lon)
                            return m.props.schoolId && a.contains(b);
                          })
                          .map(s => [schools[0].state.toLowerCase(),s.props.schoolId])
                        tempFindMoreSchools(seen);
                      })
                    }
                    if (style && style !== 'large') { 
                      // TODO: clear listeners for bounds changed when not zoomed in
                      // not ideal as I would like to just remove that single listener
                      // but removeListener wasn't working. May need to revisit
                      googleMaps.event.clearListeners(map, 'bounds_changed');
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
