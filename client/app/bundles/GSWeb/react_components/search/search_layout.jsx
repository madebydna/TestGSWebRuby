import React from 'react';
import PropTypes from 'prop-types';
import { throttle, debounce } from 'lodash';
import $ from 'jquery';
import { viewport, SM, validSizes } from 'util/viewport';
import OpenableCloseable from 'react_components/openable_closeable';
// import EntityTypeFilter from './entity_type_filter';

function keepInViewport(
  selector,
  {
    $elementsAbove = [],
    $elementsBelow = [],
    setTop = true,
    setBottom = true
  } = {}
) {
  let initialTop = null;
  if ($(selector).size > 0) {
    initialTop = $(selector).position().top;
  }

  const updateElementPosition = function updateElementPosition() {
    const $elem = $(selector);
    if ($elem.size === 0 || !$elem.position()) {
      return;
    }
    if (initialTop === null) {
      initialTop = $elem.position().top;
    }
    if (setTop) {
      const YValueOfTopOfViewport = $(window).scrollTop();
      const minTop = $elementsAbove.reduce(
        (sum, $e) => sum + $e.outerHeight(),
        0
      );
      const top = Math.max(initialTop - YValueOfTopOfViewport, minTop);
      $elem.css({ top: `${top}px` });
    }

    if (setBottom) {
      const YValueOfBottomOfViewport =
        $(window).scrollTop() + $(window).height();
      const minBottomY = $elementsBelow.reduce(
        (minSoFar, e) => Math.min(minSoFar, e.position().top),
        $('html').height()
      );
      const bottom = Math.max(YValueOfBottomOfViewport - minBottomY, 0);
      $elem.css({ bottom: `${bottom}px` });
    }
  };
  $(() => {
    $(window).on('scroll', throttle(updateElementPosition, 40));
    $(window).on('resize', debounce(updateElementPosition, 80));
  });
}

class SearchLayout extends React.Component {
  static defaultProps = {};

  static propTypes = {
    size: PropTypes.oneOf(validSizes).isRequired,
    currentView: PropTypes.string.isRequired,
    entityTypeButtons: PropTypes.element.isRequired,
    gradeLevelButtons: PropTypes.element.isRequired,
    entityTypeCheckboxes: PropTypes.element.isRequired,
    gradeLevelCheckboxes: PropTypes.element.isRequired,
    distanceFilter: PropTypes.element.isRequired,
    sortSelect: PropTypes.element.isRequired,
    listMapDropdown: PropTypes.element.isRequired,
    schoolList: PropTypes.element.isRequired,
    map: PropTypes.element.isRequired,
    tallAd: PropTypes.element.isRequired
  };

  constructor(props) {
    super(props);
    this.fixedYLayer = React.createRef();
    this.header = React.createRef();
  }

  componentDidMount() {
    keepInViewport(this.header.current, {
      setTop: true,
      setBottom: false
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
        <div className="fixed-y-layer" ref={this.fixedYLayer}>
          <div className="fixed-y-centering">
            <div className="right-column">
              <div className="ad-column">{ad}</div>
              <div className="map-column">{map}</div>
            </div>
          </div>
        </div>
      );
    }
    return (
      <div
        style={{
          height: `${viewport().height - 250}px`,
          width: '400px',
          height: '400px',
          position: 'relative',
          display: this.shouldRenderMap() ? 'block' : 'block'
        }}
      >
        {map}
      </div>
    );
  }

  renderDesktopFilterBar() {
    return (
      <div className="menu-bar filters" ref={this.header}>
        <div style={{ maxWidth: '1282px', margin: 'auto' }}>
          <span className="menu-item">{this.props.entityTypeButtons}</span>
          <span className="menu-item">{this.props.gradeLevelButtons}</span>
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

  renderDesktopSortBar() {
    return (
      <div className="menu-bar sort">
        <span className="menu-item">
          <span>Sort by: </span>
          <span>{this.props.sortSelect}</span>
        </span>
      </div>
    );
  }

  renderMobileMenuBar() {
    return (
      <div className="menu-bar">
        {this.renderMobileFilterPanel()}
        <span className="menu-item">{this.props.listMapDropdown}</span>
      </div>
    );
  }

  renderMobileFilterPanel() {
    return (
      <OpenableCloseable>
        {(isOpen, { toggle, close, open }) => (
          <React.Fragment>
            <span
              className="menu-item"
              onClick={toggle}
              onKeyPress={toggle}
              role="button"
            >
              Filter
            </span>
            {isOpen ? (
              <div className="full-overlay">
                <div className="filter-panel">
                  <span
                    className="icon-close"
                    onClick={close}
                    onKeyPress={close}
                    role="button"
                  />
                  <div className="menu-bar">
                    <span className="menu-item">
                      {this.props.entityTypeCheckboxes}
                    </span>
                    <span className="menu-item">
                      {this.props.gradeLevelCheckboxes}
                    </span>
                  </div>
                  <div className="controls">
                    <button onClick={close}>Done</button>
                  </div>
                </div>
              </div>
            ) : null}
          </React.Fragment>
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
        <div className="result-summary">Some 333 results in Alameda, CA</div>
        <div className="list-map-ad">
          {this.renderMapAndAdContainer(
            <div className="map-container">
              <div className="map-fit">{this.props.map}</div>
            </div>,
            this.props.tallAd
          )}
          {this.shouldRenderList() && this.props.schoolList}
        </div>
      </div>
    );
  }
}

export default SearchLayout;
