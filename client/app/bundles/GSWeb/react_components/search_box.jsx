import React from 'react';
import PropTypes from 'prop-types';
import OpenableCloseable from './openable_closeable';
import CaptureOutsideClick from './search/capture_outside_click';
import MultiItemDropdown from './multi_item_dropdown';

export default class SearchBox extends React.Component {
  static propTypes = {
    autoSuggestResults: PropTypes.object.isRequired,
    searchFunction: PropTypes.func.isRequired
  };

  constructor(props) {
    super(props);
    // this.submitOnEnterKey = this.submitOnEnterKey.bind(this);
    // this.onSearchTermChange = this.onSearchTermChange.bind(this);
    // this.search = this.search.bind(this);
    this.state = { searchTerm: '' };
    this.searchData = this.searchData.bind(this);
  }

  searchData(e) {
    this.setState({ searchTerm: e.target.value }, () => {
      this.props.searchFunction(this.state.searchTerm);
    });
  }

  render() {
    return (
      <OpenableCloseable openByDefault>
        {(isOpen, { toggle, open, close } = {}) => (
          <div>
            <CaptureOutsideClick
              _key="testing multi item dropdown"
              callback={close}
            >
              {/* DIV IS REQUIRED FOR CAPTUREOUTSIDECLICK TO GET A PROPER REF */}
              <div style={{ width: '237px' }}>
                <input
                  onKeyPress={this.searchData}
                  type="text"
                  className="js-nav-school-search-input typeahead-nav full-width pam search_form_field"
                  placeholder="City, zip, address or school"
                  style={{ width: '100%' }}
                />
                {isOpen && (
                  <MultiItemDropdown
                    listGroups={this.props.autoSuggestResults}
                    searchTerm={this.state.searchTerm}
                  />
                )}
              </div>
            </CaptureOutsideClick>
          </div>
        )}
      </OpenableCloseable>
    );
  }
}
