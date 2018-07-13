import React from 'react';
import PropTypes from 'prop-types';
import * as googleMaps from '../../components/map/google_maps';
import * as googleMapExtensions from '../../components/map/google_maps_extensions';

export default class GoogleMapsInitializer extends React.Component {
  static propTypes = {
    children: PropTypes.func.isRequired
  };

  constructor(props) {
    super(props);
    this.init = this.init.bind(this);
    this.state = {
      initialized: false
    };
  }

  componentDidMount() {
    if (!this.state.initialized) {
      this.init();
    }
  }

  init() {
    googleMaps.init(() => {
      googleMapExtensions.init();
      this.setState({
        initialized: true
      });
    });
  }

  render() {
    return this.props.children(
      this.state.initialized,
      this.state.initialized ? google.maps : null
    );
  }
}
