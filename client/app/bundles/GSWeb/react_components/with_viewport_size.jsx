import React from 'react';
import PropTypes from 'prop-types';
import { throttle } from 'lodash';
import { size as viewportSize } from 'util/viewport';

const withViewportSize = ({ propName = 'viewportSize' }) => WrappedComponent =>
  class extends React.Component {
    constructor(props) {
      super(props);
      this.handleWindowResize = throttle(this.handleWindowResize, 200).bind(
        this
      );
      this.state = {
        size: viewportSize()
      };
    }

    componentDidMount() {
      window.addEventListener('resize', this.handleWindowResize);
    }

    componentWillUnmount() {
      window.removeEventListener('resize', this.handleWindowResize);
    }

    handleWindowResize() {
      this.setState({ size: viewportSize() });
    }

    render() {
      const props = {
        [propName]: this.state.size,
        ...this.props
      };
      return <WrappedComponent {...props} />;
    }
  };

export default withViewportSize;
