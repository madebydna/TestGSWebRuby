import React from 'react';
import PropTypes from 'prop-types';
import OpenableCloseable from './openable_closeable'
import CaptureOutsideClick from './search/capture_outside_click'
import MultiItemDropdown from './multi_item_dropdown'

export default class SearchBox extends React.Component {
  static propTypes = {
  }

  constructor(props) {
    super(props);
    // this.submitOnEnterKey = this.submitOnEnterKey.bind(this);
    // this.onSearchTermChange = this.onSearchTermChange.bind(this);
    // this.search = this.search.bind(this);
    this.state = {searchTerm: ''}
  }


  sampleSelectData(){
    return (
      {
        'Schools': {
          listItems: [
            {
              title: 'Berkeley Elementary School',
              url: '/california/berkeley/32-Leconte-Elementary-School/',
              additionalInfo: 'Berkeley, CA'
            }
          ]
        },
        'Districts': {
          listItems: [
            {
              title: "Unified Berkeley School District",
              url: '/california/berkeley-unified-school-district',
              additionalInfo: 'Berkeley, CA'
            }
          ]
        }
      }
    )
  }

  searchData(){

  }

  render(){
    return(
      <OpenableCloseable openByDefault={true}>
        {(isOpen, { toggle, open, close } = {}) => (
          <div>
            <CaptureOutsideClick _key={'testing multi item dropdown'} callback={close}>
              {/*DIV IS REQUIRED FOR CAPTUREOUTSIDECLICK TO GET A PROPER REF*/}
              <div style={{width: '237px'}}>
                <input type="text" className="js-nav-school-search-input typeahead-nav full-width pam search_form_field" placeholder="City, zip, address or school" style={{width: '100%'}}/>
                {isOpen && (
                  <MultiItemDropdown listGroups={this.sampleSelectData()} searchTerm="Berkeley"/>
                )}
              </div>
            </CaptureOutsideClick>
          </div>
        )}
      </OpenableCloseable>
    )
  }
}

