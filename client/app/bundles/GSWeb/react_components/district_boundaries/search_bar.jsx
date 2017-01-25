import React, { PropTypes } from 'react';
import { geocode } from '../../components/geocoding';
import Multibutton from '../multibutton';

export default class SearchBar extends React.Component {

  static defaultProps = {
  }

  static propTypes = {
    searchTerm: React.PropTypes.string,
    districts: React.PropTypes.array,
    level: React.PropTypes.string,
    additionalSchoolType: React.PropTypes.string
  }

  constructor(props) {
    super(props);
    this.submitOnEnterKey = this.submitOnEnterKey.bind(this);
    this.onSearchTermChange = this.onSearchTermChange.bind(this);
    this.search = this.search.bind(this);
    this.state = {
      searchTerm: this.props.searchTerm
    }
  }

  submitOnEnterKey(e) {
    if(e.key == 'Enter') {
      this.search();
    }
  }

  onSearchTermChange(e) {
    this.setState({
      searchTerm: e.target.value
    });
  }

  search() {
    this.props.geocode(this.state.searchTerm);
  }

  render() {
    return (
      <div className="filter-bar">
        <div className="search-input">
          <label>Search</label>
          <input name="search-term" type="text" value={this.props.searchTerm} onChange={this.onSearchTermChange} onKeyPress={this.submitOnEnterKey}/>
          <button name="submit-search" onClick={this.search}>Search</button>
        </div>
        <div className="filters">
          <div className="district-select">
            <label>Districts near ...</label>
            <select>
            </select>
          </div>
          <div className="grade-filter">
            <label>School Grade</label>
            <Multibutton
              options={{E: 'Elementary', M: 'Middle', H: 'High'}}
              onSelect={this.props.setLevel} />
          </div>
          <div>
            <label className="type-filter">Additional school type</label>
            <div>
              <input type="checkbox"/>Charter
              <input type="checkbox"/>Private
            </div>
          </div>
        </div>
      </div>
    );
  }

}
