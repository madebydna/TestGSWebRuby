import React from 'react';
import PropTypes from 'prop-types';
import { findDOMNode } from 'react-dom';
import { once } from 'lodash';
import School from '../../react_components/search/school'

export default class Map extends React.Component {
  static propTypes = {
    googleMaps: PropTypes.object.isRequired,
    markers: PropTypes.arrayOf(PropTypes.element),
    polygons: PropTypes.arrayOf(PropTypes.element),
    hidden: PropTypes.bool,
    lat: PropTypes.number,
    lon: PropTypes.number,
    schools: PropTypes.arrayOf(PropTypes.shape(School.propTypes)),
  };

  static defaultProps = {
    markers: [],
    polygons: [],
    hidden: false,
    lat: null,
    lon: null
  };

  constructor(props) {
    super(props);
    this.state = { mapUpdated: true };
    this.openInfoWindow = this.openInfoWindow.bind(this);
    this.fitBounds = (this.fitBounds.bind(this));
  }

  createGoogleMap($elem) {
    const mapCenter = {
      lat: this.props.lat || 37.77,
      lon: this.props.lon || -122.419
    };
    const mapOptions = {
      center: new this.props.googleMaps.LatLng(mapCenter.lat, mapCenter.lon),
      zoom: 12,
      mapTypeId: this.props.googleMaps.MapTypeId.ROADMAP,
      mapTypeControl: false,
      scrollwheel: false,
      zoomControlOptions: {
        position: this.props.googleMaps.ControlPosition.TOP_RIGHT
      },
      clickableIcons: false
    };
    return new this.props.googleMaps.Map($elem, mapOptions);
  }

  openInfoWindow(content, marker) {
    this.closeInfoWindow();
    const infoWindow = new this.props.googleMaps.InfoWindow({
      content
    });
    infoWindow.open(this.map, marker);
    this.infoWindow = infoWindow;
  }

  closeInfoWindow() {
    if (this.infoWindow) {
      this.infoWindow.close();
      this.infoWindow = null;
    }
  }

  onDragEnd() {
    this.closeInfoWindow();
    this.setState({ mapCenter: this.map.getCenter() });
  }

  onIdle() {
    this.props.googleMaps.event.trigger(this.map, 'resize');
    this.setState({ mapCenter: this.map.getCenter() });
  }

  onResize() {
    this.props.googleMaps.event.trigger(this.map, 'resize');
    this.map.setCenter(this.state.mapCenter);
  }

  onClick(e) {
    this.closeInfoWindow();
    this.setState({ mapCenter: e.latLng });
    this.props.changeLocation(e.latLng.lat(), e.latLng.lng());
  }

  componentDidMount() {
    const $map = $(findDOMNode(this.mapDiv))[0];
    this.map = this.createGoogleMap($map);
    this.bounds = new this.props.googleMaps.LatLngBounds();
    this.$map = $map;
    this.props.googleMaps.event.addDomListener(
      this.map,
      'dragend',
      this.onDragEnd.bind(this)
    );
    this.props.googleMaps.event.addDomListener(
      this.map,
      'idle',
      this.onIdle.bind(this)
    );
    this.props.googleMaps.event.addDomListener(
      window,
      'resize',
      this.onResize.bind(this)
    );
    this.map.addListener('click', this.onClick.bind(this));
    this.setState({ mapCenter: this.map.getCenter(), mounted: true });
  }

  componentDidUpdate(prevProps, prevState) {
    if (prevProps.markers.length == 0 && this.props.markers.length > 0) {
      this.onResize();
    }
    if (prevProps.hidden && !this.props.hidden) {
      this.onResize();
    }
    if (this.props.schools.map(school => school.id + school.name).join('') !== prevProps.schools.map(school => school.id + school.name).join('')) {
      this.setState({ mapUpdated: true});
    }
  }

  renderPolygons() {
    return this.props.polygons.map(component =>
      React.cloneElement(component, {
        googleMaps: this.props.googleMaps,
        map: this.map
      })
    );
  }

  renderMarkers() {
    return this.props.markers.map(component =>
      React.cloneElement(component, {
        googleMaps: this.props.googleMaps,
        map: this.map,
        onClick: m => {
          component.props.onClick();
          this.openInfoWindow(component.props.createInfoWindow(), m);
        },
        openInfoWindow: m => {
          this.openInfoWindow(component.props.createInfoWindow(), m);
        }
      })
    );
  }

  fitBounds(markers) {
    markers.forEach(m => {
      this.bounds.extend(
        new this.props.googleMaps.LatLng(m.props.lat, m.props.lon)
      );
    });
    if (this.state.mapUpdated) {
      this.map.fitBounds(this.bounds);
      console.log(this.bounds);
      this.setState({
        mapUpdated: false,
      })
      this.bounds = new this.props.googleMaps.LatLngBounds();
    }

  }

  render() {
    return (
      <div
        className="map"
        ref={map => {
          this.mapDiv = map;
        }}
      >
        {this.state.mounted &&
          this.props.children({
            googleMaps: this.props.googleMaps,
            map: this.map,
            openInfoWindow: this.openInfoWindow,
            fitBounds: this.fitBounds
          })}
      </div>
    );
  }
}
