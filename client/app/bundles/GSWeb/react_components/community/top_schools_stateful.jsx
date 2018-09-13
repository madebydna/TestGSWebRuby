import React from "react";
import PropTypes from "prop-types";
import TopSchools from "./top_schools";
import School from "react_components/search/school";
import { SM, validSizes as validViewportSizes } from "util/viewport";
import * as APISchools from 'api_clients/schools';

class TopSchoolsStateful extends React.Component {
  static propTypes = {
    schoolsObj: PropTypes.object,
    size: PropTypes.oneOf(validViewportSizes).isRequired,
    locality: PropTypes.object.isRequired,
    community: PropTypes.string.isRequired,
    schoolLevels: PropTypes.object,
  };

  static defaultProps = {
    schoolsObj: {},
    schoolLevels: {}
  };

  constructor(props) {
    super(props);
    this.state = {
      size: props.size,
      schoolLevels: props.schoolLevels
    };
    this.initialSchoolLoad(props.schoolsObj);
    this.handleGradeLevel = this.handleGradeLevel.bind(this);
  }

  initialSchoolLoad({elementary, middle, high}){
    if (elementary.length > 0) {
      this.state = {
        levelCodes: 'e',
        schools: elementary
      }
    }else if(middle.length > 0){
      this.state = {
        levelCodes: 'm',
        schools: middle
      }
    }else if(high.length > 0){
      this.state = {
        levelCodes: 'h',
        schools: high
      }
    }
  }

  handleGradeLevel(str){
    const schools = { 
      'e': this.props.schoolsObj.elementary, 
      'm': this.props.schoolsObj.middle, 
      'h': this.props.schoolsObj.high
    }
    this.setState({
      levelCodes: str,
      schools: schools[str]
    })
  }

  render() {
    return (
       <TopSchools
        schools={this.state.schools}
        schoolLevels={this.props.schoolLevels}
        handleGradeLevel={this.handleGradeLevel}
        size={this.props.size}
        levelCodes={this.state.levelCodes}
        community={this.props.community}
        locality={this.props.locality}
      />
    );
  }
}

export default TopSchoolsStateful;