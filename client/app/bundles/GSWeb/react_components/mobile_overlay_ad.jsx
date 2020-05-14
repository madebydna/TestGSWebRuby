import React from 'react';
import { connect } from 'react-redux';
import NewAd from 'react_components/new_ad';
import OpenableCloseable from 'react_components/openable_closeable';

const MobileOverlayAd = ({ loaded }) =>
  loaded ? (
    <OpenableCloseable openByDefault={false}>
      {(isOpen, { openForDuration, close }) => (
        <NewAd
          container={
            <div className={`mobile-ad-sticky-bottom ${isOpen ? '' : 'dn'}`} />
          }
          slot="Mobile_overlay"
          sizeName="mobile_overlay"
          transitionDuration={1000}
          onFill={() => openForDuration(15000, 1000)}
        >
          {adElement => (
            <React.Fragment>
              <span className="close" onClick={close}>
                ×
              </span>
              {adElement}
            </React.Fragment>
          )}
        </NewAd>
      )}
    </OpenableCloseable>
  ) : null;

const ConnectedMobileOverlayAd = connect(state => ({
  loaded: state.common.shouldLoadMobileOverlayAd
}))(MobileOverlayAd);

export default ConnectedMobileOverlayAd;
