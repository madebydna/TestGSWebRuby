import React from 'react';
import PropTypes from 'prop-types';
import { capitalize, t } from 'util/i18n';
import ButtonGroup from '../buttongroup';
import Select from '../select';
import * as Geocoding from '../../components/geocoding';
import Checkbox from '../checkbox';
import SpinnyWheel from '../../react_components/spinny_wheel';

export default class SearchBar extends React.Component {

  static defaultProps = {
    district: {}
  }

  static propTypes = {
    searchTerm: PropTypes.string,
    districts: PropTypes.array,
    level: PropTypes.string,
    additionalSchoolType: PropTypes.string,
    onClickMapView: PropTypes.func,
    onClickListView: PropTypes.func,
    mapSelected: PropTypes.bool
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
      searchTerm: props.searchTerm,
      showFilters: false,
      mapSelected: props.mapSelected,
      listSelected: !props.mapSelected
    }
  }

  componentDidUpdate(prevProps, prevState) {
    if(!prevProps.googleMapsInitialized && this.props.googleMapsInitialized) {
      if(this.state.searchTerm) {
        this.search();
      }
    }
    if (prevProps.mapSelected !== this.props.mapSelected) {
      this.setState({
        mapSelected: this.props.mapSelected,
        listSelected: !this.props.mapSelected
      })
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
        } else {
          this.props.locationChangeFailed();
        }
      })
      .fail(this.props.locationChangeFailed);
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

  homesForSaleHref() {
    let homesForSaleHref = null;
    if (this.props.districts && this.props.districts[0] && this.props.districts[0].state && this.props.districts[0].address) {
      let entity = this.props.districts[0];
      homesForSaleHref = 'https://www.zillow.com/' + entity.state + '-' + entity.address.zip.split("-")[0] + '?cbpartner=Great+Schools&utm_source=GreatSchools&utm_medium=referral&utm_campaign=districtbrowsemap';
    } else {
      homesForSaleHref = 'https://www.zillow.com/?cbpartner=Great+Schools&utm_source=GreatSchools&utm_medium=referral&utm_campaign=districtbrowsemap';
    }
    return homesForSaleHref;
  }

  render() {
    let searchInput = null;
    let searchButton = <button name="submit-search" onClick={this.search}>{t('search')}</button>;
    if(this.props.loading) {
      searchInput = <SpinnyWheel><input name="search-term" type="text" defaultValue={this.state.searchTerm} onChange={this.onSearchTermChange} onKeyPress={this.submitOnEnterKey}/></SpinnyWheel>
    } else {
      searchInput = <input name="search-term" type="text" placeholder={t('enter_an_address_to_see_schools')} defaultValue={this.state.searchTerm} onChange={this.onSearchTermChange} onKeyPress={this.submitOnEnterKey}/>
    }
    return (
      <div className="filter-bar">
        <div className="search-input-and-filter-button">
          <div className="search-input">
            <label>{t('search')}</label>
            { searchInput }
            { searchButton }
            <div className="icon active icon-house"> <a href={this.homesForSaleHref()} target="_blank">{t('nearby_homes_for_sale')}</a></div>
          </div>
          <button onClick={this.toggleFilters} >Filters</button>
        </div>

        <div className="toggle-bar">
          <span className="icon active icon-house"> <a href={this.homesForSaleHref()} target="_blank">{t('nearby_homes_for_sale')}</a></span>

          <div className="list-map-toggle">
            <a href="javascript:void(0);" className="show-list" onClick={this.onClickListView}>
              <span className={'icon icon-list' + (this.state.listSelected ? ' active' : '')}/>
              <span className="icontext">List View</span>
            </a>
            <a href="javascript:void(0);" className="show-map" onClick={this.onClickMapView}>
              <span className={'icon icon-location' + (this.state.mapSelected ? ' active' : '')}/>
              <span className="icontext">Map View</span>
            </a>
          </div>
        </div>

        <div className={this.state.showFilters ? "filters open" : "filters"}>
          <hr/>
          <div className="filter district-select">
            <label>{t('districts')} { this.state.searchLocation ? 'near ' + this.state.searchLocation : '' }</label>
            <Select objects={this.props.districts}
              labelFunc={d => d.name}
              keyFunc={d => d.state + d.id}
              onChange={d => this.props.selectDistrict(d.id, d.state)}
              defaultLabel={t('search_or_click_map_for_districts')}
              defaultValue={this.props.district.id}
              key={this.props.district.id}
            />
          </div>
          <div className="filter grade-filter">
            <label>{t('school_grade')}</label>
            <ButtonGroup
              activeOption={this.props.level}
              options={[
                {key: 'e', label: t('Elementary')},
                {key: 'm', label: t('Middle')},
                {key: 'h', label: t('High')}
              ]}
              onSelect={this.props.setLevel} />
          </div>
          <div className="filter">
            <label className="type-filter">{t('additional_school_type')}</label>
            <div>
              <Checkbox value="charter" label={t('Charter')} onClick={this.handleSchoolType} />
              <Checkbox value="private" label={t('school_types.Private')} onClick={this.handleSchoolType} />
            </div>
          </div>
        </div>
      </div>
    );
  }

}
