import React from 'react';
import { connect } from 'react-redux';
import Ad from 'react_components/ad';
import OpenableCloseable from 'react_components/openable_closeable';

const MobileOverlayAd = ({ loaded }) =>
  loaded && (
    <OpenableCloseable openByDefault>
      {({ close }) => (
        <Ad
          container={<div className="mobile-ad-sticky-bottom">sdlkfj</div>}
          slot="Mobile_overlay"
          sizeName="mobile_overlay"
          width={320}
          height={100}
          closeButton
          defer
        >
          {adElement => (
            <React.Fragment>
              <span className="close" onClick={close}>
                ×
              </span>
              {adElement}
            </React.Fragment>
          )}
        </Ad>
      )}
    </OpenableCloseable>
  );

const ConnectedMobileOverlayAd = connect(state => ({
  loaded: state.common.loadMobileOverlayAd
}))(MobileOverlayAd);

export default ConnectedMobileOverlayAd;
