import React from 'react';
import PropTypes from 'prop-types';
import { throttle, debounce } from 'lodash';
import $ from 'jquery';
import { SM, validSizes } from 'util/viewport';
import OpenableCloseable from 'react_components/openable_closeable';
import Button from 'react_components/button';
import { t } from 'util/i18n';
import { LIST_VIEW, MAP_VIEW, TABLE_VIEW } from './search_context';
import CaptureOutsideClick from './capture_outside_click';

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
    breadcrumbs: null,
    distanceFilter: null,
    pagination: null
  };

  static propTypes = {
    size: PropTypes.oneOf(validSizes).isRequired,
    view: PropTypes.string.isRequired,
    gradeLevelButtons: PropTypes.element.isRequired,
    entityTypeDropdown: PropTypes.element.isRequired,
    gradeLevelCheckboxes: PropTypes.element.isRequired,
    distanceFilter: PropTypes.element,
    sortSelect: PropTypes.element.isRequired,
    listMapTableSelect: PropTypes.element.isRequired,
    schoolList: PropTypes.element.isRequired,
    schoolTable: PropTypes.element.isRequired,
    map: PropTypes.element.isRequired,
    tallAd: PropTypes.element.isRequired,
    searchBox: PropTypes.element.isRequired,
    breadcrumbs: PropTypes.element,
    pagination: PropTypes.element,
    resultSummary: PropTypes.string.isRequired
  };

  static getDerivedStateFromProps(props) {
    if (
      props.view === MAP_VIEW ||
      (props.size > SM && props.view !== TABLE_VIEW)
    ) {
      return {
        hasShownMap: true
      };
    }
    return {};
  }

  constructor(props) {
    super(props);
    this.fixedYLayer = React.createRef();
    this.header = React.createRef();
    this.state = {
      hasShownMap: this.shouldRenderMap()
    };
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
    return (
      this.props.view === MAP_VIEW ||
      (this.props.size > SM && this.props.view !== TABLE_VIEW)
    );
  }

  shouldRenderList() {
    return (
      this.props.view === LIST_VIEW ||
      (this.props.size > SM && this.props.view !== TABLE_VIEW)
    );
  }

  shouldRenderTable() {
    return this.props.view === TABLE_VIEW;
  }

  renderTableView() {
    return this.props.schoolTable;
  }

  renderMapAndAdContainer(map, ad) {
    if (!this.state.hasShownMap) {
      return null;
    }
    if (this.props.size > SM) {
      return (
        <div
          key="right-column"
          className={`right-column ${this.shouldRenderMap() ? ' ' : 'closed'}`}
        >
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
        {this.props.searchBox}
        <div style={{ margin: 'auto' }}>
          <span className="menu-item">{this.props.entityTypeDropdown}</span>
          <span className="menu-item">{this.props.gradeLevelButtons}</span>
          {this.props.distanceFilter ? (
            <span className="menu-item">
              <span className="label">Distance:</span>
              <span>{this.props.distanceFilter}</span>
            </span>
          ) : null}
          <span className="menu-item list-map-toggle">
            {this.props.listMapTableSelect}
          </span>
        </div>
      </div>
    );
  }

  renderMobileMenuBar() {
    return (
      <OpenableCloseable openByDefault={this.props.view === LIST_VIEW}>
        {(isOpen, { toggle, close }) => (
          <div>
            {this.props.searchBox}
            <div className="menu-bar mobile-filters">
              <span className="menu-item list-map-toggle">
                {this.props.listMapTableSelect}
              </span>
              <span className="menu-item">
                <span className="button-group">
                  <Button
                    key="filter"
                    label={t('Filter')}
                    active={isOpen}
                    onClick={toggle}
                    onKeyPress={toggle}
                    className="js-filter-button"
                  />
                </span>
              </span>
            </div>
            {isOpen ? (
              <CaptureOutsideClick
                callback={toggle}
                ignoreClassNames={['js-filter-button']}
              >
                <div className="filter-panel">
                  <span
                    className="icon-close"
                    onClick={close}
                    onKeyPress={close}
                    role="button"
                  />
                  <div>
                    <span className="menu-item">
                      <span className="label">
                        {t('School type and level')}:
                      </span>
                      {this.props.entityTypeDropdown}
                    </span>
                    <span className="menu-item">
                      {this.props.gradeLevelButtons}
                    </span>
                    <span className="menu-item">
                      <span className="label">{t('Sort by')}:</span>
                      {this.props.sortSelect}
                    </span>
                  </div>
                  {/* <div className="controls">
                    <button onClick={close}>Done</button>
                  </div> */}
                </div>
              </CaptureOutsideClick>
            ) : null}
          </div>
        )}
      </OpenableCloseable>
    );
  }

  renderBreadcrumbsSummarySort() {
    return (
      !(this.shouldRenderMap() && this.props.size <= SM) && (
        <div className="subheader menu-bar">
          {this.props.breadcrumbs}
          <div className="pagination-summary">{this.props.resultSummary}</div>
          {this.props.size > SM && (
            <div className="menu-item">
              <span className="label">{t('Sort by')}:</span>
              {this.props.sortSelect}
            </div>
          )}
        </div>
      )
    );
  }

  render() {
    return (
      <div className="search-body">
        {this.props.size > SM
          ? this.renderDesktopFilterBar()
          : this.renderMobileMenuBar()}
        {this.renderBreadcrumbsSummarySort()}
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
          {this.shouldRenderTable() ? this.renderTableView() : null}
          {this.props.pagination}
        </div>
      </div>
    );
  }
}

export default SearchLayout;
