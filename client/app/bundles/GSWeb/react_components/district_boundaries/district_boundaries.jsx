import React from 'react';
import PropTypes from 'prop-types';
import SpinnyWheel from '../spinny_wheel';
import * as google_maps from '../../components/map/google_maps';
import * as google_map_extensions from '../../components/map/google_maps_extensions';
import createInfoWindow from '../../components/map/info_window';
import Map from '../../components/map/map';
import MapMarker from '../../components/map/map_marker';
import DefaultMapMarker from '../../components/map/default_map_marker';
import Polygon from './polygon';
import ConnectedSearchBar from './connected_search_bar';
import * as markerTypes from '../../components/map/markers';
import * as polygonTypes from '../../components/map/polygons';
import SchoolList from './school_list';
import DistrictBoundariesLegend from './district_boundaries_legend';

const markerProps = entity => {
  const props = {
    title: entity.name,
    lat: entity.lat,
    lon: entity.lon,
    svg: false
  };
  if (entity.rating) {
    props.rating = entity.rating;
  }
  return props;
};

export default class DistrictBoundaries extends React.Component {
  static defaultProps = {
    schools: [],
    districts: [],
    school: null,
    district: null,
    selectSchool: () => {},
    selectDistrict: () => {},
    state: null,
    schoolId: null,
    districtId: null,
    locateSchool: () => {},
    locateDistrict: () => {},
    changeLocation: () => {},
    lat: null,
    lon: null,
    resetErrors: () => {},
    apiFailure: false,
    locationChangeFailure: false,
    schoolBoundaryCoordinates: null,
    districtBoundaryCoordinates: null,
    loading: false
  };

  static propTypes = {
    schools: PropTypes.array,
    districts: PropTypes.array,
    school: PropTypes.object,
    district: PropTypes.object,
    selectSchool: PropTypes.func,
    selectDistrict: PropTypes.func,
    state: PropTypes.string,
    schoolId: PropTypes.number,
    districtId: PropTypes.number,
    locateSchool: PropTypes.func,
    locateDistrict: PropTypes.func,
    changeLocation: PropTypes.func,
    lat: PropTypes.number,
    lon: PropTypes.number,
    resetErrors: PropTypes.func,
    apiFailure: PropTypes.bool,
    locationChangeFailure: PropTypes.bool,
    schoolBoundaryCoordinates: PropTypes.array,
    districtBoundaryCoordinates: PropTypes.array,
    loading: PropTypes.bool
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

  componentDidMount() {
    if (this.props.schoolId && this.props.state) {
      this.props.locateSchool(this.props.state, this.props.schoolId);
    } else if (this.props.districtId && this.props.state) {
      this.props.locateDistrict(this.props.state, this.props.districtId);
    } else if (this.props.lat && this.props.lon) {
      this.props.changeLocation(this.props.lat, this.props.lon);
    } else {
      // do nothing
    }
  }

  componentDidUpdate(prevProps) {
    if (!prevProps.locationChangeFailure && this.props.locationChangeFailure) {
      alert('No results found. Please try a different search.');
      this.props.resetErrors();
    }
    if (!prevProps.apiFailure && this.props.apiFailure) {
      alert('An error occurred. Please try again in a moment.');
      this.props.resetErrors();
    }
  }

  initGoogleMaps() {
    google_maps.init(() => {
      google_map_extensions.init();
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

  isSchoolSelected({ state, id }) {
    return (
      this.props.school &&
      this.props.school.state === state &&
      this.props.school.id === id
    );
  }

  isAnySchoolSelected = () =>
    this.props.schools.some(s => this.isSchoolSelected(s));

  isDistrictSelected({ state, id }) {
    return (
      this.props.district &&
      this.props.district.state === state &&
      this.props.district.id === id
    );
  }

  schoolPolygon(otherProps = {}) {
    return this.props.schoolBoundaryCoordinates ? (
      <Polygon
        key={`s${this.props.school.state}${this.props.school.id}`}
        type={polygonTypes.SCHOOL}
        coordinates={this.props.schoolBoundaryCoordinates}
        {...otherProps}
      />
    ) : null;
  }

  districtPolygon(otherProps = {}) {
    return this.props.districtBoundaryCoordinates ? (
      <Polygon
        key={`d${this.props.district.state}${this.props.district.id}`}
        type={polygonTypes.DISTRICT}
        coordinates={this.props.districtBoundaryCoordinates}
        {...otherProps}
      />
    ) : null;
  }

  schoolMarkers(otherProps = {}) {
    const utmCampaignCode = 'districtbrowsemap';

    return this.props.schools.map(s => (
      <MapMarker
        {...markerProps(s)}
        {...otherProps}
        {...{
          key: `s${s.state}${s.id}`,
          openInfoWindow: m =>
            otherProps.openInfoWindow(createInfoWindow(s, utmCampaignCode), m),
          onClick: () => this.props.selectSchool(s.id, s.state),
          selected: this.isSchoolSelected(s),
          type:
            s.schoolType === 'private'
              ? markerTypes.PRIVATE_SCHOOL
              : markerTypes.PUBLIC_SCHOOL
        }}
      />
    ));
  }

  districtMarkers(otherProps = {}) {
    const utmCampaignCode = 'districtbrowsemap';

    return this.props.districts.map(d => (
      <MapMarker
        {...markerProps(d)}
        {...otherProps}
        {...{
          key: `d${d.state}${d.id}`,
          openInfoWindow: m =>
            otherProps.openInfoWindow(createInfoWindow(d, utmCampaignCode), m),
          onClick: () => this.props.selectDistrict(d.id, d.state),
          selected: !this.isAnySchoolSelected() && this.isDistrictSelected(d),
          type: markerTypes.DISTRICT
        }}
      />
    ));
  }

  locationMarker(otherProps = {}) {
    return this.props.lat && this.props.lon ? (
      <DefaultMapMarker
        {...otherProps}
        {...{
          lat: this.props.lat,
          lon: this.props.lon,
          svg: false,
          key: `locationMarkerl${this.props.lat}l${this.props.lon}`
        }}
      />
    ) : null;
  }

  renderMarkers(otherProps = {}) {
    let markers = this.schoolMarkers(otherProps);
    markers = markers.concat(this.districtMarkers(otherProps));
    if (this.props.lat && this.props.lon) {
      markers = markers.concat(this.locationMarker(otherProps));
    }
    return markers;
  }

  renderMap() {
    const google = window.google;
    if (this.state.googleMapsInitialized) {
      return (
        <Map
          googleMaps={google.maps}
          changeLocation={this.props.changeLocation}
          hidden={this.state.mapHidden}
        >
          {({ googleMaps, map, openInfoWindow }) => (
            <React.Fragment>
              {this.renderMarkers({ googleMaps, map, openInfoWindow })}
              {this.schoolPolygon({ googleMaps, map })}
              {this.districtPolygon({ googleMaps, map })}
            </React.Fragment>
          )}
        </Map>
      );
    }
    const content = (
      <div style={{ height: '400px', width: '75%', display: 'block' }} />
    );
    return (
      <div>
        <SpinnyWheel content={content} />
      </div>
    );
  }

  render() {
    return (
      <div className="district-boundaries-component">
        <ConnectedSearchBar
          onClickMapView={this.showMapView}
          onClickListView={this.showListView}
          googleMapsInitialized={this.state.googleMapsInitialized}
          mapSelected={this.state.listHidden}
        />
        {this.props.schools.length > 0 && (
          <SchoolList
            showMapView={this.showMapView}
            className={this.state.listHidden ? 'closed' : ''}
          />
        )}
        <div className={this.state.mapHidden ? 'map closed' : 'map'}>
          <SpinnyWheel active={this.props.loading}>
            {this.renderMap()}
          </SpinnyWheel>
        </div>
      </div>
    );
  }
}
