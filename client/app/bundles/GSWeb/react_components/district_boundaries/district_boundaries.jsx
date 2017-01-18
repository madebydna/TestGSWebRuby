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

export default class DistrictBoundaries extends React.Component {
  static defaultProps = {
  }

  static propTypes = {
  }

  constructor(props) {
    super(props);
    this.map = null;
    this.nearbyDistrictsRadius = 50;
    this.initGoogleMaps = this.initGoogleMaps.bind(this);
    this.loadSchoolById = this.loadSchoolById.bind(this);
    this.renderMap = this.renderMap.bind(this);

    this.state = {
      googleMapsInitialized: false,
      // schoolId: 8,
      // state: 'ca'
      level: 'm',
      lat: 37.7949217,
      lon: -122.2499247,
      schoolMarkers: {},
      districtMarkers: {}
    }
    this.initGoogleMaps();
  }

  loadData() {
    this.loadSchool();
    this.loadNearbyDistricts();
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
        this.setState({
          districtId: null,
          schoolId: null,
          lat: e.latLng.lat(),
          lon: e.latLng.lng(),
        });
      }.bind(this));

      google.maps.event.addDomListener(
        window, 'resize', () => this.map.setCenter(this.state.mapCenter)
      );
    }.bind(this));
  }

  componentDidMount() {
    this.$map = $(findDOMNode(this.mapDiv));
    this.centerMapOnSchool();
    this.loadData();
  }

  updateSchoolMarkers()  {
    let existingMarkers = this.state.schoolMarkers;

    let newMarkers = Object.values(this.props.schools).reduce(function(obj, s) {
      let key = [s.state.toLowerCase(), s.id];
      let marker = obj[key] = existingMarkers[key] || new School(s).getMarker();

      google.maps.event.clearListeners(marker, 'click');
      google.maps.event.addListener(marker, 'click', function() {
        this.setState({
          state: obj.state,
          schoolId: obj.id
        });
      }.bind(this), obj);

      return obj;
    }.bind(this), {});

    Object.keys(existingMarkers).forEach(function(key) {
      if(!newMarkers[key]) {
        existingMarkers[key].setMap(null);
      }
    });

    this.setState({
      schoolMarkers: newMarkers
    });
  }

  updateDistrictMarkers()  {
    let existingMarkers = this.state.districtMarkers;

    let newMarkers = Object.values(this.props.nearbyDistricts).reduce(function(obj, s) {
      let key = [s.state.toLowerCase(), s.id];
      let marker = obj[key] = existingMarkers[key] || new District(s).getMarker();

      google.maps.event.addListener(marker, 'click', function() {
        this.showInfoWindow(marker, s);
        this.setState({
          state: obj.state,
          districtId: obj.id,
          schoolId: null
        });
      }.bind(this), obj);

      return obj;
    }.bind(this), {});

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
        <div class="circle-rating--9 circle-rating--medium">
          9<span class="rating-circle-small">/10</span>
        </div>
        <div class="title-container" style="width:300px">
          <div>
            <span class="title">
              {entity.name}
            </span>
          </div>
          <div>{entity.address.street1}</div>
          <div>{entity.address.city}, {entity.address.state} {entity.address.zip}</div>
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
    let polygonChanged = prevState.polygon && prevState.polygon != this.state.polygon;
    let schoolsChanged = (Object.keys(prevProps.schools) != Object.keys(this.props.schools));
    let mapCenterChanged = prevState.mapCenter != this.state.mapCenter;

    if(polygonChanged) {
      prevState.polygon.setMap(null);
    }
    if(mapCenterChanged) {
      this.map.setCenter(this.state.mapCenter);
    }
    if(prevProps.schools != this.props.schools) {
      this.updateSchoolMarkers();
    }
    if(prevProps.nearbyDistricts != this.props.nearbyDistricts) {
      this.updateDistrictMarkers();
    }
    if(Object.keys(prevProps.schools).length == 0 && Object.keys(this.props.schools).length > 0) {
      this.centerMapOnSchool();
    }
    if(prevState.schoolId != this.state.schoolId) {
      this.loadSchoolById();
    }
    if(prevState.districtId != this.state.districtId) {
      this.loadDistrictById();
    }
    if(prevState.lat != this.state.lat || prevState.lon != this.state.lon) {
      this.loadSchoolByLatLon();
      this.loadDistrictByLatLon();
      this.loadNearbyDistricts();
    }
    if(prevState.districtMarkers != this.state.districtMarkers) {
      Object.values(prevState.districtMarkers).forEach(m => m.setMap(null));
      Object.values(this.state.districtMarkers).forEach(m => m.setMap(this.map));
    }
    if(prevState.schoolMarkers != this.state.schoolMarkers) {
      Object.values(prevState.schoolMarkers).forEach(m => m.setMap(null));
      Object.values(this.state.schoolMarkers).forEach(m => m.setMap(this.map));
    }
    if(prevProps.districtAtLatLon != this.props.districtAtLatLon) {
      let district = this.props.nearbyDistricts[this.props.districtAtLatLon];
      this.setState({
        polygon: new District(district).getPolygon(this.state.level)
      });
    } else if (this.state.schoolId && (prevState.schoolId != this.state.schoolId || schoolsChanged)) {
      let school = this.props.schools[[this.state.state.toLowerCase(), this.state.schoolId]];
      if(school) {
        this.setState({
          polygon: new School(school).getPolygon(this.state.level)
        });
      }
    } else if (this.state.districtId && (prevState.districtId != this.state.districtId || districtsChanged)) {
      let district = this.props.districts[[this.state.state.toLowerCase(), this.state.districtId]];
      if(district) {
        this.setState({
          polygon: new District(district).getPolygon(this.state.level)
        });
      }
    }
  }

  centerMapOnSchool() {
    let school = this.getSchool();
    if(school) {
      this.map.setCenter(school.getPosition());
    }
  }

  loadSchoolById() {
    let key = [this.state.state, this.state.schoolId];
    let school = this.props.schools[key];
    if (!school) {
      this.props.getSchool(
        this.state.schoolId, {
          state: this.state.state
        }
      );
    }
  }

  loadSchoolByLatLon() {
    this.props.loadSchoolWithBoundaryContainingPoint(
      this.state.lat,
      this.state.lon,
      {
        boundary_level: this.state.level
      }
    );
  }

  loadDistrictById() {
    let key = [this.state.state, this.state.districtId];
    let district = this.props.schools[key];
    if (!district) {
      this.props.getDistrict(
        this.state.districtId, {
          state: this.state.state
        }
      );
    }
  }

  loadDistrictByLatLon() {
    this.props.loadDistrictWithBoundaryContainingPoint(
      this.state.lat,
      this.state.lon,
      {
        boundary_level: this.state.level
      }
    );
  }

  loadNearbyDistricts() {
    this.props.getNearbyDistricts(this.state.lat, this.state.lon, this.nearbyDistrictsRadius, {
      charter_only: false 
    });
  }

  getSchool() {
    let key = undefined;
    if (this.state.schoolId && this.state.state) {
      key = [this.state.state, this.state.schoolId];
    } else if (this.state.lat && this.state.lon) {
      key = this.props.schoolAtLatLon;
    }
    return this.props.schools[key];
  }

  getDistrict() {
    let key = undefined;
    if (this.state.districtId && this.state.state) {
      key = [this.state.state, this.state.districtId];
    } else if (this.state.lat && this.state.lon) {
      key = this.props.districtAtLatLon;
    }
    return this.props.nearbyDistricts[key];
  }

  loadSchool() {
    if (this.state.schoolId && this.state.state) {
      this.loadSchoolById();
    } else if (this.state.lat && this.state.lon) {
      this.loadSchoolByLatLon();
    }
  }

  loadDistrict() {
    if (this.state.districtId && this.state.state) {
      this.loadDistrictById();
    } else if (this.state.lat && this.state.lon) {
      this.loadDistrictByLatLon();
    }
  }

  renderMap() {
    let school = this.getSchool();
    let district = this.getDistrict();
    if (this.state.polygon) {
      this.state.polygon.setMap(this.map);
    }
    let nearbyDistricts = this.props.nearbyDistricts;
  }

  render() {
    if(this.state.googleMapsInitialized) {
      this.renderMap();
    }
    return (
      <div id="district-boundaries-component">
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
