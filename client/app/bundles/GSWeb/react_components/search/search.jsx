import React from 'react';
import PropTypes from 'prop-types';
import SpinnyWheel from '../spinny_wheel';
import SpinnyOverlay from '../spinny_overlay';
import * as googleMaps from '../../components/map/google_maps';
import * as googleMapExtensions from '../../components/map/google_maps_extensions';
import createInfoWindow from '../../components/map/info_window';
import Map from '../../components/map/map';
import MapMarker from '../../components/map/map_marker';
import Legend from '../../components/map/legend';
import * as markerTypes from '../../components/map/markers';
import FilterBar from './filter_bar';
import SearchContext from './search_context';
import School from './school';
import SortSelect from './sort_select';

class Search extends React.Component {
  static defaultProps = {
    city: null,
    state: null,
    schools: [],
    loadingSchools: false,
    changeLocation: () => {}
  };

  static propTypes = {
    city: PropTypes.string,
    state: PropTypes.string,
    schools: PropTypes.arrayOf(PropTypes.object),
    result_summary: PropTypes.string.isRequired,
    pagination_summary: PropTypes.string.isRequired,
    address_coordinates: PropTypes.arrayOf(PropTypes.object).isRequired,
    loadingSchools: PropTypes.bool,
    changeLocation: PropTypes.func
  };

  constructor(props) {
    super(props);
    this.map = null;
    this.initGoogleMaps = this.initGoogleMaps.bind(this);
    this.showMapView = this.showMapView.bind(this);
    this.showListView = this.showListView.bind(this);
    this.state = {
      googleMapsInitialized: false,
      listHidden: true
    };
    this.initGoogleMaps();
  }

  initGoogleMaps() {
    googleMaps.init(() => {
      googleMapExtensions.init();
      this.setState({
        googleMapsInitialized: true
      });
    });
  }

  showMapView() {
    this.setState({
      mapHidden: false,
      listHidden: true
    });
  }

  showListView() {
    this.setState({
      mapHidden: true,
      listHidden: false
    });
  }

  renderMap() {
    if (this.state.googleMapsInitialized) {
      return (
        <Map
          googleMaps={google.maps}
          markers={this.renderMarkers()}
          polygons={this.renderPolygons()}
          changeLocation={this.props.changeLocation}
          hidden={this.state.mapHidden}
          {...this.props}
        />
      );
    }
    const content = (
      <div style={{ height: '400px', width: '75%', display: 'block' }} />
    );
    return content;
  }

  renderMarkers() {
    const markers = this.props.schools.map(s => {
      const props = { title: s.name, rating: s.rating, lat: s.lat, lon: s.lon };
      props.key = `s${s.state}${s.id}`;
      props.createInfoWindow = () => createInfoWindow(s);
      // props.onClick = () => this.props.selectSchool(s.id, s.state);
      if (
        this.props.school &&
        this.props.school.state == s.state &&
        this.props.school.id == s.id
      ) {
        props.selected = true;
      }
      if (s.schoolType === 'private') {
        return (
          <MapMarker
            type={markerTypes.PRIVATE_SCHOOL}
            map={this.props.map}
            {...props}
          />
        );
      }
      return (
        <MapMarker
          type={markerTypes.PUBLIC_SCHOOL}
          map={this.props.map}
          {...props}
        />
      );
    });
    return markers;
  }

  render() {
    return (
      <div className="search-component">
        <FilterBar />
        <SortSelect />
        <h3>
          <div>{this.props.result_summary}</div>
          <div>{this.props.pagination_summary}</div>
        </h3>
        <div className="right-rail">
          <div className="ad-bar">Advertisement</div>
        </div>
        <div className="list-and-map">
          <SpinnyOverlay spin={this.props.loadingSchools}>
            {({ createContainer, spinny }) =>
              createContainer(
                <section className="school-list">
                  {spinny}
                  <ol>
                    {this.props.schools.map(s => (
                      <li className={s.active ? 'active' : ''}>
                        <School {...s} />
                      </li>
                    ))}
                  </ol>
                </section>
              )
            }
          </SpinnyOverlay>

          <div className={this.state.mapHidden ? 'map closed' : 'map'}>
            <SpinnyWheel active={!this.state.googleMapsInitialized}>
              {this.renderMap()}
              <Legend content={<div>ASSETS/COPY HERE!</div>} />
            </SpinnyWheel>
          </div>
        </div>
      </div>
    );
  }
}

export default function() {
  return (
    <SearchContext.Provider>
      <SearchContext.Consumer>
        {state => <Search {...state} />}
      </SearchContext.Consumer>
    </SearchContext.Provider>
  );
}
