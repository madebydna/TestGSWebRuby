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

const keyMap = {'ArrowUp': -1, 'ArrowDown': 1};

export default class SearchBox extends React.Component {
  static propTypes = {
    autoSuggestResults: PropTypes.object.isRequired,
    searchFunction: PropTypes.func.isRequired
  };

  constructor(props) {
    super(props);
    this.handleKeyDown = this.handleKeyDown.bind(this)
    this.resetSelectedListItem = this.resetSelectedListItem.bind(this)
    this.manageSelectedListItem = this.manageSelectedListItem.bind(this)
    this.state = { searchTerm: '', type: 'schools', selectedListItem: -1, navigateToSelectedListItem: false };
  }

  componentDidUpdate(prevProps){
    if(this.props.autoSuggestResults !== prevProps.autoSuggestResults) {
      this.setState({autoSuggestResultsCount: this.autoSuggestResultsCount()})
    }
  }

  shouldRenderResults() {
    return this.state.autoSuggestResultsCount > 0;
  }

  autoSuggestResultsCount(){
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

  resetSelectedListItem(){
    this.setState({selectedListItem: -1})
  }

  selectionOutOfBounds(e){
    return (e.key === 'ArrowUp' && this.state.selectedListItem === -1) || ( e.key === 'ArrowDown' && this.state.selectedListItem >= this.state.autoSuggestResultsCount - 1)
  }

  manageSelectedListItem(e){
    if( this.selectionOutOfBounds(e) ) {
      return;
    }
    this.setState({selectedListItem: this.state.selectedListItem + keyMap[e.key]})
  }

  handleKeyDown(e) {
    if (e.key === 'Enter') {
      if(this.state.selectedListItem > -1){
        this.setState({navigateToSelectedListItem: true})
      } else {
        this.submit();
      }
    } else if (Object.keys(keyMap).includes(e.key)) {
      this.manageSelectedListItem(e)
    }
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
              callback={()=> {this.resetSelectedListItem(); close()}}
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
                      selectedListItem={this.state.selectedListItem}
                      navigateToSelectedListItem={this.state.navigateToSelectedListItem}
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
