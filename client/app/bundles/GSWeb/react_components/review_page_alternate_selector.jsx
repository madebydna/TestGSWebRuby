import React from 'react';
import { stateAbbreviations } from '../util/states';
import {hasClass, addClass, removeClass} from 'util/selectors';
import {t} from "../../../../../app/assets/javascripts/util/i18n";

export default class ReviewPageAlternateSelector extends React.Component  {
  constructor(props) {
    super(props);
    this.schoolList = [];
    this.state = {
      state_value: '',
      cityOptions: [],
      city_value: ''
    }
  }

  onQueryMatchesAddress(q) {}

  loadCities = function(state) {
    $.ajax({
      type: 'GET',
      url: "/gsr/ajax/get_cities_alphabetically",
      data: {state: state},
      async: true
    }).done((data) => {
      this.setState({state_value: state, cityOptions: data, city_value: ''});
    });
  };

  loadSchools = function(state, city) {
    $.ajax({
      type: 'GET',
      url: "/gsr/ajax/get_schools_with_link",
      data: {state: state, city: city, osp: this.props.osp},
      async: true
    }).done((data) => {
      this.schoolList = data;
      this.setState({city_value: city});
    });
  };

  render() {
    return (
        <React.Fragment>
          {this.stateCitySchoolSelect()}
        </React.Fragment>
    )
  }

  handleStateSelect(event) {
    if(event.target.value == '') return true;
    this.loadCities(event.target.value);
  }

  handleCitySelect(event){
    if(event.target.value == '') return true;
    this.loadSchools(this.state.state_value, event.target.value);
  }

  handleSchoolSelect(event){
    let url = event.target.value;
    console.log("state: " + event.target.value);
    if(!this.props.osp){
      url = url +'#Reviews';
    }
    window.location.assign(url);
  }

  stateCitySchoolSelect() {
    let maxWidth = {
      maxWidth: '600px'
    };

    let subtitleHeight = {
      height: '35px'
    };

    let paddingBottom = {
      paddingBottom: '20px'
    };

    let state_option_list = stateAbbreviations.map((state, key) =>
        <option value={state}>{state.toUpperCase()}</option>
    );

    let city_option_list = this.state.cityOptions.map((city, key) =>
        <option value={city}>{city}</option>
    );

    let school_option_list = this.schoolList.map((school, key) =>
        <option value={school['url']}>{school['name']}</option>
    );

    return (
        <React.Fragment>
          <div className="subtitle-sm tac" style={subtitleHeight}></div>
          <div className="form-control ma" style={maxWidth}>
            <div style={paddingBottom}>

              <select value={this.state.state_value} onChange={(e) => this.handleStateSelect(e)} className="notranslate form-control mtm ">
                <option value="">Select state</option>
                {state_option_list}
              </select>
            </div>
            {this.state.state_value &&
              <div style={paddingBottom}>
                <select className="form-control notranslate" value={this.state.city_value} onChange={(e) => this.handleCitySelect(e)} >
                  <option value=''>Select City</option>
                  {city_option_list}
                </select>
              </div>}
            {(this.state.state_value && this.state.city_value) &&
              <div style={paddingBottom}>
                <select className="form-control notranslate" onChange={(e) => this.handleSchoolSelect(e)} >
                  <option value=''>Select School</option>
                  {school_option_list}
                </select>
              </div>}
          </div>
        </React.Fragment>
    )
  }
}