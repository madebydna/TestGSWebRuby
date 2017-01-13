import React, { PropTypes } from 'react';
import * as google_map_extensions from '../../components/map/google_maps_extensions';
import * as google_maps from '../../components/map/google_maps';
import * as boundaries_jquery_plugin from '../../components/map/jquery_plugin';
import Boundary from '../../components/map/boundaries';
import * as infobox from '../../components/map/infobox';
import { findDOMNode } from 'react-dom';

export default class DistrictBoundaries extends React.Component {
  static defaultProps = {
  }

  static propTypes = {
  }

  constructor(props) {
    super(props);
    this.map = null;
    this.initGoogleMaps = this.initGoogleMaps.bind(this);
    this.updateMap = this.updateMap.bind(this);
    this.state = {
      googleMapsInitialized: false,
      schoolId: 8,
      state: 'ca'
    }
    this.initGoogleMaps();
  }

  initGoogleMaps() {
    google_maps.init(function() {
      google_map_extensions.init();
      infobox.init();
      boundaries_jquery_plugin.init();
      this.setState({
        googleMapsInitialized: true
      });
    }.bind(this));
  }

  componentDidMount() {
    this.$map = $(findDOMNode(this.mapDiv));
  }

  componentDidUpdate(prevProps, prevState) {
  }

  updateMap() {
    if (this.state.schoolId && this.state.state) {
      this.$map.boundaries('school', {
        id: this.state.schoolId,
        state: this.state.state
      });
    }
  }

  mapclick(event, obj){
    // enter('browsing');
    // STATES.browsing.position = obj.data;
    // $map.boundaries('district', obj.data);
    // $map.boundaries('districts', obj.data);
  }

  markerclick(event, obj) {
    // if (state('searching') && obj.data.type=='district' && STATES.searching.originalId!=obj.data.id){
    //   enter('browsing');
    // }
    // STATES.browsing.position = obj.data.getMarker().getPosition();
  }

  render() {
    if(this.state.googleMapsInitialized) {
      this.updateMap();
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
