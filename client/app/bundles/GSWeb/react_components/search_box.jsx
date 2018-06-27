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
  }

  shouldRenderResults(){
    return (this.props.autoSuggestResults && Object.keys(this.props.autoSuggestResults).length > 0 && this.props.autoSuggestResults.city.length > 0)
  }

  render() {
    return (
      <OpenableCloseable>
        {(isOpen, { open, close } = {}) => (
          <div>
            <CaptureOutsideClick
              _key="testing multi item dropdown"
              callback={close}
            >
              {/* DIV IS REQUIRED FOR CAPTUREOUTSIDECLICK TO GET A PROPER REF */}
              <div style={{ width: '237px' }}>
                <input
                  onKeyUp={(e) => {
                    open()
                    this.setState({ searchTerm: e.target.value }, () => {
                      this.props.searchFunction(this.state.searchTerm)
                      if(this.state.searchTerm === '') {
                        close()
                      }
                    });
                  }}
                  type="text"
                  className="full-width pam search_form_field"
                  placeholder="City, zip, address or school"
                />
                {isOpen && this.shouldRenderResults() && (
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
