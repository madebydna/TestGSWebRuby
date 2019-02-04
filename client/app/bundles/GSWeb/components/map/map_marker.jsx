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
    style: PropTypes.string,
    locationQuery: PropTypes.bool,
    propertiesCount: PropTypes.number
  };

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
      this.props.lon,
      this.props.highlighted,
      this.props.svg,
      this.props.assigned,
      this.props.address,
      this.props.style,
      this.props.locationQuery
    );
    if (this.props.animation) {
      this.marker.setAnimation(this.props.animation);
    }
    this.marker.setMap(this.props.map);
    google.maps.event.addListener(this.marker, 'click', () => {
      this.props.onClick(this.marker);
      // this.props.openInfoWindow(this.marker);
    });
    if (this.props.selected) {
      this.props.openInfoWindow(this.marker);
    }
    if(this.props.openInfoWindowOnStartUp){
      this.props.openInfoWindow(this.marker, true);
    }
  }

  componentWillReceiveProps(nextProps) {
    if (!this.props.selected && nextProps.selected && this.marker) {
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
  style,
  savedHeartCallback,
  findSchoolCallback
) =>
  schools.map(s => {
    const shouldFetchSchoolDetails = Object.values(s).length < 10;
    const schoolInfo = {state: s.state, id: s.id};
    return <MapMarker
      {...{
        title: s.name,
        schoolId: s.id,
        rating: s.rating,
        lat: s.lat,
        lon: s.lon,
        svg: true,
        highlighted: s.highlighted,
        assigned: s.assigned,
        googleMaps,
        style,
        locationQuery: s.locationQuery,
        map,
        key: `s${s.state}${s.id}${s.assigned}${s.highlighted}${style}${Object.values(s).length}`,
        openInfoWindow: (m, boolean = false) => openInfoWindow(createInfoWindow({ ...s, savedSchoolCallback: savedHeartCallback }), m, {openOnStartUpDone: boolean, ...schoolInfo}),
        onClick: m => {
          if(shouldFetchSchoolDetails){
            findSchoolCallback([[s.state, s.id]], true)
          }else{
            if (selectSchool) {
              selectSchool();
            }
            openInfoWindow(createInfoWindow({ ...s, savedSchoolCallback: savedHeartCallback }), m, { ...schoolInfo });
          }
        },
        selected: s === selectedSchool,
        type:
          s.schoolType === 'private'
            ? Markers.PRIVATE_SCHOOL
            : Markers.PUBLIC_SCHOOL,
        openInfoWindowOnStartUp: s.openInfoWindowOnStartUp
      }}
    />
  });

export { createMarkersFromSchools };
