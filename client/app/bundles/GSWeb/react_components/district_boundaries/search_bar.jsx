import React, { PropTypes } from 'react';
import { geocode } from '../../components/geocoding';
import ButtonGroup from '../buttongroup';
import Select from '../select';
import * as Geocoding from '../../components/geocoding';
import Checkbox from '../checkbox';

export default class SearchBar extends React.Component {

  static defaultProps = {
  }

  static propTypes = {
    searchTerm: React.PropTypes.string,
    districts: React.PropTypes.array,
    level: React.PropTypes.string,
    additionalSchoolType: React.PropTypes.string,
    onClickMapView: React.PropTypes.func,
    onClickListView: React.PropTypes.func
  }

  constructor(props) {
    super(props);
    this.submitOnEnterKey = this.submitOnEnterKey.bind(this);
    this.onSearchTermChange = this.onSearchTermChange.bind(this);
    this.toggleFilters = this.toggleFilters.bind(this);
    this.onClickListView = this.onClickListView.bind(this);
    this.onClickMapView = this.onClickMapView.bind(this);
    this.handleSchoolType = this.handleSchoolType.bind(this);
    this.search = this.search.bind(this);
    this.state = {
      searchTerm: this.props.searchTerm,
      showFilters: false,
      mapSelected: true,
      listSelected: false
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
    Geocoding.geocode(this.state.searchTerm)
      .then(json => json[0])
      .done(({lat, lon, normalizedAddress = ''} = {}) => {
        if (lat && lon) {
          this.setState({
            searchLocation: normalizedAddress.replace(', USA', '')
          });
          this.props.changeLocation(lat, lon);
        }
      });
  }

  toggleFilters() {
    this.setState({
      showFilters: !this.state.showFilters
    });
  }

  onClickMapView() {
    this.setState({
      mapSelected: true,
      listSelected: false
    });
    this.props.onClickMapView();
  }

  onClickListView() {
    this.setState({
      listSelected: true,
      mapSelected: false
    });
    this.props.onClickListView();
  }

  handleSchoolType(value) {
    this.props.toggleSchoolType(value);
  }

  render() {
    return (
      <div className="filter-bar">
        <div className="search-input">
          <label>Search</label>
          <input name="search-term" type="text" value={this.props.searchTerm} onChange={this.onSearchTermChange} onKeyPress={this.submitOnEnterKey}/>
          <button name="submit-search" onClick={this.search}>Search</button>
        </div>

        <div className="toggle-bar">
          <button className="filter-toggle-button" onClick={this.toggleFilters} >Filters</button>
          <div className="list-map-toggle">
            <a href="javascript:void(0);" className="show-list" onClick={this.onClickListView}>
              <span className={'icon icon-document' + (this.state.listSelected ? ' active' : '')}/>
              List View
            </a>
            <a href="javascript:void(0);" className="show-map" onClick={this.onClickMapView}>
              <span className={'icon icon-location' + (this.state.mapSelected ? ' active' : '')}/>
              Map View
            </a>
          </div>
        </div>

        <div className={this.state.showFilters ? "filters open" : "filters"}>
          <hr/>
          <div className="filter district-select">
            <label>Districts { this.state.searchLocation ? 'near ' + this.state.searchLocation : '' }</label>
            <Select objects={this.props.districts}
              labelFunc={d => d.name}
              keyFunc={d => d.state + d.id}
              onChange={d => this.props.selectDistrict(d.id, d.state)}
              defaultLabel='Search or click map for districts'
            />
          </div>
          <div className="filter grade-filter">
            <label>School Grade</label>
            <ButtonGroup
              options={{e: 'Elementary', m: 'Middle', h: 'High'}}
              onSelect={this.props.setLevel} />
          </div>
          <div className="filter">
            <label className="type-filter">Additional school type</label>
            <div>
              <Checkbox value="charter" label="Charter" onClick={this.handleSchoolType} />
              <Checkbox value="private" label="Private" onClick={this.handleSchoolType} />
            </div>
          </div>
        </div>
      </div>
    );
  }

}
