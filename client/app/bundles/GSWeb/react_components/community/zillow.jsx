import React from 'react';
import PropTypes from 'prop-types';
import { setVisibilityCallback } from 'util/visibility_hooks';
import {
  fetchHomesAndRentals,
  decorateListing,
  addCampaignCode,
  nearbyHomesUrl,
  borrowingPageUrl
} from 'api_clients/homes_and_rentals';
import ButtonGroup from '../buttongroup';
import AnchorButton from '../anchor_button';
import zillowLogo from 'ZG_Logo_82x22.png';
import { t } from 'util/i18n';

export default class Zillow extends React.Component {
  static propTypes = {
    locality: PropTypes.object.isRequired,
    utmCampaign: PropTypes.string.isRequired,
    pageType: PropTypes.string.isRequired
  };

  constructor(props) {
    super(props);
    this.tabNames = [t('Homes for sale'), t('Homes for rent')];
    this.renderHome = this.renderHome.bind(this);
    this.numberOfListings = 2;

    this.state = {
      initialized: false, // initialized once when components comes into view
      tabIndex: 0,
      listings: []
    };
  }

  static defaultProps = {
    domId: 'homes-and-rentals'
  };

  title() {
    return (
        <React.Fragment>
          {[t('Homes for sale near'), t('Rentals near')][this.state.tabIndex]}
          <br className="rwd-break" />&nbsp;
          {this.props.locality.city}
        </React.Fragment>
    );
  }

  forSaleOrForRent() {
    return ['forSale', 'forRent'][this.state.tabIndex];
  }

  componentDidMount() {
    setVisibilityCallback(
        `#${  this.props.domId}`,
        () => this.setState({ initialized: true }),
        -1000
    );
  }

  buttonStringMoreListings(){
    return 'See more listings near this '+this.props.pageType;
  }

  getZipCode() {
    // city page uses zip
    if(this.props.locality.zip){ return this.props.locality.zip;}
    // district page uses zipCode
    if(this.props.locality.zipCode){ return this.props.locality.zipCode;}
  }

  fetchData() {
    try {
      fetchHomesAndRentals(
          this.forSaleOrForRent(),
          this.props.locality.city,
          this.props.locality.stateShort,
          this.getZipCode(),
          this.numberOfListings
      )
          .done(data => {
            if (data && data.response && data.response.results) {
              this.setState({
                listings: data.response.results.map(decorateListing)
              });
            }
          })
          .fail(data => {
            this.setState({
              listings: []
            });
          });
    } catch (e) {
      this.setState({
        listings: []
      });
    }
  }

  componentDidUpdate(prevProps, prevState) {
    if (prevState.initialized == false && this.state.initialized == true) {
      this.fetchData();
    }
  }

  tabSwitched(index) {
    this.setState(
        {
          tabIndex: parseInt(index)
        },
        this.fetchData
    );
  }

  renderTabs() {
    const tabs = this.tabNames.map(
      (label, index) => ({key: index, label }),
    );
    return (
      <ButtonGroup
        activeOption={this.state.tabIndex}
        options={tabs}
        onSelect={this.tabSwitched.bind(this)}
      />
    );
  }

  renderHome(listing, idx) {
    return (
        <div className="tile-container" key={`listing-${idx}`}>
          <a
              className="tile"
              href={listing.detailPageLink(this.props.utmCampaign)}
              target="_blank"
              rel="nofollow"
          >
            <img src={listing.largerImageUrl()} />
            <div className="price">{listing.price()}</div>
            <div className="info">
              <div className="heading">{listing.fullAddress()}</div>
              <div>{listing.pipeSeparatedDetails()}</div>
            </div>
          </a>
        </div>
    );
  }

  renderHomesAndRentals() {
    if (this.state.listings.length == 0) {
      return <div className="tile-container">{t('No listings found')}</div>;
    }
    return this.state.listings.map(this.renderHome);
  }

  render() {
    if (!this.state.initialized) {
      return <div id={this.props.domId} />;
    }

    return (
        <div id={this.props.domId} className="city module-section">
          <div className="title-bar">
            <h2 className="title city">{this.title()}</h2>
            <div className="tabs">{this.renderTabs()}</div>
          </div>
          <div className="tiles">{this.renderHomesAndRentals()}</div>
          <div className="cta-buttons">
            <AnchorButton
                className="bold-anchor"
                rel="nofollow"
                target="_blank"
                href={nearbyHomesUrl(this.props.locality.city, this.props.locality.stateShort, this.props.utmCampaign)}
            >
              {t(this.buttonStringMoreListings())}
            </AnchorButton>
            <img className="zillow-logo" src={zillowLogo} />
          </div>
        </div>
    );
  }
}
