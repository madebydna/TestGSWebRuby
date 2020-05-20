import React from 'react';
import PropTypes from 'prop-types';
import Selectable from 'react_components/selectable';
import Dropdown from 'react_components/search/dropdown';
import { createPortal } from 'react-dom';
import { reduce, debounce, cloneDeep } from 'lodash';
import { SM, XS, validSizes, viewport } from 'util/viewport';
import { geocode } from 'components/geocoding';
import suggest from 'api_clients/autosuggest';
import { parse, stringify } from 'query-string';
import { getAddressPredictions } from 'api_clients/google_places';
import { init as initGoogleMaps } from 'components/map/google_maps';
import { href } from 'util/search';
import { analyticsEvent } from 'util/page_analytics';
import { translateWithDictionary } from 'util/i18n';
import { legacyUrlEncode } from 'util/uri';
import OpenableCloseable from './openable_closeable';
import CaptureOutsideClick from './search/capture_outside_click';
import SearchResultsList from './search_results_list';
import { name as stateName } from 'util/states';
import cancelCircle from 'icons/cancel-circle.svg';

// Matches only 5 digits
// Todo currently 3-4 schools would match this regex,
// but it may not be worth maintain a list of those schools to prevent matches
const matchesFiveDigits = string => /(\D|^)\d{5}(\D*$|$)/.test(string);

//Matches three digits minimum
const matchesThreeDigits = string => /(\D|^)\d{3}(\D*$|$)/.test(string);

// Matches 5 digits + dash or space or no space + 4 digits.
const matchesFiveDigitsPlusFourDigits = string =>
  /(\D|^)\d{5}(-|\s*)\d{4}(\D|$)/.test(string);

const matchesZip = string =>
  matchesFiveDigits(string) || matchesFiveDigitsPlusFourDigits(string) || matchesThreeDigits(string);

const matchesNumbersAsOnlyFirstCharacters = string => /^\W*\d+\s/.test(string);

const matchesStateAbbreviationQuery = string => /\w*,\s*\w\w\b/.test(string);

// Matches when first character/characters are numbers + a space + if it does not match schools in the school and district list.
// ToDo perhaps not worth maintaining list of 300 schools for this regex.
// ToDo if we do decide to maintain the list, perhaps move this into a service that autogenerates the list
const matchesAddress = string =>
  matchesNumbersAsOnlyFirstCharacters(string) ||
  matchesStateAbbreviationQuery(string);

const matchesAddressOrZip = string =>
  matchesAddress(string) || matchesZip(string);

export const t = translateWithDictionary({
  // entries not needed if text matches key
  en: {},
  es: {
    Schools: 'Escuelas',
    Parenting: 'Crianza',
    'City, zip, address or school':
      'Ciudad, código postal, dirección o escuela',
    'Articles, worksheets and more': 'Artículos, hoja de ejercicios y más'
  }
});
const options = [
  {
    key: 'schools',
    label: <span>{t('Schools')}</span>
  },
  {
    key: 'parenting',
    label: <span>{t('Parenting')}</span>
  }
];

export const keyMap = {
  ArrowUp: -1,
  ArrowDown: 1
};

const newSearchResultsPageUrl = newParams => {
  const { newsearch, lang } = parse(window.location.search);
  const params = {
    newsearch,
    lang,
    ...newParams
  };
  return `/search/search.page?${stringify(params)}`;
};

// city should be a not-yet-encoded string
const newCityBrowsePageUrl = (stateAbbreviation, city, newParams) => {
  const { newsearch, lang } = parse(window.location.search);
  const params = {
    newsearch,
    lang,
    ...newParams
  };
  const stateUriPart = legacyUrlEncode(stateName(stateAbbreviation));
  const cityUriPart = legacyUrlEncode(city);
  const queryString = stringify(params);
  if (queryString) {
    return `/${stateUriPart}/${cityUriPart}/schools/?${stringify(params)}`;
  }
  return `/${stateUriPart}/${cityUriPart}/schools/`;
};

const contentSearchResultsPageUrl = ({ q }) => {
  const { lang } = parse(window.location.search);
  const params = {
    s: q,
    lang
  };
  return `/gk/?${stringify(params)}`;
};

export default class SearchBox extends React.Component {
  static propTypes = {
    size: PropTypes.oneOf(validSizes),
    defaultType: PropTypes.string,
    resultTypes: PropTypes.arrayOf(PropTypes.string),
    pageType: PropTypes.string,
    listType: PropTypes.func,
    showSearchAllOption: PropTypes.bool,
    showSearchButton: PropTypes.bool
  };
  static defaultProps = {
    size: 2,
    defaultType: 'schools',
    resultTypes: [],
    pageType: 'Default',
    listType: SearchResultsList,
    showSearchAllOption: true,
    showSearchButton: true
  };

  constructor(props) {
    super(props);
    this.handleKeyDown = this.handleKeyDown.bind(this);
    this.resetSelectedListItem = this.resetSelectedListItem.bind(this);
    this.resetSearchTerm = this.resetSearchTerm.bind(this);
    this.manageSelectedListItem = this.manageSelectedListItem.bind(this);
    this.state = this.defaultState(props);
    this.submit = this.submit.bind(this);
    this.geocodeAndSubmit = this.geocodeAndSubmit.bind(this);
    this.autoSuggestQuery = debounce(this.autoSuggestQuery.bind(this), 200);
  }

  defaultState(props) {
    return {
      searchTerm: '',
      type: props.defaultType,
      selectedListItem: -1,
      navigateToSelectedListItem: false,
      autoSuggestResults: {
        Addresses: [],
        Zipcodes: [],
        Cities: [],
        Districts: [],
        Schools: []
      },
      displayMobileSearchModal: false,
      googleMapsInitialized: false
    };
  }

  componentDidUpdate(prevProps, prevState) {
    if (this.state.autoSuggestResults !== prevState.autoSuggestResults) {
      this.setState({
        autoSuggestResultsCount: this.autoSuggestResultsCount()
      });
    }
    if (
      this.state.displayMobileSearchModal === true &&
      prevState.displayMobileSearchModal !== this.state.displayMobileSearchModal
    ) {
      setTimeout(() => {
        window.scrollTo({ top: 0, left: 0, behavior: 'smooth' });
      }, 100);
    }
  }

  shouldRenderResults() {
    return this.state.autoSuggestResultsCount > 0;
  }

  autoSuggestResultsCount() {
    return reduce(
      Object.keys(this.state.autoSuggestResults || {}),
      (sum, k) => sum + (this.state.autoSuggestResults[k] || []).length,
      0
    );
  }

  placeholderText() {
    if (this.state.type === 'schools') {
      return t('City, zip, address or school');
    } else if (this.state.type === 'parenting') {
      return t('Articles, worksheets and more');
    }
  }

  selectAndSubmit(close) {
    return item => {
      analyticsEvent('autosuggest', `select ${item.category}`, item.title);
      close();
      if (item.type === 'address') {
        this.setState({ searchTerm: item.value }, this.geocodeAndSubmit);
      } else {
        this.setState({ searchTerm: item.value }, this.submit);
      }
    };
  }

  geocodeAndSubmit() {
    const { searchTerm, type } = this.state;
    if (type === 'parenting') {
      window.location.href = contentSearchResultsPageUrl({
        q: searchTerm
      });
    } else if (type === 'schools') {
      if (!matchesAddressOrZip(searchTerm)) {
        this.submit();
        return;
      }
      if (this.state.googleMapsInitialized) {
        this.doGeocode();
      }
    }
  }

  doGeocode() {
    const { searchTerm } = this.state;
    geocode(searchTerm)
        .then(json => json[0])
        .done(
          ({
            lat,
            lon,
            city,
            state,
            zip,
            normalizedAddress,
            level,
            neighborhood,
            sublocality
          } = {}) => {
            let params = {};
            if (city && state && level === 'city') {
              window.location.href = newCityBrowsePageUrl(state, city, params);
              return;
            }

            if (lat && lon) {
              params = { lat, lon };
            } else {
              params.q = searchTerm;
            }
            if (matchesZip(searchTerm) && !matchesAddress(searchTerm)) {
              params.locationLabel = `${city ||
                sublocality ||
                neighborhood}, ${state} ${zip}`;
              params.locationType = 'zip';
              params.state = state;
              params.st = ['public_charter', 'public', 'charter'];
            } else {
              params.locationLabel = normalizedAddress;
              params.locationType = 'street_address';
              params.state = state;
              params.st = ['public_charter', 'public', 'charter'];
            }
            window.location.href = newSearchResultsPageUrl(params);
          }
        )
        .fail(() => {
          window.location.href = newSearchResultsPageUrl({
            q: this.state.searchTerm
          });
        });
  }

  submit() {
    if (this.state.type === 'parenting') {
      window.location.href = contentSearchResultsPageUrl({
        q: this.state.searchTerm
      });
    } else if (this.state.type === 'schools') {
      window.location.href = newSearchResultsPageUrl({
        q: this.state.searchTerm
      });
    }
  }

  onTextChanged({ open, close }) {
    return e => {
      this.setState({ searchTerm: e.target.value }, () => {
        if (this.state.type === 'schools') {
          this.autoSuggestQuery(this.state.searchTerm);
          if (this.state.searchTerm === '') {
            close();
          } else {
            open();
          }
        } else {
          close();
        }
      });
    };
  }

  // we need to init Google Maps for later Geocoding
  onQueryMatchesAddressOrZip(q) {
    initGoogleMaps(() => {
      if (matchesAddress(q)) {
        getAddressPredictions(q, addresses => {
          const newResults = cloneDeep(this.state.autoSuggestResults);
          newResults.Addresses = addresses.map(address => ({
            type: 'address',
            title: address,
            value: address
          }));
          this.setState({ googleMapsInitialized: true, autoSuggestResults: newResults });
        });
      } else {
        this.setState({ googleMapsInitialized: true });
      }
    });
  }

  autoSuggestQuery(q) {
    q = q.replace(/[^a-zA-Z 0-9\-\,\']+/g, '');
    if (q.length >= 3) {
      if (matchesAddressOrZip(q)) {
        this.onQueryMatchesAddressOrZip(q);
      }

      let qPortionBeforeComma = q;
      if (matchesStateAbbreviationQuery(q)) {
        qPortionBeforeComma = q.substr(0, q.indexOf(','));
      }
      suggest(qPortionBeforeComma, { types: this.props.resultTypes }).done(
        results => {
          this.sortResultsByCategory(results)
        }
      );
    } else {
      this.setState({ autoSuggestResults: {} });
    }
  }

  sortResultsByCategory(results){
    const adaptedResults = {
      Addresses: [],
      Zipcodes: [],
      Cities: [],
      Districts: [],
      Schools: []
    };
    Object.keys(results).forEach(category => {
      (results[category] || []).forEach(result => {
        adaptedResults[category].push(result);
      });
    });
    adaptedResults.Addresses = this.state.autoSuggestResults.Addresses;
    this.setState({ autoSuggestResults: adaptedResults });
  }

  resetSelectedListItem() {
    this.setState({ selectedListItem: -1 });
  }

  resetSearchTerm() {
    const newResults = cloneDeep(this.state.autoSuggestResults);
    newResults.Addresses = []
    this.setState({
      searchTerm: '',
      autoSuggestResults: newResults
    });
  }

  selectionOutOfBounds(e) {
    return (
      (e.key === 'ArrowUp' && this.state.selectedListItem === -1) ||
      (e.key === 'ArrowDown' &&
        this.state.selectedListItem >= this.state.autoSuggestResultsCount - 1)
    );
  }

  manageSelectedListItem(e) {
    if (this.selectionOutOfBounds(e)) {
      return;
    }
    this.setState({
      selectedListItem: this.state.selectedListItem + keyMap[e.key]
    });
  }

  handleKeyDown(e, { close }) {
    if (e.key === 'Enter') {
      if (this.state.selectedListItem > -1) {
        close();
        const flattenedResultValues = Array.prototype.concat.apply(
          [],
          Object.values(this.state.autoSuggestResults).filter(array => !!array)
        );
        const selectedListItem =
          flattenedResultValues[this.state.selectedListItem];
        if (selectedListItem.url) {
          window.location.href = href(selectedListItem.url);
        } else {
          this.selectAndSubmit(() => {})(selectedListItem);
        }
      } else {
        this.geocodeAndSubmit();
      }
    } else if (Object.keys(keyMap).includes(e.key)) {
      this.manageSelectedListItem(e);
    }
  }

  inputBox = ({ open, close }) => {
    const onFocusValue =
      this.props.pageType === 'Home' && this.props.size <= XS
        ? this.toggleSearchBoxModal
        : null;
    return (
      <form
        action="#"
        onSubmit={e => {
          e.preventDefault();
          return false;
        }}
      >
        {/* Form and action makes iOS button say 'Go' */}
        <input
          onKeyDown={e => this.handleKeyDown(e, { close })}
          onChange={this.onTextChanged({ open, close })}
          type="text"
          className="full-width pam search_form_field"
          placeholder={this.placeholderText()}
          value={this.state.searchTerm}
          maxLength={60}
          onFocus={onFocusValue}
        />
      </form>
    );
  };

  toggleSearchBoxModal = (e, shouldBeClose = false) => {
    if (!this.state.displayMobileSearchModal && !shouldBeClose) {
      this.setState({
        displayMobileSearchModal: true
      });
    } else if (this.state.displayMobileSearchModal && shouldBeClose) {
      this.setState({
        displayMobileSearchModal: false
      });
    }
  };

  searchButton = () => (
    <React.Fragment>
      <div className="search_bar_button" onClick={this.geocodeAndSubmit}>
        <button type="submit" className="search_form_button">
          <span className="search_icon_image_white" />
        </button>
      </div>
      {this.state.displayMobileSearchModal &&
        this.props.size <= XS && (
          <div
            className="search_bar_button"
            onClick={e => this.toggleSearchBoxModal(e, true)}
          >
            <button className="search_form_button">
              <span style={{ fontSize: 22 }}>X</span>
            </button>
          </div>
        )}
    </React.Fragment>
  );

  resetSearchTermButton = close => (
    <div
      className="search-term-reset-button"
      onClick={() => {
        analyticsEvent(
          'search',
          'autocomplete-search-reset',
          this.state.searchTerm
        );
        close();
        this.resetSearchTerm();
      }}
    >
      <img src={cancelCircle}/>
    </div>
  );

  renderResetSearchTermButton() {
    return this.state.searchTerm && this.state.searchTerm.length > 0;
  }

  searchResultsList = ({ close }) => {
    const ListType = this.props.listType;
    return (
      <ListType
        listGroups={this.state.autoSuggestResults}
        searchTerm={this.state.searchTerm}
        onSelect={this.selectAndSubmit(close)}
        selectedListItem={this.state.selectedListItem}
        navigateToSelectedListItem={this.state.navigateToSelectedListItem}
        showSearchAllOption={this.props.showSearchAllOption}
      />
    );
  };

  renderMobileSearchBox(element) {
    return createPortal(
      <OpenableCloseable>
        {(isOpen, { open, close } = {}) => (
          <div className="search-box">
            <Selectable
              options={options}
              allowDeselect={false}
              activeOptions={[options.find(opt => opt.key === this.state.type)]}
              onSelect={opt => {
                this.setState({ type: opt.key });
              }}
            >
              {opts =>
                opts.map(({ option, active, select }) => (
                  <div
                    key={option.key}
                    onClick={select}
                    className={`mobile-toggle-button font-size-medium tac tav ${
                      active ? 'active' : ''
                    }`}
                  >
                    {option.label}
                  </div>
                ))
              }
            </Selectable>
            <div className="search-input-box">
              {this.inputBox({ open, close })}
              {this.renderResetSearchTermButton() &&
                this.resetSearchTermButton(close)}
              {isOpen &&
                this.shouldRenderResults() && (
                  <div
                    className="search-results-list"
                    style={{ maxHeight: viewport().height - 160 }}
                  >
                    {this.searchResultsList({ close })}
                  </div>
                )}
            </div>
            {this.props.showSearchButton && this.searchButton()}
          </div>
        )}
      </OpenableCloseable>,
      element
    );
  }

  searchBoxElement(renderDropdown = true) {
    const searchBoxName =
      this.state.displayMobileSearchModal === true
        ? 'search-box search-mode-homepage'
        : 'search-box';
    return (
      <OpenableCloseable>
        {(isOpen, { open, close } = {}) => (
          <div className={searchBoxName}>
            {renderDropdown ? (
              <Dropdown
                mouseOver
                options={options}
                onSelect={opt => {
                  this.setState({ type: opt.key });
                }}
                activeOption={options.find(opt => opt.key === this.state.type)}
              />
            ) : null}
            <CaptureOutsideClick
              callback={() => {
                this.resetSelectedListItem();
                close();
              }}
            >
              {/* DIV IS REQUIRED FOR CAPTUREOUTSIDECLICK TO GET A PROPER REF */}
              <div className="search-input-box">
                {this.inputBox({ open, close })}
                {this.renderResetSearchTermButton() &&
                  this.resetSearchTermButton(close)}
                {isOpen &&
                  this.shouldRenderResults() && (
                    <div className="search-results-list">
                      {this.searchResultsList({ close })}
                    </div>
                  )}
              </div>
            </CaptureOutsideClick>
            {this.props.showSearchButton && this.searchButton()}
          </div>
        )}
      </OpenableCloseable>
    );
  }

  renderSearchBox(element, renderDropdown = true) {
    return createPortal(this.searchBoxElement(renderDropdown), element);
  }

  renderSearchBoxModal(element, renderDropdown = true) {
    if (!this.state.displayMobileSearchModal) {
      return this.renderSearchBox(element, false);
    }
    return (
      <React.Fragment>
        {this.renderSearchBox(element, false)}
        <div className="home-page-overlay" />
      </React.Fragment>
    );
  }

  render() {
    // Uses React Portals to pin the component onto the DOM after it is loaded
    // renderSearchBox and renderMobileSearchBox is used everywhere else on the site
    // as the search box
    // renderSearchBoxModal is used only on the homepage where special handling kicks in from
    // a handheld device
    let element = window.document.querySelector('#home-page .input-group');
    if (element && this.props.pageType === 'Home') {
      if (this.props.size <= XS) {
        return this.renderSearchBoxModal(element, false);
      }
      return this.renderSearchBox(element, false);
    }

    element = window.document.querySelector('.dt-desktop');
    if (this.props.size <= SM) {
      return this.renderMobileSearchBox(element);
    }
    return this.renderSearchBox(element);
  }
}
