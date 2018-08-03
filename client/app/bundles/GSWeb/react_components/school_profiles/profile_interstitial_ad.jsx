import React from 'react';
import PropTypes from 'prop-types';
import Modal from 'react_components/modal';
import Ad from 'react_components/ad';
import { get as getCookie, set as setCookie } from 'js-cookie';
import { t } from 'util/i18n';

const COOKIE_NAME = 'gs_interstitial';
const INTERSTITIAL_VIEWED = 'viewed';

const trackInterstitialViewed = () => {
  setCookie(COOKIE_NAME, INTERSTITIAL_VIEWED);
  return true;
};

const searchRegExp = /search\.page/;
const browseExp = /\/schools\/|\?/;

const referrerIsSearch = () =>
  searchRegExp.test(window.document.referrer) ||
  browseExp.test(window.document.referrer);

const hasViewedInterstitial = () =>
  getCookie(COOKIE_NAME) === INTERSTITIAL_VIEWED;

const shouldShowInterstitial = () =>
  referrerIsSearch() && !hasViewedInterstitial();

const ProfileInterstitialAd = ({ loaded }) =>
  shouldShowInterstitial() && loaded ? (
    <Modal closeOnOutsideClick={false} className="interstitial-modal">
      {({ openForDuration, close }) => (
        <Ad
          sizeName="prestitial"
          slot="Prestitial"
          onFill={() => trackInterstitialViewed() && openForDuration(10000)}
        >
          <p>
            {t(
              'GreatSchools thanks the foundations and advertisers that make it possible to provide our site free to millions of parents. To skip ad,'
            )}
            <a onClick={close} style={{ cursor: 'pointer' }}>
              {t('click here')} »
            </a>
          </p>
        </Ad>
      )}
    </Modal>
  ) : (
    <div />
  );

ProfileInterstitialAd.propTypes = {
  loaded: PropTypes.bool.isRequired
};

// shouldLoad is just a property on this object that will cause the interstitial to load immediately
// (if shouldLoad is true). This handles the case where we know we want to load the interstitial
// before the component has been mounted
//
// If the interstitial has been mounted and not loaded, then we can cause it to load by invoking
// profileInterstitialLoader.load(), which is overwritten by the interstitial when it is constructed.
//
// I could have put this code in the ProfileInterstitialAd above and had one fewer components,
// But wanted to separate it out since it's specific to how we're using it currently.
// The interstitial could be used separately without all this loading logic stuff
const profileInterstitialLoader = {
  shouldLoad: false,
  load: () => {
    profileInterstitialLoader.shouldLoad = true;
  }
};

class ProfileInterstitialWrapper extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      loaded: profileInterstitialLoader.shouldLoad
    };
    profileInterstitialLoader.load = () => {
      this.setState({
        loaded: true
      });
    };
  }
  render() {
    return <ProfileInterstitialAd loaded={this.state.loaded} />;
  }
}

export default ProfileInterstitialWrapper;

export { shouldShowInterstitial, profileInterstitialLoader };
