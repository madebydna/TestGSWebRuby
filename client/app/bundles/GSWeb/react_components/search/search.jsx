import React from 'react';
import PropTypes from 'prop-types';
import SpinnyWheel from '../spinny_wheel';
import * as google_maps from '../../components/map/google_maps';
import * as google_map_extensions from '../../components/map/google_maps_extensions';
import createInfoWindow from '../../components/map/info_window';
import Map from '../../components/map/map';
import MapMarker from '../../components/map/map_marker';
import DefaultMapMarker from '../../components/map/default_map_marker';
import Polygon from '../district_boundaries/polygon';
import ConnectedSearchBar from '../district_boundaries/connected_search_bar';
import * as markerTypes from '../../components/map/markers';
import * as polygonTypes from '../../components/map/polygons';
import jsxToString from 'jsx-to-string';
import SchoolList from './school_list'

export default class Search extends React.Component {
  static defaultProps = {
  };

  static propTypes = {
    city: PropTypes.string,
    state: PropTypes.string,
    schools: PropTypes.array,
    total: PropTypes.number,
    current_page: PropTypes.number,
    offset: PropTypes.number,
    is_first_page: PropTypes.bool,
    is_last_page: PropTypes.bool,
    index_of_first_item: PropTypes.number,
    index_of_last_item: PropTypes.number,
    result_summary: PropTypes.string,
    pagination_summary: PropTypes.string
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
    }
    this.initGoogleMaps();
  }

  componentDidMount() {
    if(this.props.schoolId && this.props.state) {
      this.props.locateSchool(this.props.state, this.props.schoolId);
    } else if(this.props.districtId && this.props.state) {
      this.props.locateDistrict(this.props.state, this.props.districtId);
    } else if(this.props.lat && this.props.lon) {
      if(this.props.changeLocation) {this.props.changeLocation(this.props.lat, this.props.lon)};
    } else {
      // do nothing
    }
  }

  componentDidUpdate(prevProps, prevState) {
    if(!prevProps.locationChangeFailure && this.props.locationChangeFailure) {
      alert('No results found. Please try a different search.');
      this.props.resetErrors();
    }
    if(!prevProps.apiFailure && this.props.apiFailure) {
      alert('An error occurred. Please try again in a moment.');
      this.props.resetErrors();
    }
  }

  initGoogleMaps() {
    google_maps.init(function() {
      google_map_extensions.init();
      this.setState({
        googleMapsInitialized: true
      });
    }.bind(this));
  }

  renderMarkers() {
    let anySchoolMarkerSelected = false;
    let markers = this.props.schools.map(s => {
      let props = {title: s.name, rating: s.rating, lat: s.lat, lon: s.lon};
      props.key = 's' + s.state + s.id;
      props.createInfoWindow = () => createInfoWindow(s);
      // props.onClick = () => this.props.selectSchool(s.id, s.state);
      if(this.props.school && this.props.school.state == s.state && this.props.school.id == s.id) {
        props.selected = true;
        anySchoolMarkerSelected = true;
      }
      if(s.schoolType == 'private') {
        return <MapMarker type={markerTypes.PRIVATE_SCHOOL} map={this.props.map} {...props} />
      } else {
        return <MapMarker type={markerTypes.PUBLIC_SCHOOL} map={this.props.map} {...props} />
      }
    });
    // markers = markers.concat(this.props.districts.map(d => {
    //   let props = {title: d.name, rating: null, lat: d.lat, lon: d.lon};
    //   props.key = 'd' + d.state + d.id;
    //   props.createInfoWindow = () => createInfoWindow(d);
    //   props.onClick = () => this.props.selectDistrict(d.id, d.state);
    //   if(!anySchoolMarkerSelected && this.props.district && this.props.district.state == d.state && this.props.district.id == d.id) {
    //     props.selected = true;
    //   }
    //   return <MapMarker type={markerTypes.DISTRICT} {...props} />
    // }));
    //DEFAULT LOCATION PIN
    // if (this.props.lat && this.props.lon) {
    //   let props = {lat: this.props.lat, lon: this.props.lon};
    //   props.key = 'locationMarkerl' + this.props.lat + 'l' + this.props.lon;
    //   markers = markers.concat(<DefaultMapMarker {...props} />);
    // }
    return markers;
  }

  renderPolygons() {
    let polygons = [];
    if(this.props.schoolBoundaryCoordinates) {
      let key = 's'+ this.props.school.state + this.props.school.id;
      polygons.push(<Polygon key={key} type={polygonTypes.SCHOOL} coordinates={this.props.schoolBoundaryCoordinates}/>);
    }
    if(this.props.districtBoundaryCoordinates) {
      let key = 'd'+ this.props.district.state + this.props.district.id;
      polygons.push(<Polygon key={key} type={polygonTypes.DISTRICT} coordinates={this.props.districtBoundaryCoordinates}/>);
    }
    return polygons;
  }

  renderMap() {
    if(this.state.googleMapsInitialized) {
      return(
        <Map
          googleMaps={google.maps}
          markers={this.renderMarkers()}
          polygons={this.renderPolygons()}
          changeLocation={this.props.changeLocation}
          hidden={this.state.mapHidden}
          {...this.props}
        />
      );
    } else {
      let content = <div style={{height: '400px', width:'75%',display:'block'}}></div>
      return content;
    }
  };

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

  render() {
    return (
      <div className="search-component">
        <h3>
          <div>{this.props.result_summary}</div>
          <div>{this.props.pagination_summary}</div>
        </h3>
        <div className="right-rail">
          <div className='ad-bar'>Advertisement</div>
        </div>
        <div className="list-and-map">
          <SchoolList schools={this.props.schools} />

          <div className={ this.state.mapHidden ? 'map closed' : 'map'}>
            <SpinnyWheel active={this.state.googleMapsInitialized ? false : true}>
              {this.renderMap()}
            </SpinnyWheel>
          </div>
        </div>
      </div>
    );
  }
}
