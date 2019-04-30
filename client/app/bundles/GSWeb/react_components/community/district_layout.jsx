import React from 'react';
import PropTypes from 'prop-types';
import { XS, SM, LG, MD, validSizes } from 'util/viewport';
import OpenableCloseable from 'react_components/openable_closeable';
import Button from 'react_components/button';
import Ad from 'react_components/ad';
import { t, capitalize } from 'util/i18n';
import { keepInViewport } from 'util/sticky';
import xq from 'community/xq-sm.png';

class DistrictLayout extends React.Component {
  static propTypes = {
    viewportSize: PropTypes.oneOf(validSizes).isRequired,
    searchBox: PropTypes.element.isRequired,
    breadcrumbs: PropTypes.element,
    heroData: PropTypes.object,
    shouldDisplayReviews: PropTypes.bool
  };

  constructor(props) {
    super(props);
    this.ad = React.createRef();
    this.breadcrumbs = React.createRef();
    this.toc = React.createRef();
    this.zillow = React.createRef();
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

  renderNarration(narration) {
    if (narration){
      return <div className='district-hero-narrative'>{narration}</div>
    }
  }

  renderZillow(){
    return (
        <div>
          {this.props.zillow}
        </div>
    )
  }

  renderAcademics(){
    return (
      <div id="academics">
        {this.props.academics}
      </div>
    )
  }

  renderCalendar() {
    return (
      <div id="calendar">
        <h2 className="modules-title">{t('district_calendar')}</h2>
        {this.props.calendar}
      </div>
    )
  }

  renderMobility() {
    return (
      <div id="mobility">
        <h2 className="modules-title">{`${t('mobility.title')} ${this.props.locality.name}`}</h2>
        {this.props.mobility}
      </div>
    )
  }

  renderHero() {
    let {name, address, city, stateShort, zipCode, phone, districtUrl} = this.props.locality;
    let {enrollment, grades, schoolCount, narration} = this.props.heroData;
    return (
      <div id="hero">
        <div>
          <div className="icon-nearby_2"></div>
          <h1 className="district-hero-title">{name}</h1>
          <div className="district-hero-contact-info">
            {address && <span className="content">{address}, {city}, {stateShort} {zipCode}</span>}
            {phone && <span className="badge-and-content phone">
              <span className="badge icon-phone"></span>
              <span className="content">{phone}</span>
            </span>}
            {districtUrl && <span className="badge-and-content link">
              <span className="badge icon-link"/>
              <span><a className="content" href={districtUrl}>{t('website')}</a></span>
            </span>
            }
          </div>
          {  this.renderNarration(narration)}
          <div className="district-hero-stats">
            <div>
              <div>{t('schools').toUpperCase()}</div>
              <div>{schoolCount}</div>
            </div>
            {enrollment ? <div>
              <div>{t('students').toUpperCase()}</div>
              <div>{enrollment.toLocaleString()}</div>
            </div> : null}
            <div>
              <div>{t('Grades').toUpperCase()}</div>
              <div>{grades}</div>
            </div>
          </div>
        </div>
      </div>)
  }

  renderBreadcrumbs(){
    return <div className="breadcrumbs-container" ref={this.breadcrumbs}>{this.props.breadcrumbs}</div>
  }

  renderBoxAd() {
    return <div id="second-ad">
      <Ad slot="districtpage_second" sizeName="box"/>
    </div>
  }

  renderDesktopAd(){
    return (
      this.props.viewportSize > SM && <div className="ad-bar sticky" >
        <Ad slot="districtpage_first" sizeName="box_or_tall" />
      </div>
    )
  }

  renderToc(){
    return this.props.viewportSize > XS && <div ref={this.toc} className="toc sticky">{this.props.toc}</div>
  }

  renderSchools() {
    return (
      <div id="schools">
        <h2 className="modules-title">{`${t('find_schools_in')} ${this.props.locality.name}`}</h2>
        <div className="xq-partnership">
          {this.props.translations.inPartnershipWith}
          <a href='https://xqsuperschool.org/school-board-thing' target="_blank" rel="nofollow">
            <img src={xq} alt='xq icon' />
          </a>
        </div>
        {this.props.browseSchools}
        {this.props.schoolCounts.all > 0 ? this.props.topSchools: null}
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

  renderReviews(){
    return (
      this.props.shouldDisplayReviews &&
      <div id="reviews">
        <div className="rating-container reviews-module">
          <h3>{t('recent_reviews.title')} {`${this.props.locality.name}`}</h3>
          {this.props.recentReviews}
        </div>
      </div>
    )
  }

  render() {
    return (
      <div className="district-body">
        {this.props.searchBox}
        {this.renderBreadcrumbs()}
        {this.renderHero()}
        <div className="below-hero">
          {this.renderToc()}
          <div className="community-modules">
            {this.props.viewportSize < SM && <Ad slot="districtpage_first" sizeName="thin_banner_mobile" />}
            {this.renderSchools()}
            {this.renderBoxAd()}
            {this.renderCsaModule()}
            {this.renderAcademics()}
            {this.renderCalendar()}
            {this.renderMobility()}
            {this.renderZillow()}
            {this.renderReviews()}
          </div>
          {this.renderDesktopAd()}
        </div>
      </div>
    );
  }
}

export default DistrictLayout;
