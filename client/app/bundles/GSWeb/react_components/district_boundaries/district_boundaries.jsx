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

export default class DistrictBoundaries extends React.Component {
  static defaultProps = {
  }

  static propTypes = {
  }

  constructor(props) {
    super(props);
    this.map = null;
    this.initGoogleMaps = this.initGoogleMaps.bind(this);
    this.state = {
      googleMapsInitialized: false,
    }
    this.initGoogleMaps();
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
    let markers = this.props.schools.map(s => {
      let props = {title: s.name, rating: s.rating, lat: s.lat, lon: s.lon};
      props.key = 's' + s.state + s.id;
      props.createInfoWindow = () => createInfoWindow(s);
      props.onClick = () => this.props.selectSchool(s.id, s.state);
      if(this.props.school && this.props.school.state == s.state && this.props.school.id == s.id) {
        props.selected = true;
      }
      if(s.type == 'private') {
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
      return <MapMarker type={markerTypes.DISTRICT} {...props} />
    }));
    return markers;
  }

  renderPolygons() {
    let polygons = [];
    if(this.props.schoolBoundaryCoordinates) {
      let key = 's'+ this.props.district.state + this.props.school.id;
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
        />
      );
    } else {
      let content = <div style={{height: '400px', width:'75%',display:'block'}}></div>
      return (<div><SpinnyWheel content={content}/></div>);
    }
  };

  render() {
    return (
      <div className="district-boundaries-component">
        <ConnectedSearchBar/>
        <SchoolList />
        <div className="map">
          {this.renderMap()}
        </div>

        <div id="districtList"></div>
        <div id="js-districtHeader"></div>
        <div id="schoolList"></div>
        <div className="js_mapLevelCode"></div>
        <div id="searchLocationForm"></div>
        <div id="js_schoolType_private"></div>
        <div id="js_schoolType_charter"></div>
        <div id="js_nearbyHomesForSale"></div>
        <div id="district_name_header"></div>
      </div>
    );
  }
}
