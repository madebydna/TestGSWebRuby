import React, { PropTypes } from 'react';
import * as google_map_extensions from '../../components/map/google_maps_extensions';
import * as google_maps from '../../components/map/google_maps';
import * as boundaries_jquery_plugin from '../../components/map/jquery_plugin';
import Boundary from '../../components/map/boundaries';
import * as infobox from '../../components/map/infobox';
import { findDOMNode } from 'react-dom';
import School from '../../components/map/school';
import District from '../../components/map/district';
import jsxToString from 'jsx-to-string';
import ConnectedSearchBar from './connected_search_bar';

export default class DistrictBoundaries extends React.Component {
  static defaultProps = {
  }

  static propTypes = {
  }

  constructor(props) {
    super(props);
    this.map = null;
    this.initGoogleMaps = this.initGoogleMaps.bind(this);
    this.updateSchoolMarkers = this.updateSchoolMarkers.bind(this);
    this.updateDistrictMarkers = this.updateDistrictMarkers.bind(this);

    this.state = {
      googleMapsInitialized: false,
      schoolMarkers: {},
      districtMarkers: {},
      schoolPolygon: null,
      districtPolygon: null,
      mapCenter: null
    }
    this.initGoogleMaps();
  }

  createGoogleMap() {
    let mapOptions = {
      center: new google.maps.LatLng(37.77,-122.419),
      zoom: 11,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      mapTypeControl: false
    };
    return new google.maps.Map(this.$map[0], mapOptions);
  }

  initGoogleMaps() {
    google_maps.init(function() {
      google_map_extensions.init();
      infobox.init();
      boundaries_jquery_plugin.init();
      this.map = this.createGoogleMap();
      this.setState({
        googleMapsInitialized: true
      });

      google.maps.event.addDomListener(this.map, 'idle', function() {
        this.setState({mapCenter: this.map.getCenter()});
      }.bind(this));

      google.maps.event.addDomListener(
        this.map, 'drag_end', function() {
          if(this.infoWindow) {
            this.infoWindow.close();
          }
          this.setState({mapCenter: this.map.getCenter()});
        }.bind(this)
      );

      this.map.addListener('click', function(e) {
        if(this.infoWindow) {
          this.infoWindow.close();
        }
        this.props.changeLocation(e.latLng.lat(), e.latLng.lng());
      }.bind(this));

      google.maps.event.addDomListener(
        window, 'resize', () => this.map.setCenter(this.state.mapCenter)
      );
    }.bind(this));
  }

  componentDidMount() {
    this.$map = $(findDOMNode(this.mapDiv));
  }

  onSchoolMarkerClicked(marker, obj) {
    return (e) => {
      this.showInfoWindow(marker, obj);
      this.props.selectSchool(obj.id, obj.state);
    }
  }

  onDistrictMarkerClicked(marker, obj) {
    return (e) => {
      this.showInfoWindow(marker, obj);
      this.props.selectDistrict(obj.id, obj.state);
    }
  }

  updateSchoolMarkers() {
    let schools = this.props.schools;
    let newMarkers = Object.values(schools).reduce((obj, s) => {
      if(s == undefined) return obj;
      let key = [s.state.toLowerCase(), s.id];
      let marker = obj[key] = this.state.schoolMarkers[key] || new School(s).getMarker();
      google.maps.event.addListener(marker, 'click', this.onSchoolMarkerClicked(marker, s));
      return obj;
    }, {});
    this.setState({
      schoolMarkers: newMarkers
    });
  }

  updateDistrictMarkers() {
    let newMarkers = Object.values(this.props.districts).reduce((obj, s) => {
      if(s == undefined) return obj;
      let key = [s.state.toLowerCase(), s.id];
      let marker = obj[key] = this.state.districtMarkers[key] || new District(s).getMarker();
      google.maps.event.addListener(marker, 'click', this.onDistrictMarkerClicked(marker, s));
      return obj;
    }, {});
    this.setState({
      districtMarkers: newMarkers
    });
  }

  showInfoWindow(marker, entity) {
    if(this.infoWindow) {
      this.infoWindow.close();
    }

    let contentString = <div class="rating-container__rating">
      <div class="module-header">
        <div class={'circle-rating--' + entity.rating + ' circle-rating--medium'}>
          {entity.rating}<span class="rating-circle-small">/10</span>
        </div>
        <div class="title-container" style="width:300px">
          <div>
            <span class="title">
              {entity.name}
            </span>
          </div>
          {entity.address &&
            <div>
              <div>{entity.address.street1}</div>
              <div>{entity.address.city}, {entity.address.state} {entity.address.zip}</div>
            </div>
          }
        </div>
      </div>
    </div>;
    contentString = jsxToString(contentString);

    let infoWindow = new google.maps.InfoWindow({
      content: contentString
    });

    this.infoWindow = infoWindow;
    infoWindow.open(this.map, marker);
  }

  componentDidUpdate(prevProps, prevState) {
    let schoolPolygonChanged = prevState.schoolPolygon != this.state.schoolPolygon;
    let districtPolygonChanged = prevState.districtPolygon != this.state.districtPolygon;
    let mapCenterChanged = prevState.mapCenter != this.state.mapCenter;
    let schoolsChanged = prevProps.schools != this.props.schools;
    let districtsChanged = prevProps.districts != this.props.districts;
    let selectedSchoolChanged = prevProps.school != this.props.school;
    let selectedDistrictChanged = prevProps.district != this.props.district;
    let schoolMarkersChanged = prevState.schoolMarkers != this.state.schoolMarkers;
    let districtMarkersChanged = prevState.districtMarkers != this.state.districtMarkers;

    if(schoolPolygonChanged) {
      if(prevState.schoolPolygon) {
        prevState.schoolPolygon.setMap(null);
      }
      if(this.state.schoolPolygon) {
        this.state.schoolPolygon.setMap(this.map);
      }
    }
    if(districtPolygonChanged) {
      if(prevState.districtPolygon) {
        prevState.districtPolygon.setMap(null);
      }
      if(this.state.districtPolygon) {
        this.state.districtPolygon.setMap(this.map);
      }
    }
    if(mapCenterChanged) {
      this.map.setCenter(this.state.mapCenter);
    }
    if(schoolsChanged) {
      this.updateSchoolMarkers();
    }
    if(districtsChanged) {
      this.updateDistrictMarkers();
    }
    if(selectedSchoolChanged) {
      let school = this.props.school;
      if(school) {
        school = new School(school);
        this.setState({
          schoolPolygon: school.getPolygon(this.props.level)
        });
      } else {
        this.setState({
          schoolPolygon: null
        });
      }
    }
    if(selectedDistrictChanged) {
      let district = this.props.district;
      if(district) {
        district = new District(district);
        let m = this.state.districtMarkers[[district.state.toLowerCase(), district.id]];
        this.showInfoWindow(m, district);
        this.setState({
          districtPolygon: district.getPolygon(this.props.level)
        });
      } else {
        this.setState({
          districtPolygon: null
        });
      }
    }

    if(schoolMarkersChanged) {
      Object.values(prevState.schoolMarkers).forEach(m => {
        m.setMap(null);
        google.maps.event.clearListeners(m, 'click');
      });
      Object.values(this.state.schoolMarkers).forEach(m => m.setMap(this.map));
    }
    if(districtMarkersChanged) {
      Object.values(prevState.districtMarkers).forEach(m => {
        m.setMap(null);
        google.maps.event.clearListeners(m, 'click');
      });
      Object.values(this.state.districtMarkers).forEach(m => m.setMap(this.map));
    }
  }

  render() {
    return (
      <div id="district-boundaries-component">
        <ConnectedSearchBar/>

        <div id="map-canvas" style={{width:'75%', height:'400px'}} ref={(map) => { this.mapDiv = map; }}></div>
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
