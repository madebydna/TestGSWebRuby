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
    locality: PropTypes.object.isRequired
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
        `${[t('Homes for sale near'), t('Rentals near')][this.state.tabIndex]
            } ${
            this.props.locality.city}`
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
          this.props.locality.city,
          this.props.locality.stateShort,
          this.props.locality.zip,
          this.numberOfListings
      )
          .done(data => {
            console.log("DATA:"+JSON.stringify(data));
            if (data && data.response && data.response.results) {
              this.setState({
                listings: data.response.results.map(decorateListing)
              });
            }
          })
          .fail(data => {
            console.log("DATA:"+JSON.stringify(data));
            this.setState({
              listings: []
            });
          });
    } catch (e) {
      console.log("DATAe:"+e);
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
    const tabs = this.tabNames.reduce(
        (accum, name, index) => ({ ...accum, [index]: name }),
        {}
    );
    return (
        <ButtonGroup
            activeOption={this.state.tabIndex.toString()}
            options={tabs}
            onSelect={this.tabSwitched.bind(this)}
        />
    );
  }

  renderHome(listing) {
    return (
        <div className="tile-container">
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
                href={borrowingPageUrl()}
            >
              <span className="icon-house prs" />
              {t('See how much you can afford to borrow')}
            </AnchorButton>
            <AnchorButton
                className="bold-anchor"
                rel="nofollow"
                target="_blank"
                href={nearbyHomesUrl(this.props.locality.city, this.props.locality.stateShort)}
            >
              {t('See more listings in this city')}
            </AnchorButton>
            <img className="zillow-logo" src={zillowLogo} />
          </div>
        </div>
    );
  }
}
