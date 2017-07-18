import React, { PropTypes } from 'react';

export default class DefaultMapMarker extends React.Component {
  static propTypes = {
    googleMaps: PropTypes.object,
    map: PropTypes.object,
    lat: PropTypes.number.isRequired,
    lon: PropTypes.number.isRequired
  };

  constructor(props) {
    super(props);
  }

  componentDidMount() {
    // the reason we call createMarker() here and not pass in the marker as
    // a prop, is we want to wait until React mounts the component before
    // actually having to create a Google Maps marker
    let position = new this.props.googleMaps.LatLng(this.props.lat, this.props.lon);
    this.marker = new this.props.googleMaps.Marker({
      position: position,
      zIndex: 2,
      animation: this.props.googleMaps.Animation.DROP
    });
    this.marker.setMap(this.props.map);
  }

  componentWillUnmount() {
    google.maps.event.clearListeners(this.marker, 'click');
    this.marker.setMap(null);
  }

  render() {
    return null;
  }
}
