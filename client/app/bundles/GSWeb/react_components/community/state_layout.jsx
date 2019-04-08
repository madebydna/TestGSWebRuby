import React from 'react';
import PropTypes from 'prop-types';
import { XS, SM, LG, MD, validSizes } from 'util/viewport';
import OpenableCloseable from 'react_components/openable_closeable';
import Button from 'react_components/button';
import Ad from 'react_components/ad';
import { t, capitalize } from 'util/i18n';
import { keepInViewport } from 'util/sticky';
import csaBadgeGenLg from 'school_profiles/csa_generic_badge_lg_icon.png';

class StateLayout extends React.Component {
  static propTypes = {
    viewportSize: PropTypes.oneOf(validSizes).isRequired,
    searchBox: PropTypes.element.isRequired,
    breadcrumbs: PropTypes.element,
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

  // AC_TODO: Add Spanish translation for Schools
  heroTitle(){
    let {nameLong} = this.props.locality;
    return `${nameLong} Schools`;
  }

  // AC_TODO: Add Spanish translation for hero blurb
  heroNarration(){
    let {nameLong} = this.props.locality;
    let schoolCount = this.props.schoolCount;

    return <div
        dangerouslySetInnerHTML={{
          __html: t('state_hero_html', { parameters: { nameLong, schoolCount } })
        }}
      />;
  }

  renderHero(){
    return (<div id="hero">
      <div>
        {/* <div className="icon-city"></div> */}
        <h1 className="city-hero-title">{this.heroTitle()}</h1>
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
        <div className="modules-title">{`${t('Public school districts in')} ${this.props.locality.city}`}</div>
          {this.props.districtsInCity}
      </div>
    )
  }

  // AC_TODO: Add translations
  renderCities(){
    const browseHeader = `Browse schools in ${this.props.locality.nameLong} by`;

    return (
      <div id="schools">
        {}
        <div className="modules-title">{browseHeader}</div>
        {this.props.browseCities}
      </div>
    )
  }

  renderCsaModule() {
    const csaStateLink = this.props.locality.stateCsaUrl;

    if (this.props.csaModule) {
      return (
        <div className="csa-state-module">
          <h3>{t('award_winners')}</h3>
          <div className="csa-state-blurb">
            <img 
              src={csaBadgeGenLg}
              className="csa-badge-gen-lg"
              alt="csa-badge-icon"
            />
            <p>
              <span dangerouslySetInnerHTML={{__html: t("csa_district_schools_info_html")}}/>
            </p>
          </div>
          <div className="more-school-btn">
            <a href={csaStateLink}>
              <button>{t('see_all_winning_schools')}</button>
            </a>
          </div>
        </div>
      );
    }
  }

  // renderZillow(){
  //   return (
  //       <div>
  //         {this.props.zillow}
  //       </div>
  //   )
  // }

  render() {
    return (
      <div className="city-body">
        {this.props.searchBox}
        {/* {this.renderBreadcrumbs()} */}
        {this.renderHero()}
        <div className="below-hero">
          {/*<div className="content">*/}
            {this.renderToc()}
            <div className="community-modules">
              {this.props.viewportSize < SM && <Ad slot="citypage_first" sizeName="thin_banner_mobile" />}
              {this.renderCities()}
              {this.renderCsaModule()}
              {/* {this.renderBoxAd()}
              {this.renderDistricts()}
              {this.renderZillow()} */}
            </div>
          {/*</div>*/}
          {this.renderDesktopAd()}
        </div>
      </div>
    );
  }
}

export default StateLayout;
