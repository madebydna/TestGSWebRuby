import React from 'react';
import PropTypes from 'prop-types';
import { XS, SM, LG, MD, validSizes } from 'util/viewport';
import OpenableCloseable from 'react_components/openable_closeable';
import Button from 'react_components/button';
import Ad from 'react_components/ad';
import { t, capitalize } from 'util/i18n';
import { keepInViewport } from 'util/sticky';

class StateLayout extends React.Component {
  static propTypes = {
    viewportSize: PropTypes.oneOf(validSizes).isRequired,
    searchBox: PropTypes.element.isRequired,
    breadcrumbs: PropTypes.element,
    shouldDisplayDistricts: PropTypes.bool,
    shouldDisplayReviews: PropTypes.bool,
    hasSchoolLevelData: PropTypes.bool
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
    let { nameLong } = this.props.locality;
    return t('state.state_hero_title', { parameters: { nameLong }});
  }

  heroNarration(){
    let { nameLong } = this.props.locality;
    let schoolCount = this.props.schoolCount.toLocaleString();

    return t('state.state_hero_narrative_html', { parameters: { nameLong, schoolCount } });
  }

  renderHero(){
    return (<div id="hero">
      <div>
        <h1 className="state-hero-title">{this.heroTitle()}</h1>
        <div className="state-hero-narrative">{this.heroNarration()}</div>
      </div>
    </div>);
  }

  renderBreadcrumbs(){
    return <div className="breadcrumbs-container" ref={this.breadcrumbs}>{this.props.breadcrumbs}</div>
  }

  renderBoxAd() {
    return <div id="second-ad">
      <Ad slot="statepage_second" sizeName="box"/>
    </div>
  }

  renderDesktopAd(){
    return this.props.viewportSize > SM && <div className="ad-bar sticky" >
        <Ad slot="statepage_first" sizeName="box_or_tall" />
    </div>
  }

  renderToc(){
    return this.props.viewportSize > XS && <div ref={this.toc} className="toc sticky">{this.props.toc}</div>
  }

  renderDistricts(){
    let { nameLong } = this.props.locality;

    return this.props.shouldDisplayDistricts && (
      <div id="districts" className="module-section">
        <div className="modules-title">{t('state.districts_header', { parameters: { nameLong }})}</div>
          {this.props.districtsInState}
      </div>
    )
  }

  renderAcademics() {
    return (
      <div id="academics" className="module-section">
        {this.props.academics}
      </div>
    )
  }

  renderSchoolLevelData(){
    if (this.props.browseSchools) {
      return (
        <React.Fragment>
          <div className="modules-title">{t('state.explore_by_type')}</div>
          { this.props.browseSchools }
        </React.Fragment>
      );
    }
  }

  renderSchools(){
    let { nameLong } = this.props.locality;
    const browseHeader = t('state.explore_in_state', { parameters: { nameLong }});
    
    return (
      <div id="schools" className="module-section">
        <div className="modules-title">{browseHeader}</div>
        {this.props.topSchools}
        {this.renderSchoolLevelData()}
      </div>
    )
  }

  renderCities() {
    return (
      <div id="cities" className="module-section">
        {this.props.browseCities}
      </div>
    )    
  }

  renderStudentsModule() {
    return (this.props.hasStudentDemographicData &&
      <div id="students" className="module-section">
        {this.props.students}
      </div>
    )
  }
  
  renderCsaModule() {
    return this.props.shouldDisplayCsaInfo && (
      <div id="award-winning-schools" className="module-section">
        {this.props.csaTopSchools}
      </div>
    );
  }

  // CA Advocacy CSA
  renderCaCsaModule() {
    return this.props.locality.nameShort === 'CA' && (
      <div>
        {this.props.caCsaInfo}
      </div>
    );
  }

  renderReviews() {
    return (
      this.props.shouldDisplayReviews &&
        <div id="reviews" className="module-section">
          <div className="rating-container reviews-module">
            <h3>{t('recent_reviews.title')} {`${this.props.locality.nameLong}`}</h3>
            {this.props.recentReviews}
          </div>
        </div>
    )
  }

  render() {
    return (
      <div className="state-body">
        {this.props.searchBox}
        {this.renderBreadcrumbs()}
        {this.renderHero()}
        <div className="below-hero">
          {/*<div className="content">*/}
            {this.renderToc()}
            <div className="community-modules">
              {this.props.viewportSize < SM && <Ad slot="statepage_first" sizeName="thin_banner_mobile" />}
              {this.renderSchools()}
              {this.renderCsaModule()}
              {this.renderCaCsaModule()}
              {this.renderAcademics()}
              {this.renderBoxAd()}
              {this.renderStudentsModule()}
              {this.renderCities()}
              {this.renderDistricts()}
              {this.renderReviews()}
            </div>
          {/*</div>*/}
          {this.renderDesktopAd()}
        </div>
      </div>
    );
  }
}

export default StateLayout;
