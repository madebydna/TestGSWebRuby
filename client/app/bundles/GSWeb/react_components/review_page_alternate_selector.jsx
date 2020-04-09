import React from 'react';
import { titleizedName, statesToDisplay } from '../util/states';
import PropTypes from "prop-types";

export default class ReviewPageAlternateSelector extends React.Component  {
  static propTypes = {
    osp: PropTypes.bool
  };

  static defaultProps = {
    osp: false
  };

  constructor(props) {
    super(props);
    this.schoolList = [];
    this.state = {
      stateValue: '',
      cityOptions: [],
      cityValue: ''
    }
  };

  loadCities = function(state) {
    $.ajax({
      type: 'GET',
      url: "/gsr/ajax/get_cities_alphabetically",
      data: {state: state},
      async: true
    }).done((data) => {
      this.setState({stateValue: state, cityOptions: data, cityValue: ''});
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
      this.setState({cityValue: city});
    });
  };

  render() {
    return (
        <React.Fragment>
          {this.stateCitySchoolSelect()}
        </React.Fragment>
    )
  }

  handleStateSelect = (event) => {
    if(event.target.value == '') return true;
    this.loadCities(event.target.value);
  };

  handleCitySelect = (event) => {
    if(event.target.value == '') return true;
    this.loadSchools(this.state.stateValue, event.target.value);
  };

  handleSchoolSelect = (event) => {
    let url = event.target.value;
    if(!this.props.osp){
      url = url +'#Reviews';
    }
    window.location.assign(url);
  };

  stateCitySchoolSelect() {
    let maxWidth = {
      maxWidth: '600px'
    };

    let subtitleHeight = {
      height: '1em'
    };

    let paddingBottom = {
      paddingBottom: '1em'
    };

    let stateOptionList = Object.keys(statesToDisplay()).sort().map(state =>
      <option value={statesToDisplay()[state]}>{titleizedName(state)}</option>
    );

    let cityOptionList = this.state.cityOptions.map((city) =>
        <option value={city}>{city}</option>
    );

    let schoolOptionList = this.schoolList.map((school) =>
        <option value={school['url']}>{school['name']}</option>
    );

    return (
      <div className="review-alternate-school-picker">
        <div className="subtitle-sm tac" style={subtitleHeight}></div>
        <div className="form-control ma" style={maxWidth}>
          <div style={paddingBottom}>
            <select value={this.state.stateValue} onChange={this.handleStateSelect} className="notranslate form-control mtm">
              <option value="">Select state</option>
              {stateOptionList}
            </select>
          </div>
          {this.state.stateValue &&
            <div style={paddingBottom}>
              <select className="form-control notranslate" value={this.state.cityValue} onChange={this.handleCitySelect} >
                <option value=''>Select City</option>
                {cityOptionList}
              </select>
            </div>}
          {(this.state.stateValue && this.state.cityValue) &&
            <div style={paddingBottom}>
              <select className="form-control notranslate" onChange={this.handleSchoolSelect} >
                <option value=''>Select School</option>
                {schoolOptionList}
              </select>
            </div>}
        </div>
      </div>
    )
  };
}