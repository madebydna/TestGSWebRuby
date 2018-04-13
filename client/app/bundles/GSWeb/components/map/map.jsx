import React, { PropTypes } from 'react';
import { findDOMNode } from 'react-dom';

export default class Map extends React.Component {
  static propTypes = {
    googleMaps: React.PropTypes.object.isRequired,
    markers: React.PropTypes.array
  }
  
  static defaultProps = {
    markers: []
  }

  constructor(props) {
    super(props);
    this.state = {};
  }

  createGoogleMap($elem) {
    let mapOptions = {
      center: new this.props.googleMaps.LatLng(37.77,-122.419),
      zoom: 11,
      mapTypeId: this.props.googleMaps.MapTypeId.ROADMAP,
      mapTypeControl: false,
      scrollwheel: false,
      zoomControlOptions: {
        position: google.maps.ControlPosition.TOP_RIGHT
      },
    };
    return new this.props.googleMaps.Map($elem, mapOptions);
  }

  openInfoWindow(content, marker) {
    this.closeInfoWindow();
    let infoWindow = new this.props.googleMaps.InfoWindow({
      content: content
    });
    infoWindow.open(this.map, marker);
    this.infoWindow = infoWindow;
  }

  closeInfoWindow() {
    if(this.infoWindow) {
      this.infoWindow.close();
      this.infoWindow = null;
    }
  }

  onDragEnd() {
    this.closeInfoWindow();
    this.setState({mapCenter: this.map.getCenter()});
  }

  onIdle() {
    this.props.googleMaps.event.trigger(this.map, 'resize');
    this.setState({mapCenter: this.map.getCenter()});
  }

  onResize() {
    this.props.googleMaps.event.trigger(this.map, 'resize');
    this.map.setCenter(this.state.mapCenter)
  }

  onClick(e) {
    this.closeInfoWindow();
    this.setState({mapCenter: e.latLng});
    this.props.changeLocation(e.latLng.lat(), e.latLng.lng());
  }

  componentDidMount() {
    let $map = $(findDOMNode(this.mapDiv))[0];
    this.map = this.createGoogleMap($map);
    this.$map = $map;
    this.props.googleMaps.event.addDomListener(this.map, 'dragend', this.onDragEnd.bind(this));
    this.props.googleMaps.event.addDomListener(this.map, 'idle', this.onIdle.bind(this));
    this.props.googleMaps.event.addDomListener(window, 'resize', this.onResize.bind(this));
    this.map.addListener('click', this.onClick.bind(this));
    this.setState({mapCenter: this.map.getCenter(), mounted: true});
  }

  componentDidUpdate(prevProps, prevState) {
    if(prevProps.markers.length == 0 && this.props.markers.length > 0) {
      this.onResize();
    }
    if(prevProps.hidden && !this.props.hidden) {
      this.onResize();
    }
  }
  

  renderPolygons() {
    return this.props.polygons.map(component => React.cloneElement(component, {
      googleMaps: this.props.googleMaps,
      map: this.map,
    }));
  }

  renderMarkers() {
    return this.props.markers.map(component => React.cloneElement(component, {
      googleMaps: this.props.googleMaps,
      map: this.map,
      onClick: (m) => {
        component.props.onClick();
        this.openInfoWindow(component.props.createInfoWindow(), m) 
      },
      openInfoWindow: (m) => {
        this.openInfoWindow(component.props.createInfoWindow(), m) 
      }
    }));
  }

  render() {
    return (
      <div className="map" ref={(map) => { this.mapDiv = map; }}>
        {this.state.mounted && this.renderMarkers()}
        {this.renderPolygons()}
      </div>
    );
  }
}
