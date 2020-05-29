import React from 'react';
import PropTypes from 'prop-types';
import { t } from 'util/i18n';
import {
  defineAdOnce,
  destroyAd,
  adsInitialized,
  slotIdFromName,
  showAd
} from 'util/new_advertising.js';

import { CSSTransition } from 'react-transition-group';

class NewAd extends React.Component {
  static propTypes = {
    slot: PropTypes.string.isRequired, // slot name
    slotOccurrenceNumber: PropTypes.number,
    defer: PropTypes.bool,
    ghostTextEnabled: PropTypes.bool,
    container: PropTypes.element,
    children: PropTypes.func,
    transitionDuration: PropTypes.number
  };

  static defaultProps = {
    slotOccurrenceNumber: 1,
    defer: false,
    ghostTextEnabled: true,
    container: <div />,
    children: null,
    transitionDuration: 1000
  };

  state = {
    adRenderEnded: false,
    adFilled: false
  }

  componentDidMount() {
    this.onAdRenderEnded = this.onAdRenderEnded.bind(this);
    const {
      slot,
      defer,
      slotOccurrenceNumber
    } = this.props;
    console.log('NEW AD ... ad component', slot, 'did mount');

    if (adsInitialized() && !defer) {
      console.log('NEW AD ... showing existing ad', slot);
      showAd(slot, slotOccurrenceNumber, this.onAdRenderEnded);
    } else if (!defer) {
      console.log('NEW AD ... initializing react ad', slot);
      defineAdOnce(slot, slotOccurrenceNumber, this.onAdRenderEnded);
    }
  }

  componentWillUnmount() {
    console.log('NEW AD ... ad component', this.props.slot, 'will unmount');
    destroyAd(this.props.slot);
  }

  onAdRenderEnded(event) {
    console.log('NEW AD ... SlotRenderedHandler', event.isEmpty);
    this.setState(
      {
        adRenderEnded: true,
        adFilled: !event.isEmpty
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

export default NewAd;
