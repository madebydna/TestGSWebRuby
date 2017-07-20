import React, { PropTypes } from 'react';
import SpinnyWheel from '../spinny_wheel';
import * as google_maps from '../../components/map/google_maps';
import * as google_map_extensions from '../../components/map/google_maps_extensions';
import createInfoWindow from './info_window';
import Map from './map';
import MapMarker from './map_marker';
import Polygon from './polygon';
import ConnectedSearchBar from './connected_search_bar';
import * as markerTypes from '../../components/map/markers';
import * as polygonTypes from '../../components/map/polygons';
import SchoolList from './school_list';
import jsxToString from 'jsx-to-string';
import DistrictBoundariesLegend from './district_boundaries_legend';

export default class DistrictBoundaries extends React.Component {
  static defaultProps = {
  }

  static propTypes = {
  }

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
      this.props.changeLocation(this.props.lat, this.props.lon);
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
      props.onClick = () => this.props.selectSchool(s.id, s.state);
      if(this.props.school && this.props.school.state == s.state && this.props.school.id == s.id) {
        props.selected = true;
        anySchoolMarkerSelected = true;
      }
      if(s.schoolType == 'private') {
        return <MapMarker type={markerTypes.PRIVATE_SCHOOL} {...props} />
      } else {
        return <MapMarker type={markerTypes.PUBLIC_SCHOOL} {...props} />
      }
    });
    markers = markers.concat(this.props.districts.map(d => {
      let props = {title: d.name, rating: d.rating, lat: d.lat, lon: d.lon};
      props.key = 'd' + d.state + d.id;
      props.createInfoWindow = () => createInfoWindow(d);
      props.onClick = () => this.props.selectDistrict(d.id, d.state);
      if(!anySchoolMarkerSelected && this.props.district && this.props.district.state == d.state && this.props.district.id == d.id) {
        props.selected = true;
      }
      return <MapMarker type={markerTypes.DISTRICT} {...props} />
    }));
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
        />
      );
    } else {
      let content = <div style={{height: '400px', width:'75%',display:'block'}}></div>
      return (<div><SpinnyWheel content={content}/></div>);
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
      <div className="district-boundaries-component">
        <DistrictBoundariesLegend legendContainerForCtaId="js-legend-container-for-cta" style={{display: 'none'}}/>
        <ConnectedSearchBar onClickMapView={this.showMapView} onClickListView={this.showListView}
                            googleMapsInitialized={this.state.googleMapsInitialized} mapSelected={this.state.listHidden}/>
        { this.props.schools.length > 0 && 
          <SchoolList showMapView={this.showMapView} className={ this.state.listHidden ? 'closed' : '' } />
        }
          <div className={ this.state.mapHidden ? 'map closed' : 'map'}>
            <SpinnyWheel active={this.props.loading}>
              {this.renderMap()}
            </SpinnyWheel>
          </div>
      </div>
    );
  }
}
