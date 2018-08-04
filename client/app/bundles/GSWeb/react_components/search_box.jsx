import React from 'react';
import PropTypes from 'prop-types';
import OpenableCloseable from './openable_closeable';
import CaptureOutsideClick from './search/capture_outside_click';
import SearchResultsList from './search_results_list';
import Selectable from 'react_components/selectable';
import Dropdown from 'react_components/search/dropdown';
import { createPortal } from 'react-dom';
import { reduce, debounce, cloneDeep } from 'lodash';
import { SM, validSizes, viewport } from 'util/viewport';
import { geocode } from 'components/geocoding';
import suggest from 'api_clients/autosuggest';
import { parse, stringify } from 'query-string';
import { getAddressPredictions } from 'api_clients/google_places';
import { init as initGoogleMaps } from 'components/map/google_maps';
import { href } from 'util/search';
import { analyticsEvent } from 'util/page_analytics';
import { translateWithDictionary } from 'util/i18n';

// Matches only 5 digits
// Todo currently 3-4 schools would match this regex,
// but it may not be worth maintain a list of those schools to prevent matches
const matchesFiveDigits = string => /(\D|^)\d{5}(\D*$|$)/.test(string);

// Matches 5 digits + dash or space or no space + 4 digits.
const matchesFiveDigitsPlusFourDigits = string =>
  /(\D|^)\d{5}(-|\s*)\d{4}(\D|$)/.test(string);

const matchesZip = string =>
  matchesFiveDigits(string) || matchesFiveDigitsPlusFourDigits(string);

const matchesNumbersAsOnlyFirstCharacters = string => /^\W*\d+\s/.test(string);

const matchesStateAbbreviationQuery = string => /\w*, \w\w\b/.test(string);

// Matches when first character/characters are numbers + a space + if it does not match schools in the school and district list.
// ToDo perhaps not worth maintaining list of 300 schools for this regex.
// ToDo if we do decide to maintain the list, perhaps move this into a service that autogenerates the list
const matchesAddress = string =>
  matchesNumbersAsOnlyFirstCharacters(string) ||
  matchesStateAbbreviationQuery(string);

const matchesAddressOrZip = string =>
  matchesAddress(string) || matchesZip(string);

const t = translateWithDictionary({
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

const keyMap = {
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

const contentSearchResultsPageUrl = ({ q }) =>
  `/gk/?s=${window.encodeURIComponent(q)}`;

export default class SearchBox extends React.Component {
  static propTypes = {
    size: PropTypes.oneOf(validSizes),
    defaultType: PropTypes.string
  };
  static defaultProps = {
    size: 2,
    defaultType: 'schools'
  };

  constructor(props) {
    super(props);
    this.handleKeyDown = this.handleKeyDown.bind(this);
    this.resetSelectedListItem = this.resetSelectedListItem.bind(this);
    this.manageSelectedListItem = this.manageSelectedListItem.bind(this);
    this.state = {
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
      }
    };
    this.submit = this.submit.bind(this);
    this.geocodeAndSubmit = this.geocodeAndSubmit.bind(this);
    this.autoSuggestQuery = debounce(this.autoSuggestQuery.bind(this), 200);
  }

  componentDidUpdate(prevProps, prevState) {
    if (this.state.autoSuggestResults !== prevState.autoSuggestResults) {
      this.setState({
        autoSuggestResultsCount: this.autoSuggestResultsCount()
      });
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
      if (item.type === 'zip' || item.type === 'address') {
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

      geocode(searchTerm)
        .then(json => json[0])
        .done(({ lat, lon, city, state, zip, normalizedAddress } = {}) => {
          let params = {};
          if (lat && lon) {
            params = { lat, lon };
          } else {
            params.q = searchTerm;
          }
          if (matchesZip(searchTerm) && !matchesAddress(searchTerm)) {
            params.locationLabel = `${city}, ${state} ${zip}`;
            params.locationType = 'zip';
            params.state = state;
          } else {
            params.locationLabel = normalizedAddress;
            params.locationType = 'street_address';
            params.state = state;
          }
          window.location.href = newSearchResultsPageUrl(params);
        })
        .fail(() => {
          window.location.href = newSearchResultsPageUrl({
            q: this.state.searchTerm
          });
        });
    }
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

  /*
  { city: [
      {"id": null,
      "city": "New Boston",
      "state": "nh",
      "type": "city",
      "url": '/new-mexico/alamogordo//829-Alamogordo-SDA-School}
    ],
    school: [
      {"id": null,
      "school": "Alameda High School",
      "city": "New Boston",
      "state": "nh",
      "type": "school"}
    ],
    zip....includes an additional 'value' key.
  },
  */
  autoSuggestQuery(q) {
    if (q.length >= 3) {
      if (matchesAddress(q)) {
        initGoogleMaps(() => {
          getAddressPredictions(q, addresses => {
            const newResults = cloneDeep(this.state.autoSuggestResults);
            newResults.Addresses = addresses.map(address => ({
              type: 'address',
              title: address,
              value: address
            }));
            this.setState({ autoSuggestResults: newResults });
          });
        });
      }

      suggest(q).done(results => {
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
      });
    } else {
      this.setState({ autoSuggestResults: {} });
    }
  }

  resetSelectedListItem() {
    this.setState({ selectedListItem: -1 });
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
        const flattenedResultValues = Array.concat.apply(
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

  inputBox = ({ open, close }) => (
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
      />
    </form>
  );

  searchButton = () => (
    <div className="search_bar_button" onClick={this.geocodeAndSubmit}>
      <button type="submit" className="search_form_button">
        <span className="search_icon_image_white" />
      </button>
    </div>
  );

  searchResultsList = ({ close }) => (
    <SearchResultsList
      listGroups={this.state.autoSuggestResults}
      searchTerm={this.state.searchTerm}
      onSelect={this.selectAndSubmit(close)}
      selectedListItem={this.state.selectedListItem}
      navigateToSelectedListItem={this.state.navigateToSelectedListItem}
    />
  );

  renderDesktop(element, renderDropdown = true) {
    return createPortal(
      <OpenableCloseable>
        {(isOpen, { open, close } = {}) => (
          <div className="search-box">
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
              <div style={{ flexGrow: 2 }}>
                {this.inputBox({ open, close })}
                {isOpen &&
                  this.shouldRenderResults() && (
                    <div className="search-results-list">
                      {this.searchResultsList({ close })}
                    </div>
                  )}
              </div>
            </CaptureOutsideClick>
            {this.searchButton()}
          </div>
        )}
      </OpenableCloseable>,
      element
    );
  }

  renderMobile(element) {
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

            <div style={{ flexGrow: 2 }}>
              {this.inputBox({ open, close })}
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
            {this.searchButton()}
          </div>
        )}
      </OpenableCloseable>,
      element
    );
  }

  render() {
    let element = window.document.querySelector('#home-page .input-group');
    if (element) {
      return this.renderDesktop(element, false);
    }

    element = window.document.querySelector('.dt-desktop');
    if (this.props.size <= SM) {
      return this.renderMobile(element);
    }
    return this.renderDesktop(element);
  }
}
