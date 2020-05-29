import React from 'react';
import PropTypes from 'prop-types';
import Modal from 'react_components/modal';
import NewAd from 'react_components/new_ad';
import { get as getCookie, set as setCookie } from 'js-cookie';
import { translateWithDictionary } from 'util/i18n';

const t = translateWithDictionary({
  en: {
    thanks_text:
      'GreatSchools thanks the foundations and advertisers that make it possible to provide our site free to millions of parents. To skip this ad, ',
    ad_will_close: 'This ad will close in {seconds} seconds.'
  },
  es: {
    'click here': 'haga clic aquí',
    thanks_text:
      'GreatSchools agradece a las fundaciones y los publicistas que hacen posible ofrecer nuestro sitio de forma gratuita a millones de padres. Para cerrar este anuncio, ',
    ad_will_close: 'This ad will close in {seconds} seconds.'
  }
});

const COOKIE_NAME = 'gs_interstitial';
const INTERSTITIAL_VIEWED = 'viewed';

const trackInterstitialViewed = () => {
  setCookie(COOKIE_NAME, INTERSTITIAL_VIEWED);
  return true;
};

const searchRegExp = /search\.page/;
const browseExp = /\/schools\/|\?/;
const STATE_HASH = {
  alabama: 'al',
  alaska: 'ak',
  arizona: 'az',
  arkansas: 'ar',
  california: 'ca',
  colorado: 'co',
  connecticut: 'ct',
  delaware: 'de',
  'district of columbia': 'dc',
  'washington dc': 'dc',
  florida: 'fl',
  georgia: 'ga',
  hawaii: 'hi',
  idaho: 'id',
  illinois: 'il',
  indiana: 'in',
  iowa: 'ia',
  kansas: 'ks',
  kentucky: 'ky',
  louisiana: 'la',
  maine: 'me',
  maryland: 'md',
  massachusetts: 'ma',
  michigan: 'mi',
  minnesota: 'mn',
  mississippi: 'ms',
  missouri: 'mo',
  montana: 'mt',
  nebraska: 'ne',
  nevada: 'nv',
  'new hampshire': 'nh',
  'new jersey': 'nj',
  'new mexico': 'nm',
  'new york': 'ny',
  'north carolina': 'nc',
  'north dakota': 'nd',
  ohio: 'oh',
  oklahoma: 'ok',
  oregon: 'or',
  pennsylvania: 'pa',
  'rhode island': 'ri',
  'south carolina': 'sc',
  'south dakota': 'sd',
  tennessee: 'tn',
  texas: 'tx',
  utah: 'ut',
  vermont: 'vt',
  virginia: 'va',
  washington: 'wa',
  'west virginia': 'wv',
  wisconsin: 'wi',
  wyoming: 'wy'
};
let statesPattern = [];
Object.keys(STATE_HASH).forEach(stateName => {
  statesPattern.push(`${stateName.replace(/\s+/, '-')}`);
});
statesPattern = statesPattern.join('|');
const cityHomeRegex = new RegExp(`(${statesPattern})\/[^/]+\/?$`);
const districtHomeRegex = new RegExp(
  `(${statesPattern})\/[^/]+\/[^\\d/]+[^/]*\/?$`
);
window.cityHomeRegex = cityHomeRegex;

const referrerMatches = () =>
  window.document.referrer.indexOf('greatschools.org') > -1 &&
  (searchRegExp.test(window.document.referrer) ||
    browseExp.test(window.document.referrer) ||
    cityHomeRegex.test(window.document.referrer) ||
    districtHomeRegex.test(window.document.referrer));

const hasViewedInterstitial = () =>
  getCookie(COOKIE_NAME) === INTERSTITIAL_VIEWED;

const shouldShowInterstitial = () =>
  referrerMatches() && !hasViewedInterstitial();

const ProfileInterstitialAd = ({ loaded }) =>
  shouldShowInterstitial() && loaded ? (
    <Modal closeOnOutsideClick={false} className="interstitial-modal">
      {({ openForDuration, close, remainingTime }) => (
        <NewAd
          slot="greatschools_Prestitial"
          container={<React.Fragment />}
          onFill={() =>
            trackInterstitialViewed() && openForDuration(20000, 1000)
          }
        >
          {adElement => (
            <React.Fragment>
              <p>
                {t('thanks_text')}{' '}
                {
                  <a onClick={close} style={{ cursor: 'pointer' }}>
                    {t('click here')} »
                  </a>
                }
              </p>
              {adElement}
              <div className="timer">
                {t('ad_will_close', {
                  parameters: { seconds: remainingTime / 1000 }
                })}
              </div>
            </React.Fragment>
          )}
        </NewAd>
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
