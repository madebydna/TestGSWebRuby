import React from 'react';
import PropTypes from 'prop-types';
import { throttle, debounce } from 'lodash';
import $ from 'jquery';
import { XS, SM, LG, MD, validSizes } from 'util/viewport';
import OpenableCloseable from 'react_components/openable_closeable';
import Button from 'react_components/button';
import Ad from 'react_components/ad';
import { t, capitalize } from 'util/i18n';

function keepInViewport(
  ref,
  {
    initialTop = null,
    $elementsAbove = [],
    $elementsBelow = [],
    setTop = true,
    setBottom = true,
    shrink = false
  } = {}
) {
  if (initialTop === null && $(ref.current).size > 0) {
    initialTop = $(ref.current).position().top;
  }

  const updateElementPosition = function updateElementPosition() {
    const $elem = $(ref.current);
    if ($elem.size === 0 || !$elem.position()) {
      return;
    }
    if (initialTop === null) {
      initialTop = $elem.position().top;
    }
    let top = null;
    if (setTop) {
      const YValueOfTopOfViewport = $(window).scrollTop();
      const minTop = $elementsAbove.reduce(
        (sum, $e) => sum + $e.outerHeight(),
        0
      );
      top = Math.max(initialTop - YValueOfTopOfViewport, minTop);
    }

    if (setBottom) {
      const YValueOfBottomOfViewport =
        $(window).scrollTop() + $(window).height();
      const minBottomY = $elementsBelow.reduce(
        (minSoFar, e) => Math.min(minSoFar, e.position().top),
        $('html').height()
      );
      if (shrink) {
        const bottom = Math.max(YValueOfBottomOfViewport - minBottomY, 0);
        $elem.css({ bottom: `${bottom}px` });
      } else {
        let overlap = $elem.offset().top + $elem.height() - minBottomY;
        if (top !== null) {
          overlap += top - $elem.position().top;
        }
        if (overlap > 0) {
          top -= overlap;
        }
      }
    }

    if (top !== null) {
      $elem.css({ top: `${top}px` });
    }
  };
  $(() => {
    $(window).on('scroll', throttle(updateElementPosition, 40));
    $(window).on('resize', debounce(updateElementPosition, 80));
  });
  updateElementPosition();
}

class DistrictLayout extends React.Component {
  static propTypes = {
    viewportSize: PropTypes.oneOf(validSizes).isRequired,
    searchBox: PropTypes.element.isRequired,
    breadcrumbs: PropTypes.element,
    heroData: PropTypes.object
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

  renderMobility() {
    return (
      <div id="mobility">
        <div className="modules-title">{`${t('mobility.title')} ${this.props.locality.name}`}</div>
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
          <div className="district-hero-title">{name}</div>
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

  renderAd(){
    return this.props.viewportSize > XS && <div className="ad-bar sticky" ref={this.ad}>
        <Ad slot="districtpage_first" dimensions={[300, 600]}/>
      </div>
  }

  renderToc(){
    return this.props.viewportSize > MD && <div ref={this.toc} className="toc sticky">{this.props.toc}</div>
  }

  renderSchools() {
    return (
      <div id="schools">
        <div className="modules-title">{`${this.props.locality.name} ${t('at a glance')}`}</div>
        {this.props.browseSchools}
        {this.props.topSchools}
      </div>
    )
  }

  render() {
    return (
      <div className="district-body">
        {this.props.searchBox}
        {this.renderBreadcrumbs()}
        {this.renderHero()}
        {/* {this.renderHero()} */}
        <div className="below-hero">
          {this.renderToc()}
          <div className="community-modules">
            {this.renderSchools()}
            {this.renderMobility()}
            {this.renderZillow()}
          </div>
          {this.renderAd()}
        </div>
      </div>
    );
  }
}

export default DistrictLayout;
