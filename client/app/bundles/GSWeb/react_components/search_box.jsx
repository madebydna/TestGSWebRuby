import React from 'react';
import PropTypes from 'prop-types';
import OpenableCloseable from './openable_closeable';
import CaptureOutsideClick from './search/capture_outside_click';
import SearchResultsList from './search_results_list';
import Dropdown from 'react_components/search/dropdown';
import { createPortal } from 'react-dom';
import { reduce } from 'lodash';
import { addQueryParamToUrl, copyParam } from 'util/uri';

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

export default class SearchBox extends React.Component {
  static propTypes = {
    autoSuggestResults: PropTypes.object.isRequired,
    searchFunction: PropTypes.func.isRequired
  };

  constructor(props) {
    super(props);
    this.state = { searchTerm: '', type: 'schools', listItemsSelectable: false };
  }

  componentDidMount() {
    // window.document.querySelector('.search_bar').innerHTML = '';
  }

  shouldRenderResults() {
    const totalResults = reduce(
      Object.keys(this.props.autoSuggestResults || {}),
      (sum, k) => sum + (this.props.autoSuggestResults[k] || []).length,
      0
    );
    return totalResults > 0;
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
      this.setState({ searchTerm: itemValue }, () => {
        this.submit();
      });
    };
  }

  submit() {
    if (this.state.type === 'parenting') {
      window.location.href = `/gk/?s=${window.encodeURIComponent(
        this.state.searchTerm
      )}`;
    } else if (this.state.type === 'schools') {
      let newUrl = addQueryParamToUrl(
        'q',
        this.state.searchTerm,
        `/search/search.page${window.location.search}`
      );
      newUrl = copyParam('newsearch', window.location.href, newUrl);
      window.location.href = newUrl;
    }
  }

  onTextChanged({ open, close }) {
    return e => {
      open();
      this.setState({ searchTerm: e.target.value }, () => {
        this.props.searchFunction(this.state.searchTerm);
        if (this.state.searchTerm === '') {
          close();
        }
      });
    };
  }

  resetListItemsSelectable(){
    this.state.listItemsSelectable && this.setState({listItemsSelectable: false})
  }

  makeListItemsSelectable(){
    this.setState({listItemsSelectable: true})
  }

  render() {
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
              _key="testing multi item dropdown"
              callback={()=> {this.resetListItemsSelectable(); close()}}
            >
              {/* DIV IS REQUIRED FOR CAPTUREOUTSIDECLICK TO GET A PROPER REF */}
              <div style={{ flexGrow: 2 }}>
                <input
                  onKeyUp={e => {
                    if (e.key === 'Enter') {
                      this.submit();
                    } else if (e.key === 'ArrowDown') {
                      this.makeListItemsSelectable()
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
            <div className="search_bar_button">
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
}