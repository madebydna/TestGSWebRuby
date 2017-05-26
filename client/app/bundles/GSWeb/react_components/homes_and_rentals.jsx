import React, { PropTypes } from 'react';
import { setVisibilityCallback } from '../util/visibility_hooks';
import {
  fetchHomesAndRentals,
  decorateListing,
  addCampaignCode,
  nearbyHomesUrl,
  pricingPageUrl
} from '../api_clients/homes_and_rentals';
import ButtonGroup from './buttongroup';
import AnchorButton from './anchor_button';
import zillowLogo from '../../../../../app/assets/images/zillow_logo_sm.png';

export default class HomesAndRentals extends React.Component {

  static propTypes = {
    city: React.PropTypes.string.isRequired,
    state: React.PropTypes.string.isRequired,
    zip: React.PropTypes.string.isRequired,
    schoolName: React.PropTypes.string.isRequired,
    domId: React.PropTypes.string
  };

  static defaultProps = {
    domId: 'homes-and-rentals'
  }

  constructor(props) {
    super(props);
    this.tabNames = [GS.I18n.t('Homes for sale'), GS.I18n.t('Homes for rent')];
    this.renderHome = this.renderHome.bind(this);
    this.numberOfListings = 3;

    this.state = {
      initialized: false, // initialized once when components comes into view
      tabIndex: 0,
      listings: []
    }
  }

  title() {
    return [
      GS.I18n.t('Homes for sale near'),
      GS.I18n.t('Rentals near')
    ][this.state.tabIndex] + ' ' + this.props.schoolName;
  }

  forSaleOrForRent() {
    return ['forSale', 'forRent'][this.state.tabIndex];
  }

  componentDidMount() {
    setVisibilityCallback(
      '#' + this.props.domId,
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
      ).done(data => {
        if(data && data.response && data.response.results) {
          this.setState({
            listings: data.response.results.map(decorateListing)
          })
        }
      }).fail(data => {
        this.setState({
          listings: []
        });
      });
    } catch(e) {
      this.setState({
        listings: []
      });
    }
  }

  componentDidUpdate(prevProps, prevState) {
    if(prevState.initialized == false && this.state.initialized == true) {
      this.fetchData();
    }
  }

  tabSwitched(index) {
    this.setState({
      tabIndex: parseInt(index)
    }, this.fetchData);
  }

  renderTabs() {
    let tabs = this.tabNames.reduce((accum, name, index) => ({...accum, [index]: name}), {});
    return <ButtonGroup
              activeOption={this.state.tabIndex.toString()}
              options={tabs}
              onSelect={this.tabSwitched.bind(this)} />
  }

  renderHome(listing) {
    return (
      <div className="tile-container">
        <a className="tile" href={listing.detailPageLink()} target="_blank" rel="nofollow">
          <img src={listing.largerImageUrl()} />
          <div className="price">{listing.price()}</div>
          <div className="info">
            <div className="heading">{listing.fullAddress()}</div>
            <div>{listing.pipeSeparatedDetails()}</div>
          </div>
        </a>
      </div>
    )
  }

  renderHomesAndRentals() {
    if(this.state.listings.length == 0) {
      return <div className="tile-container">No listings found</div>;
    }
    return this.state.listings.map(this.renderHome);
  }

  render() {
    if(!this.state.initialized) {
      return <div id={this.props.domId}></div>;
    }

    return(
      <div id={this.props.domId}>
        <div className="title-bar">
          <div className="title">{this.title()}</div>
          { this.renderTabs() }
        </div>
        <div className="tiles">
          { this.renderHomesAndRentals() }
        </div>
        <div className="cta-buttons">
          <AnchorButton rel="nofollow" href={pricingPageUrl()}>{ GS.I18n.t('Find out what your home is worth') }</AnchorButton>
          <AnchorButton rel="nofollow" href={nearbyHomesUrl(this.props.city, this.props.state)}>{ GS.I18n.t('See more listings near this school') }</AnchorButton>
          <img src={zillowLogo} />
        </div>
      </div>
    );
  };
}
