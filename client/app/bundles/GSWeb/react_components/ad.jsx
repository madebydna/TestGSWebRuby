import React from 'react';
import PropTypes from 'prop-types';
import { t } from 'util/i18n';
import {
  defineAdOnce,
  showAdByName as showAd,
  destroyAdByName as destroyAd,
  onInitialize as onAdvertisingInitialize,
  slotIdFromName
} from 'util/advertising.js';
import { CSSTransition } from 'react-transition-group';

class Ad extends React.Component {
  static propTypes = {
    slot: PropTypes.string.isRequired, // slot name
    sizeName: PropTypes.string, // previously known as data-ad-setting or sizeMapping
    slotOccurrenceNumber: PropTypes.number,
    defer: PropTypes.bool,
    ghostTextEnabled: PropTypes.bool,
    container: PropTypes.element,
    dimensions: PropTypes.arrayOf(PropTypes.number),
    children: PropTypes.func,
    transitionDuration: PropTypes.number
  };

  static defaultProps = {
    slotOccurrenceNumber: 1,
    sizeName: null,
    defer: false,
    ghostTextEnabled: true,
    container: <div />,
    dimensions: [1, 1], // width, height
    children: null,
    transitionDuration: 1000
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
    const {
      slot,
      sizeName,
      defer,
      dimensions,
      slotOccurrenceNumber
    } = this.props;

    onAdvertisingInitialize(() => {
      defineAdOnce({
        divId: slot,
        slotOccurrenceNumber,
        slotName: slot,
        dimensions,
        sizeName,
        onRenderEnded: this.onAdRenderEnded
      });
      if (!defer) {
        showAd(slot, slotOccurrenceNumber);
      }
    });
  }

  componentWillUnmount() {
    destroyAd(this.props.slot, this.props.slotOccurrenceNumber);
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

  render() {
    const { container, slot, slotOccurrenceNumber } = this.props;
    const givenContainerClassName = container.props.className;
    const newContainerClassName = `${givenContainerClassName || ''} ${
      this.shouldShowContainer() ? '' : 'dn'
    }`;
    const adElement = (
      <React.Fragment>
        <div className="tac js-ad-hook" id={slotIdFromName(slot, slotOccurrenceNumber)} />
        {this.props.ghostTextEnabled && (
          <div width="100%">
            <div className="advertisement-text ma">{t('advertisement')}</div>
          </div>
        )}
      </React.Fragment>
    );
    return (
      <CSSTransition
        classNames="ad-reveal"
        in={this.state.adRenderEnded}
        timeout={this.props.transitionDuration}
      >
        {React.cloneElement(container, {
          className: `${newContainerClassName}`,
          children: this.props.children
            ? this.props.children(adElement)
            : adElement
        })}
      </CSSTransition>
    );
  }
}

export default Ad;
