import React from 'react';
import PropTypes from 'prop-types';
import { throttle, debounce } from 'lodash';
import $ from 'jquery';

function keepInViewport(
  $elem,
  {
    $elementsAbove = [],
    $elementsBelow = [],
    setTop = true,
    setBottom = true
  } = {}
) {
  const initialTop = $elem.position().top;

  const updateElementPosition = function updateElementPosition() {
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
  static defaultProps = {
    renderHeader: () => {},
    renderSubheader: () => {},
    renderAd: () => {},
    renderList: () => {},
    renderMap: () => {},
    mapHidden: true
  };

  static propTypes = {
    renderHeader: PropTypes.func,
    renderSubheader: PropTypes.func,
    renderAd: PropTypes.func,
    renderList: PropTypes.func,
    renderMap: PropTypes.func,
    mapHidden: PropTypes.bool
  };

  constructor(props) {
    super(props);
    this.fixedYLayer = React.createRef();
    this.header = React.createRef();
  }

  componentDidMount() {
    keepInViewport($(this.fixedYLayer.current), {
      $elementsAbove: [$('.search-header')],
      $elementsBelow: [$('footer')],
      fixTop: true,
      fixBottom: true
    });
    keepInViewport($(this.header.current), {
      setTop: true,
      setBottom: false
    });
  }

  render() {
    return (
      <div className="search-component">
        <div className="search-header" ref={this.header}>
          <div style={{ maxWidth: '1282px', margin: 'auto' }}>
            {this.props.renderHeader()}
          </div>
        </div>
        <div className="search-subheader">{this.props.renderSubheader()}</div>
        <div className="list-map-ad">
          <div className="fixed-y-layer" ref={this.fixedYLayer}>
            <div className="fixed-y-centering">
              <div className="right-column">
                <div className="ad-column">{this.props.renderAd()}</div>
                <div className="map-column">
                  <div
                    className={
                      this.props.mapHidden
                        ? 'map-container closed'
                        : 'map-container'
                    }
                  >
                    <div className="map-fit">{this.props.renderMap()}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          {this.props.renderList()}
        </div>
      </div>
    );
  }
}

export default SearchLayout;
