import React from 'react';
import PropTypes from 'prop-types';
import { XS, SM, LG, MD, validSizes } from 'util/viewport';
import OpenableCloseable from 'react_components/openable_closeable';
import Button from 'react_components/button';
import Ad from 'react_components/ad';
import { t, capitalize } from 'util/i18n';
import { keepInViewport } from 'util/sticky';
import { NEIGHBORING_CITIES } from './toc_config';
import CityLinks from './city_links';

class CityLayout extends React.Component {
  static propTypes = {
    viewportSize: PropTypes.oneOf(validSizes).isRequired,
    searchBox: PropTypes.element.isRequired,
    breadcrumbs: PropTypes.element,
    shouldDisplayReviews: PropTypes.bool,
    shouldDisplayDistricts: PropTypes.bool,
    neighboringCities: PropTypes.arrayOf(PropTypes.object)
  };

  constructor(props) {
    super(props);
    this.ad = React.createRef();
    this.breadcrumbs = React.createRef();
    this.toc = React.createRef();
    this.state = {}
  }

  componentDidMount() {
    keepInViewport(this.breadcrumbs, {
      initialTop: 60,
      setTop: true,
      setBottom: false
    });
    keepInViewport(this.ad, {
      $elementsAbove: [$('.header_un')],
      $elementsBelow: [$('.footer')],
      setTop: true,
      setBottom: true
    });
    keepInViewport(this.toc, {
      $elementsAbove: [$('.header_un')],
      $elementsBelow: [$('.footer')],
      setTop: true,
      setBottom: true
    });
  }

  heroTitle(){
    let {city, stateShort} = this.props.locality;
    return `${city}, ${stateShort}`
  }

  heroNarration(){
    let {city,stateLong,county} = this.props.locality;    
    if (county) {
      return <div
        dangerouslySetInnerHTML={{
          __html: t('city_hero_html', { parameters: { city, stateLong, county } })
        }}
      />
    }else{
      return <div
        dangerouslySetInnerHTML={{
          __html: t('city_hero_no_county_html', { parameters: { city, stateLong } })
        }}
      />
    }
  }

  renderHero(){
    return (<div id="hero">
      <div>
        <div className="icon-city"></div>
        <h1 className="hero-title">{this.heroTitle()}</h1>
        {this.heroNarration()}
      </div>
    </div>)
  }

  renderBreadcrumbs(){
    return <div className="breadcrumbs-container" ref={this.breadcrumbs}>{this.props.breadcrumbs}</div>
  }

  renderBoxAd() {
    return <div id="second-ad">
      <Ad slot="citypage_second" sizeName="box"/>
    </div>
  }

  renderDesktopAd(){
    return this.props.viewportSize > SM && <div className="ad-bar sticky" >
        <Ad slot="citypage_first" sizeName="box_or_tall" />
    </div>
  }

  renderToc(){
    return this.props.viewportSize > XS && <div ref={this.toc} className="toc sticky">{this.props.toc}</div>
  }

  renderDistricts(){
    return this.props.shouldDisplayDistricts && (
      <div id="districts" className="module-section">
        <h2 className="modules-title">{`${t('Public school districts in')} ${this.props.locality.city}`}</h2>
          {this.props.districtsInCity}
      </div>
    )
  }

  renderSchools(){
    return (
      <div id="schools" className="module-section">
        <h2 className="modules-title">{`${t('find_schools_in')} ${this.props.locality.city}`}</h2>
        {this.props.browseSchools}
        {this.props.topSchools}
      </div>
    )
  }

  renderCsaModule() {
    return this.props.shouldDisplayCsaInfo && (
      <div>
        {this.props.csaInfo}
      </div>
    );
  }

  // CA Advocacy CSA
  renderCaCsaModule() {
    return this.props.locality.stateShort === 'CA' && (
      <div>
        {this.props.caCsaInfo}
      </div>
    );
  }

  renderZillow(){
    return (
      this.props.zillow
    )
  }

  renderReviews() {
    return (
      this.props.shouldDisplayReviews &&
        <div id="reviews" className="module-section">
          <div className="rating-container reviews-module">
            <h3>{t('recent_reviews.title')} {`${this.props.locality.city}`}</h3>
            {this.props.recentReviews}
          </div>
        </div>
    )
  }
  
  renderMobility(){
    return(
      <div id="mobility" className="module-section">
        <h2 className="modules-title">{`${t('mobility.title')} ${this.props.locality.city}`}</h2>
        {this.props.mobility}
      </div>
    )
  }

  renderNeighboringCities(){
    if (this.props.neighboringCities == 0) return;
    return(
      <div id="neighboring-cities" className="module-section">
        <section className="links-module">
          <h3>{t(NEIGHBORING_CITIES)}</h3>
          <ul>
            <CityLinks cities={this.props.neighboringCities} size={this.props.viewportSize} />
          </ul>
        </section>
      </div>
    )
  }

  render() {
    return (
      <div className="city-body">
        {this.props.searchBox}
        {this.renderBreadcrumbs()}
        {this.renderHero()}
        <div className="below-hero">
          {/*<div className="content">*/}
            {this.renderToc()}
            <div className="community-modules">
              {this.props.viewportSize < SM && <Ad slot="citypage_first" sizeName="thin_banner_mobile" />}
              {this.renderSchools()}
              {this.renderBoxAd()}
              {this.renderCsaModule()}
              {this.renderCaCsaModule()}
              {this.renderDistricts()}
              {this.renderMobility()}
              {this.renderZillow()}
              {this.renderReviews()}
              {this.renderNeighboringCities()}
            </div>
          {/*</div>*/}
          {this.renderDesktopAd()}
        </div>
      </div>
    );
  }
}

export default CityLayout;
