import React from 'react';
import PropTypes from 'prop-types';
import { setVisibilityCallback } from '../util/visibility_hooks';
import {
  fetchHomesAndRentals,
  decorateListing,
  addCampaignCode,
  nearbyHomesUrl,
  borrowingPageUrl
} from '../api_clients/homes_and_rentals';
import ButtonGroup from './buttongroup';
import AnchorButton from './anchor_button';
import zillowLogo from 'ZG_Logo_82x22.png';
import { t } from '../util/i18n';

export default class HomesAndRentals extends React.Component {
  static propTypes = {
    city: PropTypes.string.isRequired,
    state: PropTypes.string.isRequired,
    zip: PropTypes.string.isRequired,
    schoolName: PropTypes.string.isRequired,
    domId: PropTypes.string
  };

  static defaultProps = {
    domId: 'homes-and-rentals'
  };

  constructor(props) {
    super(props);
    this.tabNames = [t('Homes for sale'), t('Homes for rent')];
    this.renderHome = this.renderHome.bind(this);
    this.numberOfListings = 3;

    this.state = {
      initialized: false, // initialized once when components comes into view
      tabIndex: 0,
      listings: []
    };
  }

  title() {
    return (
      `${[t('Homes for sale near'), t('Rentals near')][this.state.tabIndex] 
      } ${ 
      this.props.schoolName}`
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

  fetchData() {
    try {
      fetchHomesAndRentals(
        this.forSaleOrForRent(),
        this.props.city,
        this.props.state,
        this.props.zip,
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
      (label, index) => ({ key: index, label })
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
          href={listing.detailPageLink()}
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
      return <div className="tile-container">No listings found</div>;
    }
    return this.state.listings.map(this.renderHome);
  }

  render() {
    if (!this.state.initialized) {
      return <div id={this.props.domId} />;
    }

    return (
      <div id={this.props.domId}>
        <div className="title-bar">
          <div className="title">{this.title()}</div>
          <div className="tabs">{this.renderTabs()}</div>
        </div>
        <div className="tiles">{this.renderHomesAndRentals()}</div>
        <div className="cta-buttons">
          <AnchorButton
            className="bold-anchor"
            rel="nofollow"
            target="_blank"
            href={nearbyHomesUrl(this.props.city, this.props.state)}
          >
            {t('See more listings near this school')}
          </AnchorButton>
          <img src={zillowLogo} />
        </div>
      </div>
    );
  }
}
