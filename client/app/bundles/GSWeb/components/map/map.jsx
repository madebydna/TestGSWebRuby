import React from 'react';
import PropTypes from 'prop-types';
import { findDOMNode } from 'react-dom';
import { LIST_VIEW, MAP_VIEW } from 'react_components/search/search_context';
import { once } from 'lodash';

export default class Map extends React.Component {
  static propTypes = {
    googleMaps: PropTypes.object.isRequired,
    hidden: PropTypes.bool,
    lat: PropTypes.number,
    lon: PropTypes.number,
    markerDigest: PropTypes.string,
    heartClickCallback: PropTypes.func,
    view: PropTypes.string
  };

  static defaultProps = {
    hidden: false,
    lat: null,
    lon: null,
    markerDigest: ''
  };

  constructor(props) {
    super(props);
    this.state = { markersUpdated: true };
    this.openInfoWindow = this.openInfoWindow.bind(this);
    this.fitBounds = this.fitBounds.bind(this);
    this.handleHeartClickCallback = this.handleHeartClickCallback.bind(this);
  }

  createGoogleMap($elem) {
    const mapCenter = {
      lat: this.props.lat || 37.77,
      lon: this.props.lon || -122.419
    };
    const mapOptions = {
      center: new this.props.googleMaps.LatLng(mapCenter.lat, mapCenter.lon),
      zoom: 12,
      maxZoom: 17, // note this is cleared after bounds are set
      mapTypeId: this.props.googleMaps.MapTypeId.ROADMAP,
      mapTypeControl: false,
      scrollwheel: false,
      zoomControlOptions: {
        position: this.props.googleMaps.ControlPosition.TOP_RIGHT
      },
      clickableIcons: false,
      gestureHandling: 'greedy'
    };
    return new this.props.googleMaps.Map($elem, mapOptions);
  }

  openInfoWindow(content, marker) {
    this.closeInfoWindow();
    const infoWindow = new this.props.googleMaps.InfoWindow({
      content
    });
    this.handleHeartClickCallback(infoWindow);
    infoWindow.open(this.map, marker);
    this.infoWindow = infoWindow;
  }

  handleHeartClickCallback(infoWindow){
    const heartClickCallback = this.props.heartClickCallback
    this.props.googleMaps.event.addDomListener(infoWindow, 'domready', () => {
      const heartContainer = document.querySelector('.js-info-heart');
      heartContainer && heartContainer.addEventListener('click', function (e) {
        heartClickCallback({ state: this.dataset.state, id: this.dataset.id });
        if (heartContainer.classList.contains('icon-heart')) {
          heartContainer.classList.add('icon-heart-outline')
          heartContainer.classList.remove('icon-heart')
        } else {
          heartContainer.classList.add('icon-heart')
          heartContainer.classList.remove('icon-heart-outline')
        }
      })
    })
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
    if (prevProps.hidden && !this.props.hidden) {
      this.onResize();
    }
    if (this.props.markerDigest !== prevProps.markerDigest) {
      this.setState({ markersUpdated: true});
    }
    // the following condition is to help reset the center of map when map object is not viewable but MapMarkers are changed 
    if((this.props.view === LIST_VIEW || this.props.view === MAP_VIEW) && this.props.view !== prevProps.view){
      this.setState({ markersUpdated: true }, () => setTimeout(() => this.map.panBy(1, 1), 50));
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
    if (this.state.markersUpdated) {
      this.map.fitBounds(this.bounds);
      const theMap = this.map;
      // Clear the maxZoom as soon as bounds have been set
      if (!this.bounds.isEmpty()) {
        this.props.googleMaps.event.addListenerOnce(theMap, 'bounds_changed', function() {
          theMap.setOptions({maxZoom:null});
        });
      } else {
        theMap.setOptions({maxZoom:null});
      }
      // this.props.googleMaps.event.trigger(theMap, 'resize')
      this.setState({
        markersUpdated: false,
      })
    }
    this.bounds = new this.props.googleMaps.LatLngBounds();
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
