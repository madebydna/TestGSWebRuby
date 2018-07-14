import React from 'react';
import PropTypes from 'prop-types';
import OpenableCloseable from './openable_closeable';
import CaptureOutsideClick from './search/capture_outside_click';
import SearchResultsList from './search_results_list';
import Selectable from 'react_components/selectable';
import Dropdown from 'react_components/search/dropdown';
import { createPortal } from 'react-dom';
import { reduce } from 'lodash';
import { addQueryParamToUrl, copyParam } from 'util/uri';
import { SM, validSizes, viewport } from 'util/viewport';
import { geocode } from 'components/geocoding';

const options = [
  {
    key: 'schools',
    label: <span>Schools</span>
  },
  {
    key: 'parenting',
    label: <span>Parenting</span>
  }
];

const keyMap = {
  ArrowUp: -1,
  ArrowDown: 1
};

const newSearchResultsPageUrl = ({ q, lat, lon }) => {
  let newUrl = addQueryParamToUrl(
    'q',
    q,
    `/search/search.page${window.location.search}`
  );
  if (lat && lon) {
    newUrl = addQueryParamToUrl(
      'distance',
      5,
      addQueryParamToUrl('lon', lon, addQueryParamToUrl('lat', lat, newUrl))
    );
  }
  return copyParam('newsearch', window.location.href, newUrl);
};

const contentSearchResultsPageUrl = ({ q }) =>
  `/gk/?s=${window.encodeURIComponent(q)}`;

export default class SearchBox extends React.Component {
  static propTypes = {
    autoSuggestResults: PropTypes.object.isRequired,
    searchFunction: PropTypes.func.isRequired,
    size: PropTypes.oneOf(validSizes).isRequired
  };

  constructor(props) {
    super(props);
    this.handleKeyDown = this.handleKeyDown.bind(this);
    this.resetSelectedListItem = this.resetSelectedListItem.bind(this);
    this.manageSelectedListItem = this.manageSelectedListItem.bind(this);
    this.state = {
      searchTerm: '',
      type: 'schools',
      selectedListItem: -1,
      navigateToSelectedListItem: false,
      lat: null,
      lon: null
    };
    this.submit = this.submit.bind(this);
    this.geocodeAndSubmit = this.geocodeAndSubmit.bind(this);
  }

  componentDidUpdate(prevProps) {
    if (this.props.autoSuggestResults !== prevProps.autoSuggestResults) {
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
      Object.keys(this.props.autoSuggestResults || {}),
      (sum, k) => sum + (this.props.autoSuggestResults[k] || []).length,
      0
    );
  }

  placeholderText() {
    if (this.state.type === 'schools') {
      return 'City, zip, address or school';
    } else if (this.state.type === 'parenting') {
      return 'Articles, worksheets and more';
    }
  }

  onSelectItem(close) {
    return itemValue => {
      close();
      this.setState({ searchTerm: itemValue }, this.submit);
    };
  }

  geocodeAndSubmit() {
    if (this.state.type === 'parenting') {
      window.location.href = contentSearchResultsPageUrl({
        q: this.state.searchTerm
      });
    } else if (this.state.type === 'schools') {
      geocode(this.state.searchTerm)
        .then(json => json[0])
        .done(({ lat, lon } = {}) => {
          if (lat && lon) {
            this.setState({ lat, lon }, () => {
              window.location.href = newSearchResultsPageUrl({
                q: this.state.searchTerm,
                lat: this.state.lat,
                lon: this.state.lon
              });
            });
          }
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
          this.props.searchFunction(this.state.searchTerm);
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

  handleKeyDown(e) {
    if (e.key === 'Enter') {
      if (this.state.selectedListItem > -1) {
        this.setState({ navigateToSelectedListItem: true });
      } else {
        this.geocodeAndSubmit();
      }
    } else if (Object.keys(keyMap).includes(e.key)) {
      this.manageSelectedListItem(e);
    }
  }

  renderDesktop() {
    return createPortal(
      <OpenableCloseable>
        {(isOpen, { open, close } = {}) => (
          <div className="search-box">
            <Dropdown
              mouseOver
              options={options}
              onSelect={opt => {
                this.setState({ type: opt.key });
              }}
              activeOption={options.find(opt => opt.key === this.state.type)}
            />
            <CaptureOutsideClick
              callback={() => {
                this.resetSelectedListItem();
                close();
              }}
            >
              {/* DIV IS REQUIRED FOR CAPTUREOUTSIDECLICK TO GET A PROPER REF */}
              <div style={{ flexGrow: 2 }}>
                <input
                  onKeyDown={this.handleKeyDown}
                  onChange={this.onTextChanged({ open, close })}
                  type="text"
                  className="full-width pam search_form_field"
                  placeholder={this.placeholderText()}
                  value={this.state.searchTerm}
                  maxLength={60}
                />
                {isOpen &&
                  this.shouldRenderResults() && (
                    <div className="search-results-list">
                      <SearchResultsList
                        listGroups={this.props.autoSuggestResults}
                        searchTerm={this.state.searchTerm}
                        onSelect={this.onSelectItem(close)}
                        listItemsSelectable={this.state.listItemsSelectable}
                      />
                    </div>
                  )}
              </div>
            </CaptureOutsideClick>
            <div className="search_bar_button" onClick={this.geocodeAndSubmit}>
              <button type="submit" className="search_form_button">
                <span className="search_icon_image_white" />
              </button>
            </div>
          </div>
        )}
      </OpenableCloseable>,
      window.document.querySelector('.dt-desktop')
    );
  }

  renderMobile() {
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
              <input
                onKeyUp={e => {
                  if (e.key === 'Enter') {
                    this.geocodeAndSubmit();
                  } else if (e.key === 'ArrowDown') {
                    this.makeListItemsSelectable();
                  }
                }}
                onChange={this.onTextChanged({ open, close })}
                type="text"
                className="full-width pam search_form_field"
                placeholder={this.placeholderText()}
                value={this.state.searchTerm}
              />
              {isOpen &&
                this.shouldRenderResults() && (
                  <div
                    className="search-results-list"
                    style={{ maxHeight: viewport().height - 160 }}
                  >
                    <SearchResultsList
                      listGroups={this.props.autoSuggestResults}
                      searchTerm={this.state.searchTerm}
                      onSelect={this.onSelectItem(close)}
                      selectedListItem={this.state.selectedListItem}
                      navigateToSelectedListItem={
                        this.state.navigateToSelectedListItem
                      }
                    />
                  </div>
                )}
            </div>
            <div className="search_bar_button" onClick={this.submit}>
              <button type="submit" className="search_form_button">
                <span className="search_icon_image_white" />
              </button>
            </div>
          </div>
        )}
      </OpenableCloseable>,
      window.document.querySelector('.dt-desktop')
    );
  }

  render() {
    if (this.props.size <= SM) {
      return this.renderMobile();
    }
    return this.renderDesktop();
  }
}
