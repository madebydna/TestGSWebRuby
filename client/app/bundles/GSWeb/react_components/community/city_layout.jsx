import React from 'react';
import PropTypes from 'prop-types';
import { throttle, debounce } from 'lodash';
import $ from 'jquery';
import { XS, SM, LG, MD, validSizes } from 'util/viewport';
import OpenableCloseable from 'react_components/openable_closeable';
import Button from 'react_components/button';
import Ad from 'react_components/ad';
import { t } from 'util/i18n';

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

class CityLayout extends React.Component {
  static defaultProps = {
    breadcrumbs: null,
  };

  static propTypes = {
    size: PropTypes.oneOf(validSizes).isRequired,
    searchBox: PropTypes.element.isRequired,
    breadcrumbs: PropTypes.element,
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

  renderToc(){
    return null;
  }

  renderCity(){
    return null;
  }

  heroTitle(){
    let {city, state} = this.props.locality;
    return `${city}, ${state}`
  }

  heroNarration(){
    let {city,state,county} = this.props.locality;
    return `${city} is a city in ${county} county, ${state}`
  }

  render() {
    return (
      <div className="city-body">
        {this.props.searchBox}
        <React.Fragment>
            <div className="breadcrumbs-container" ref={this.breadcrumbs}>{this.props.breadcrumbs}</div>
            <div className="hero">
              <div className="icon-house"></div>
              <div className="city-hero-title">{this.heroTitle()}</div>
              <div className="city-hero-narrative">{this.heroNarration()}</div>
              <div className="city-hero-stats"></div>
            </div>
            <div className="below-hero">
              {this.props.viewportSize > MD && <div ref={this.toc} className="toc sticky"></div>}
              <div className="city-modules">
                {this.props.topSchools}
              </div>
              {this.props.viewportSize > XS && <div className="ad-bar sticky" ref={this.ad}>
                <Ad slot="citypage_first" dimensions={[300, 600]} />
              </div>}
            </div>
        </React.Fragment>
      </div>
    );
  }
}

export default CityLayout;
