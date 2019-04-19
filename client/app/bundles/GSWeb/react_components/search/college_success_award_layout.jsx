import React from 'react';
import PropTypes from 'prop-types';
import { Provider, connect } from 'react-redux';
import { throttle, debounce } from 'lodash';
import { titleizedName } from 'util/states';
import { XS, SM, validSizes } from 'util/viewport';
import OpenableCloseable from 'react_components/openable_closeable';
import Button from 'react_components/button';
import { translateWithDictionary, capitalize } from 'util/i18n';
import { LIST_VIEW, MAP_VIEW, TABLE_VIEW } from './search_context';
import CaptureOutsideClick from './capture_outside_click';
import HelpTooltip from '../help_tooltip';
import { isNotSignedIn } from '../../util/session';
import modalManager from '../../components/modals/manager';
import SharingModal from '../school_profiles/sharing_modal';
import logo from 'school_profiles/csa_generic_badge_lg_icon.png';

const t = translateWithDictionary({
  en: {
    'Your saved schools in': 'Your saved schools in',
    'Sort by': 'Sort by',
    'Sign up link': 'Sign up',
    'Sign up rest':
      'for a free GreatSchools account and access your saved schools from anywhere.',
    'Verify email':
      'Thank you! One more step - please click on the verification link we’ve emailed you to access your saved schools from anywhere.',
    'Print': 'Print',
    'Select': 'Select'
  },
  es: {
    'Your saved schools in': 'Tus escuelas guardadas en',
    'Sort by': 'Ordenar por',
    'Sign up link': 'Regístrate',
    'Sign up rest':
      'para obtener una cuenta gratuita de GreatSchools y acceda a tus escuelas guardadas desde cualquier lugar.',
    'Verify email':
      'Thank you! One more step - please click on the verification link we’ve emailed you to access your saved schools from anywhere.',
    'Print': 'Imprime',
    'Select': 'Seleccione'
  }
});

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

class CollegeSuccessAwardLayout extends React.Component {
  static defaultProps = {
    breadcrumbs: null,
    distanceFilter: null,
    pagination: null,
    noResults: null,
    stateName: null
  };

  static propTypes = {
    size: PropTypes.oneOf(validSizes).isRequired,
    view: PropTypes.string.isRequired,
    gradeLevelButtons: PropTypes.element.isRequired,
    entityTypeDropdown: PropTypes.element.isRequired,
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
    resultSummary: PropTypes.string.isRequired,
    noResults: PropTypes.element,
    chooseTableButtons: PropTypes.element,
    numOfSchools: PropTypes.number,
    stateName: PropTypes.string
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
      hasShownMap: this.shouldRenderMap(),
      needsToVerifyEmail: false
    };

    this.onSignup = this.onSignup.bind(this);
  }

  componentDidMount() {
    keepInViewport(this.fixedYLayer, {
      $elementsAbove: [$('.header_un'), $('.search-body .menu-bar')],
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
      this.props.size == XS ||
      (this.props.size > SM && this.props.view !== TABLE_VIEW)
    );
  }

  shouldRenderTable() {
    return this.props.size > XS && this.props.view === TABLE_VIEW;
  }

  onSignup() {
    modalManager
      .showModal('JoinModal')
      .done(
        ({ is_new_user } = {}) =>
          is_new_user
            ? this.setState({ needsToVerifyEmail: is_new_user })
            : window.location.reload()
      )
      .fail(() => {});
  }

  renderEmailVerificationMessage() {
    return (
      <div className="email-verification-message">{t('Verify email')}</div>
    );
  }

  renderSelectSchoolDropdown() {
    return (
      <div className="menu-item">
        <span className="label saved-schools">
          {t('Your saved schools in')}:
        </span>
      </div>
    );
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
          <div className="print-only-page-break" />
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
          <span className="menu-item list-map-toggle">
            <div>
              {this.props.listMapTableSelect}
              <span className="ollie-help-icon">
                <HelpTooltip />
              </span>
            </div>
          </span>
        </div>
      </div>
    );
  }

  renderMobileMenuBar() {
    return (
      <OpenableCloseable>
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
                    className={`js-filter-button${isOpen ? ' active' : ''}`}
                  />
                </span>
              </span>
              <span className="ollie-help-icon">
                <HelpTooltip />
              </span>
            </div>
            {isOpen ? (
              <div className="filter-panel">
                <span
                  className="icon-close"
                  onClick={close}
                  onKeyPress={close}
                  role="button"
                  aria-label={t('Close filters')}
                />
                <div>
                  <span className="menu-item">
                    <span className="label">{t('Sort by')}:</span>
                    {this.props.sortSelect}
                  </span>
                </div>
              </div>
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
          {this.shouldRenderList() && this.shouldRenderMap() && this.renderCSAYearDropDown()}
          {this.shouldRenderTable() ? (
            <React.Fragment>
              {!this.shouldRenderList() && (
                <div className="csa-title">
                  <div className="owl-image">
                    <img
                      src={logo}
                      alt="College Success Awards logo"
                  /></div>
                  <div className="owl-content">{this.props.csaSummary}</div>
                </div>
              )}
              <div className="menu-item">{this.props.chooseTableButtons}</div>
              <div className="menu-item" style={{ marginTop: '24px' }}>
                <SharingModal
                  url={window.location.href}
                  pageName="College Success Awards"
                  title={`${titleizedName(
                    this.props.stateName
                  )} College Success Awards`}
                />
              </div>
              <div className="menu-item" style={{ marginTop: '24px' }}>
                {this.renderPrintPageLink()}
              </div>
            </React.Fragment>
          ) : null}
          {this.renderSortDropDown()}
        </div>
      )
    );
  }

  renderPrintPageLink(){
    return (
      <a href={"/catalog/csa/2019_" + this.toTitleCase(this.props.stateName) + "_Winners.pdf"}><span className='icon-fax' /><span>{t("Print")}</span></a>
    )
  }
  toTitleCase = (phrase) => {
    return phrase
        .toLowerCase()
        .split(' ')
        .map(word => word.charAt(0).toUpperCase() + word.slice(1))
        .join('_');
  };

  renderSortDropDown() {
    if (this.props.size <= SM) {
      return null;
    } else if (this.shouldRenderTable()) {
      return (
        <React.Fragment>
          <div className="menu-item sort-dropdown-table-view">
            <span className="label">{t('Sort by')}:</span>
            {this.props.sortSelect}
          </div>
        </React.Fragment>
      );
    }
    return (
      <div className="menu-item">
        <span className="label">{t('Sort by')}:</span>
        {this.props.sortSelect}
      </div>
    );
  }

  renderCSAYearDropDown(){
    return (
      <React.Fragment>
        <div className="menu-item">
          <span className="label">{t('Select')}:</span>
          {this.props.csaYearSelect}
        </div>
      </React.Fragment>
    )
  }

  render() {
    return (
      <div className="search-body" id="my-school-list-page">
        {this.props.numOfSchools > 0 &&
          (this.props.size > SM
            ? this.renderDesktopFilterBar()
            : this.renderMobileMenuBar())}
        {}
        {false && this.props.noResults ? (
          <React.Fragment>
            {this.props.numOfSchools > 0 && this.renderBreadcrumbsSummarySort()}
            {this.props.noResults}
          </React.Fragment>
        ) : (
          <React.Fragment>
            {this.renderBreadcrumbsSummarySort()}
            <div className="list-map-ad clearfix">
              <div
                className={`list-column ${
                  this.shouldRenderList() ? ' ' : 'closed'
                }`}
              >
                {this.shouldRenderList() ? (
                    <div className="csa-title clearfix">
                    <div className='owl-image'><img
                      src={logo}
                      alt="College Success Awards logo"
                    /></div>
                    <div className='owl-content'>{this.props.csaSummary}</div>
                  </div>
                ) : null}
                {this.props.schoolList}
              </div>
              {this.renderMapAndAdContainer(
                <div className="map-fit">{this.props.map}</div>,
                this.props.tallAd
              )}
              {this.shouldRenderTable() ? this.renderTableView() : null}
              {this.props.pagination}
            </div>
          </React.Fragment>
        )}
      </div>
    );
  }
}

const ConnectedCollegeSuccessAwardLayout = connect(state => ({
  stateName: state.common.stateName
}))(CollegeSuccessAwardLayout);

export default props => (
  <Provider store={window.store}>
    <ConnectedCollegeSuccessAwardLayout {...props} />
  </Provider>
);
