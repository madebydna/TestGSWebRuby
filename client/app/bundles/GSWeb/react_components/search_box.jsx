import React from 'react';
import PropTypes from 'prop-types';
import OpenableCloseable from './openable_closeable';
import CaptureOutsideClick from './search/capture_outside_click';
import MultiItemDropdown from './multi_item_dropdown';
import Dropdown from 'react_components/search/dropdown';
import { createPortal } from 'react-dom';
import { reduce } from 'lodash';

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
    // this.submitOnEnterKey = this.submitOnEnterKey.bind(this);
    // this.onSearchTermChange = this.onSearchTermChange.bind(this);
    // this.search = this.search.bind(this);
    this.state = { searchTerm: '', type: 'schools' };
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

  render() {
    return createPortal(
      <div>
        <OpenableCloseable>
          {(isOpen, { open, close } = {}) => (
            <div style={{ display: 'flex' }} className="search-box">
              <Dropdown
                mouseOver
                options={options}
                onSelect={opt => {
                  this.setState({ type: opt.key });
                }}
                activeOption={options.find(opt => opt.key === this.state.type)}
              />
              <div>
                <CaptureOutsideClick
                  _key="testing multi item dropdown"
                  callback={close}
                >
                  {/* DIV IS REQUIRED FOR CAPTUREOUTSIDECLICK TO GET A PROPER REF */}
                  <div style={{ width: '237px' }}>
                    <input
                      onKeyUp={e => {
                        if (e.key === 'Enter') {
                          if (this.state.type === 'parenting') {
                            window.location.href = `/gk/?s=${window.encodeURIComponent(
                              this.state.searchTerm
                            )}`;
                          }
                        } else {
                          open();
                          this.setState({ searchTerm: e.target.value }, () => {
                            this.props.searchFunction(this.state.searchTerm);
                            if (this.state.searchTerm === '') {
                              close();
                            }
                          });
                        }
                      }}
                      type="text"
                      className="full-width pam search_form_field"
                      placeholder="City, zip, address or school"
                    />
                    {isOpen &&
                      this.shouldRenderResults() && (
                        <MultiItemDropdown
                          listGroups={this.props.autoSuggestResults}
                          searchTerm={this.state.searchTerm}
                        />
                      )}
                  </div>
                </CaptureOutsideClick>
              </div>
              <div className="search_bar_button">
                <button type="submit" className="search_form_button">
                  <span className="search_icon_image_white" />
                </button>
              </div>
            </div>
          )}
        </OpenableCloseable>
      </div>,
      window.document.querySelector('.search_bar')
    );
  }
}
