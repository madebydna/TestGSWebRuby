import React from 'react';
import PropTypes from 'prop-types';
import createMarkerFactory, * as Markers from '../../components/map/markers';
import DefaultMapMarker from './default_map_marker';
import createInfoWindow from '../../components/map/info_window';

export default class MapMarker extends DefaultMapMarker {
  static propTypes = {
    googleMaps: PropTypes.object,
    map: PropTypes.object,
    type: PropTypes.string.isRequired,
    title: PropTypes.string.isRequired,
    lat: PropTypes.number.isRequired,
    lon: PropTypes.number.isRequired,
    rating: PropTypes.number,
    onClick: PropTypes.func,
    selected: PropTypes.bool,
    assigned: PropTypes.bool,
    address: PropTypes.bool,
    animation: PropTypes.number,
    zoomLevel: PropTypes.number,
    locationQuery: PropTypes.bool,
    propertiesCount: PropTypes.number
  };

  constructor(props) {
    super(props);
    // marker factory shared by all "instances"
    this.markerFactory = createMarkerFactory(props.googleMaps);
    this.setUpMarkers = this.setUpMarkers.bind(this);
  }

  componentDidMount() {
    this.setUpMarkers()
  }

  componentDidUpdate(prevProps,prevState){
    if(this.props.zoomLevel !== prevProps.zoomLevel && (this.props.zoomLevel === 15 || this.props.zoomLevel === 14)){
      this.marker.setMap(null)
      this.setUpMarkers()
    }
  }

  componentWillReceiveProps(nextProps) {
    if (!this.props.selected && nextProps.selected && this.marker) {
      this.props.openInfoWindow(this.marker);
    }
  }

  setUpMarkers(){
    // the reason we call createMarker() here and not pass in the marker as
    // a prop, is we want to wait until React mounts the component before
    // actually having to create a Google Maps marker
    this.marker = this.markerFactory.createMarker(
      this.props.type,
      this.props.title,
      this.props.rating,
      this.props.lat,
      this.props.lon,
      this.props.highlighted,
      this.props.svg,
      this.props.assigned,
      this.props.address,
      this.props.zoomLevel,
      this.props.locationQuery,
      this.props.propertiesCount
    );
    if (this.props.animation) {
      this.marker.setAnimation(this.props.animation);
    }
    this.marker.setMap(this.props.map);
    google.maps.event.addListener(this.marker, 'click', () => {
      this.props.onClick(this.marker);
      this.props.openInfoWindow(this.marker);
    });
    if (this.props.selected) {
      this.props.openInfoWindow(this.marker);
    }
  }
}

const createMarkersFromSchools = (
  schools,
  selectedSchool,
  map,
  selectSchool,
  openInfoWindow,
  googleMaps,
  zoomLevel,
  callback
) =>
  schools.map(s => (
    <MapMarker
      {...{
        title: s.name,
        schoolId: s.school_id,
        rating: s.rating,
        lat: s.lat,
        lon: s.lon,
        svg: true,
        highlighted: s.highlighted,
        assigned: s.assigned,
        googleMaps,
        zoomLevel,
        locationQuery: s.locationQuery,
        propertiesCount: Object.values(s).length,
        map,
        key: `s${s.state}${s.id}${s.assigned}${s.highlighted}`,
        openInfoWindow: m => openInfoWindow(createInfoWindow({ ...s, savedSchoolCallback: callback}), m),
        onClick: m => {
          if (selectSchool) {
            selectSchool();
          }
          openInfoWindow(createInfoWindow({ ...s, savedSchoolCallback: callback }), m);
        },
        selected: s === selectedSchool,
        type:
          s.schoolType === 'private'
            ? Markers.PRIVATE_SCHOOL
            : Markers.PUBLIC_SCHOOL
      }}
    />
  ));

export { createMarkersFromSchools };
