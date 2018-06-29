import React from 'react';
import PropTypes from 'prop-types';
import { throttle, debounce } from 'lodash';
import $ from 'jquery';
import { SM, validSizes } from 'util/viewport';
import OpenableCloseable from 'react_components/openable_closeable';
import Button from 'react_components/button';
import SearchBox from '../search_box';
import { t } from 'util/i18n';
import suggest from 'api_clients/autosuggest';

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

class SearchLayout extends React.Component {
  static defaultProps = {
    breadcrumbs: null
  };

  static propTypes = {
    size: PropTypes.oneOf(validSizes).isRequired,
    currentView: PropTypes.string.isRequired,
    gradeLevelButtons: PropTypes.element.isRequired,
    entityTypeDropdown: PropTypes.element.isRequired,
    gradeLevelCheckboxes: PropTypes.element.isRequired,
    distanceFilter: PropTypes.element.isRequired,
    sortSelect: PropTypes.element.isRequired,
    listMapDropdown: PropTypes.element.isRequired,
    schoolList: PropTypes.element.isRequired,
    map: PropTypes.element.isRequired,
    tallAd: PropTypes.element.isRequired,
    searchBox: PropTypes.element.isRequired,
    breadcrumbs: PropTypes.element
  };

  constructor(props) {
    super(props);
    this.fixedYLayer = React.createRef();
    this.header = React.createRef();
  }

  componentDidMount() {
    keepInViewport(this.header, {
      initialTop: 60,
      setTop: true,
      setBottom: false
    });
    keepInViewport(this.fixedYLayer, {
      $elementsAbove: [$('.header_un')],
      $elementsBelow: [$('.footer')],
      setTop: true,
      setBottom: true
    });
  }

  shouldRenderMap() {
    return this.props.size > SM || this.props.currentView === 'map';
  }

  shouldRenderList() {
    return this.props.size > SM || this.props.currentView === 'list';
  }

  renderMapAndAdContainer(map, ad) {
    if (this.props.size > SM) {
      return (
        <div key="right-column" className="right-column">
          <div className="right-column-fixed" ref={this.fixedYLayer}>
            <div className="ad-column">{ad}</div>
            <div className="map-column">{map}</div>
          </div>
        </div>
      );
    }
    return (
      <div
        key="right-column"
        className={`right-column ${this.shouldRenderMap() ? ' ' : 'closed'}`}
      >
        <div className="right-column-fixed">
          <div className="ad-column">{ad}</div>
          <div className="map-column">{map}</div>
        </div>
      </div>
    );
  }

  renderDesktopFilterBar() {
    return (
      <div className="menu-bar filters" ref={this.header}>
        <div style={{ margin: 'auto', padding: '0 10px' }}>
          <span className="menu-item">{this.props.entityTypeDropdown}</span>
          <span className="menu-item">{this.props.gradeLevelButtons}</span>
          <span className="menu-item">{this.props.searchBox}</span>
          {this.props.distanceFilter ? (
            <span className="menu-item">
              <span className="label">Distance:</span>
              <span>{this.props.distanceFilter}</span>
            </span>
          ) : null}
        </div>
      </div>
    );
  }

  renderMobileMenuBar() {
    return (
      <OpenableCloseable openByDefault>
        {(isOpen, { toggle, close }) => (
          <div>
            <div className="menu-bar mobile-filters">
              <Button
                key="filter"
                label="Filter"
                active={isOpen}
                onClick={toggle}
                onKeyPress={toggle}
              />
              <span className="menu-item">{this.props.listMapDropdown}</span>
            </div>
            {isOpen ? (
              <div className="filter-panel">
                <span
                  className="icon-close"
                  onClick={close}
                  onKeyPress={close}
                  role="button"
                />
                <div className="menu-bar">
                  <span className="menu-item">
                    <span className="label">{t('School type and level')}:</span>
                    {this.props.entityTypeDropdown}
                  </span>
                  <span className="menu-item">
                    {this.props.gradeLevelCheckboxes}
                  </span>
                  <span className="menu-item">
                    <span className="label">Sort by:</span>
                    {this.props.sortSelect}
                  </span>
                </div>
                {/* <div className="controls">
                    <button onClick={close}>Done</button>
                  </div> */}
              </div>
            ) : null}
          </div>
        )}
      </OpenableCloseable>
    );
  }

  render() {
    return (
      <div className="search-body">
        {this.props.size > SM
          ? this.renderDesktopFilterBar()
          : this.renderMobileMenuBar()}
        <div className="subheader menu-bar">
          {this.props.breadcrumbs}
          <div className="pagination-summary">{this.props.resultSummary}</div>
          {this.props.size > SM && (
            <div className="menu-item">
              <span className="label">Sort by:</span>
              {this.props.sortSelect}
            </div>
          )}
        </div>
        <div className="list-map-ad clearfix">
          <div
            className={`list-column ${
              this.shouldRenderList() ? ' ' : 'closed'
            }`}
          >
            {this.props.schoolList}
          </div>
          {this.renderMapAndAdContainer(
            <div className="map-fit">{this.props.map}</div>,
            this.props.tallAd
          )}
          {this.props.pagination}
        </div>
      </div>
    );
  }
}

export default SearchLayout;
