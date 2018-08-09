import React from 'react';
import PropTypes from 'prop-types';
import { capitalize, t } from 'util/i18n';
import {
  defineAdOnce,
  showAd,
  destroyAd,
  onInitialize as onAdvertisingInitialize
} from 'util/advertising.js';

class Ad extends React.Component {
  static propTypes = {
    slot: PropTypes.string.isRequired, // slot name
    sizeName: PropTypes.string, // previously known as data-ad-setting or sizeMapping
    idCounter: PropTypes.number,
    defer: PropTypes.bool,
    ghostTextEnabled: PropTypes.bool,
    container: PropTypes.element,
    dimensions: PropTypes.arrayOf(PropTypes.number),
    children: PropTypes.func
  };

  static defaultProps = {
    idCounter: 1,
    sizeName: null,
    defer: false,
    ghostTextEnabled: true,
    container: <div />,
    dimensions: [1, 1], // width, height
    children: null
  };

  constructor(props) {
    super(props);
    this.state = {
      adRenderEnded: false,
      adFilled: false
    };
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

  componentWillUnmount() {
    destroyAd(this.slotId());
  }

  onAdRenderEnded({ isEmpty }) {
    this.setState(
      {
        adRenderEnded: true,
        adFilled: !isEmpty
      },
      () => {
        if (this.state.adFilled && this.props.onFill) {
          this.props.onFill();
        }
      }
    );
  }

  shouldShowContainer = () => this.state.adRenderEnded && this.state.adFilled;

  slotId = () => {
    const { slot, idCounter } = this.props;
    const slotName = capitalize(slot).replace(' ', '_');
    return `${slotName}${idCounter}_Ad`;
  };

  render() {
    const { container } = this.props;
    const givenContainerClassName = container.props.className;
    const newContainerClassName = `${givenContainerClassName || ''} ${
      this.shouldShowContainer() ? '' : 'dn'
    }`;
    const adElement = (
      <React.Fragment>
        <div className="tac" id={this.slotId()} />
        {this.props.ghostTextEnabled && (
          <div width="100%">
            <div className="advertisement-text ma">{t('advertisement')}</div>
          </div>
        )}
      </React.Fragment>
    );
    return React.cloneElement(container, {
      className: newContainerClassName,
      children: this.props.children ? this.props.children(adElement) : adElement
    });
  }
}

export default Ad;
