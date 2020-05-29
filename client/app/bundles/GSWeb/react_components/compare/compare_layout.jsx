import React from 'react';
import PropTypes from 'prop-types';
import { throttle, debounce } from 'lodash';
import $ from 'jquery';
import { XS, SM, LG, MD, validSizes } from 'util/viewport';
import OpenableCloseable from 'react_components/openable_closeable';
import Button from 'react_components/button';
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

class CompareLayout extends React.Component {
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

  renderBreadcrumbsContainer(){
    const pinnedSchool = this.props.pinnedSchool
    const name = <a href={pinnedSchool.links.profile}>{pinnedSchool.name}</a>
    return(
      <div className="menu-bar">
        <span className="label">{t('compare_test_scores_for')}</span>
          {this.props.breakdownSelect}
          <span>{t('from')} {name} {t('to_nearby_schools')}:</span>
          {this.props.distanceFilter}
      </div>
    )
  }

  renderFilterBar(){
    return(
      <div className="subheader menu-bar">
        <div className="menu-item sort-dropdown-table-view">
          <span className="label">{t('Sort by')}:</span>
          {this.props.sortSelect}
        </div>
      </div>
    )
  }

  renderSchoolTable(){
    return this.props.schoolTable;
  }

  render() {
    return (
      <React.Fragment>
        {this.props.searchBox}
        {this.renderBreadcrumbsContainer()}
        {this.props.noCompareResults ? (
          this.props.noCompareResults
        ) : (
          <React.Fragment>
            {this.renderFilterBar()}
            {this.renderSchoolTable()}
          </React.Fragment>
        )}
      </React.Fragment>
    );
  }
}

export default CompareLayout;
