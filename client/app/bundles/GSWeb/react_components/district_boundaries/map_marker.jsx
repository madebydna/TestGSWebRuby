import React, { PropTypes } from 'react';
import createMarkerFactory from '../../components/map/markers';

export default class MapMarker extends React.Component {
  static propTypes = {
    googleMaps: React.PropTypes.object,
    map: React.PropTypes.object,
    type: React.PropTypes.string.isRequired,
    title: React.PropTypes.string.isRequired,
    lat: React.PropTypes.number.isRequired,
    lon: React.PropTypes.number.isRequired,
    rating: React.PropTypes.string,
    onClick: React.PropTypes.func,
    selected: React.PropTypes.bool
  }

  constructor(props) {
    super(props);
    // marker factory shared by all "instances"
    this.markerFactory = createMarkerFactory(props.googleMaps);
  }

  componentDidMount() {

    // the reason we call createMarker() here and not pass in the marker as
    // a prop, is we want to wait until React mounts the component before
    // actually having to create a Google Maps marker
    this.marker = this.markerFactory.createMarker(
      this.props.type,
      this.props.title,
      this.props.rating,
      this.props.lat,
      this.props.lon
    );
    this.marker.setMap(this.props.map);
    google.maps.event.addListener( this.marker, 'click', () => this.props.onClick(this.marker));

    if(this.props.selected) {
      this.props.onClick(this.marker);
    }
  }

  componentWillReceiveProps(nextProps) {
    if(!this.props.selected && nextProps.selected && this.marker) {
      this.props.onClick(this.marker);
    }
  }

  componentWillUnmount() {
    google.maps.event.clearListeners(this.marker, 'click');
    this.marker.setMap(null);
  }

  render() {
    return null;
  }
}
