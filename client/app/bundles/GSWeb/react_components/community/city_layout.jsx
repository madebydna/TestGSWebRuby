import React from 'react';
import PropTypes from 'prop-types';
import { XS, SM, LG, MD, validSizes } from 'util/viewport';
import OpenableCloseable from 'react_components/openable_closeable';
import Button from 'react_components/button';
import Ad from 'react_components/ad';
import { t, capitalize } from 'util/i18n';
import { keepInViewport } from 'util/sticky';

class CityLayout extends React.Component {
  static propTypes = {
    viewportSize: PropTypes.oneOf(validSizes).isRequired,
    searchBox: PropTypes.element.isRequired,
    breadcrumbs: PropTypes.element,
    shouldDisplayReviews: PropTypes.bool,
    shouldDisplayDistricts: PropTypes.bool
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
        <h1>{this.heroTitle()}</h1>
        {this.heroNarration()}
        <div className="city-hero-stats"></div>
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
      <div id="districts">
        <h2 className="modules-title">{`${t('Public school districts in')} ${this.props.locality.city}`}</h2>
          {this.props.districtsInCity}
      </div>
    )
  }

  renderSchools(){
    return (
      <div id="schools">
        <h2 className="modules-title">{`${this.props.locality.city} ${t('at a glance')}`}</h2>
        {this.props.browseSchools}
        {this.props.topSchools}
      </div>
    )
  }

  renderZillow(){
    return (
        <div>
          {this.props.zillow}
        </div>
    )
  }

  renderReviews() {
    return (
      this.props.shouldDisplayReviews &&
        <div id="reviews">
          <div className="rating-container reviews-module">
            <h3>{t('recent_reviews.title')} {`${this.props.locality.city}`}</h3>
            {this.props.recentReviews}
          </div>
        </div>
    )
  }
  
  renderMobility(){
    return(
      <div id="mobility">
        <h2 className="modules-title">{`${t('mobility.title')} ${this.props.locality.city}`}</h2>
        {this.props.mobility}
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
              {this.renderDistricts()}
              {this.renderMobility()}
              {this.renderZillow()}
              {this.renderReviews()}
            </div>
          {/*</div>*/}
          {this.renderDesktopAd()}
        </div>
      </div>
    );
  }
}

export default CityLayout;
