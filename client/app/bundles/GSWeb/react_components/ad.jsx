import React from 'react';
import PropTypes from 'prop-types';
import { capitalize, t } from 'util/i18n';
import {
  defineAdOnce,
  showAd,
  onInitialize as onAdvertisingInitialize
} from 'util/advertising.js';

class Ad extends React.Component {
  static propTypes = {
    slot: PropTypes.string.isRequired, // slot name
    sizeName: PropTypes.string.isRequired, // previously known as data-ad-setting or sizeMapping
    idCounter: PropTypes.number,
    defer: PropTypes.bool,
    ghostTextEnabled: PropTypes.bool,
    container: PropTypes.element,
    dimensions: PropTypes.arrayOf(PropTypes.number)
  };

  static defaultProps = {
    idCounter: 1,
    defer: false,
    ghostTextEnabled: true,
    container: <div />,
    dimensions: [1, 1] // width, height
  };

  constructor(props) {
    super(props);
    this.state = {};
    this.onAdRenderEnded = this.onAdRenderEnded.bind(this);
  }

  componentDidMount() {
    const { slot, sizeName, defer, dimensions } = this.props;

    onAdvertisingInitialize(() => {
      defineAdOnce({
        divId: this.slotId(),
        slotName: slot,
        dimensions,
        sizeName,
        onRenderEnded: this.onAdRenderEnded
      });
      if (!defer) {
        showAd(this.slotId());
      }
    });
  }

  onAdRenderEnded({ isEmpty }) {
    this.setState({
      adRenderEnded: true,
      adFilled: !isEmpty
    });
  }

  shouldShowContainer = () => this.state.adRenderEnded && this.state.adFilled;

  slotId = () => {
    const { slot, idCounter } = this.props;
    const slotName = capitalize(slot).replace(' ', '_');
    return `${slotName}${idCounter}_Ad`;
  };

  render() {
    const { container } = this.props;
    return React.cloneElement(container, {
      className: `${container.props.className} ${
        this.shouldShowContainer() ? '' : 'dn'
      }`,
      children: (
        <React.Fragment>
          <div className="tac" id={this.slotId()} />
          {this.props.ghostTextEnabled && (
            <div width="100%">
              <div className="advertisement-text ma">{t('advertisement')}</div>
            </div>
          )}
        </React.Fragment>
      )
    });
  }
}

export default Ad;
