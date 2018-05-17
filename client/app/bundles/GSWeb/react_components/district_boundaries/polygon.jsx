import React from 'react';
import PropTypes from 'prop-types';
import createPolygonFactory from '../../components/map/polygons';

export default class Polygon extends React.Component {
  static propTypes = {
    googleMaps: PropTypes.object,
    map: PropTypes.object,
    type: PropTypes.string.isRequired,
    coordinates: PropTypes.array.isRequired
  }

  constructor(props) {
    super(props);
    // polygon factory shared by all "instances"
    this.polygonFactory = createPolygonFactory(props.googleMaps);
  }

  componentDidMount() {
    let polygon = this.polygonFactory.createPolygon(this.props.type, this.props.coordinates);
    polygon.setMap(this.props.map);
    this.setState({
      polygon: polygon
    });
  }

  componentWillUnmount() {
    this.state.polygon.setMap(null);
  }

  render() {
    return null;
  }
}
