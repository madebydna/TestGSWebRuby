import React from "react";
import PropTypes from "prop-types";
import TopSchools from "./top_schools";
import School from "react_components/search/school";
import { SM, validSizes as validViewportSizes } from "util/viewport";
import * as APISchools from 'api_clients/schools';

class TopSchoolsStateful extends React.Component {
  static propTypes = {
    // schools: PropTypes.arrayOf(PropTypes.shape(School.propTypes)).isRequired,
    schoolsData: PropTypes.object.isRequired,
    size: PropTypes.oneOf(validViewportSizes).isRequired,
    locality: PropTypes.object.isRequired,
    community: PropTypes.string,
    schoolLevels: PropTypes.object
  };

  static defaultProps = {
    schools: [],
    schoolsData: {}
  };

  constructor(props) {
    super(props);
    this.state = {
      isLoading: false,
      // levelCodes: "e",
      schoolLevels: props.schoolLevels,
      districtId: props.locality.district_id,
      // levelCodes: props.schoolsData.levelCode,
      schools: props.schools,
      // schools: props.schoolsData.schools,
      size: props.size,
      state: props.locality.stateShort,
      city: props.locality.city,
      district_name: props.locality.name
    };
    this.initialSchoolLoad(props.schools);
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
    }else{
        // Set the default for City#Show page
        this.state = {
          levelCodes: 'e',
          schools: elementary
        }
    }
  }

  handleGradeLevel(str){
    const schools = { 
      'e': this.props.schools.elementary, 
      'm': this.props.schools.middle, 
      'h': this.props.schools.high
    }
    this.setState({
      levelCodes: str,
      schools: schools[str]
    })
  }

  // handleGradeLevel(str, community) {
  //   this.setState({
  //     isLoading: true
  //   });
  //   if (community === 'city') {
  //     APISchools.find(
  //       {
  //         city: this.state.city,
  //         state: this.state.state,
  //         levelCodes: [str],
  //         sort: "rating",
  //         extras: ["students_per_teacher", "review_summary", "students_per_teacher"],
  //         limit: 5,
  //         with_rating: true
  //       },
  //       {}
  //     )
  //       .then(res =>
  //         this.setState({
  //           schools: res.items,
  //           isLoading: false,
  //           levelCodes: str
  //         })
  //       )
  //       .fail((xhr, status, error) =>
  //         alert("Request timed out. Please try again.")
  //       );
  //   }else{
  //     APISchools.find(
  //       {
  //         district_id: this.state.districtId,
  //         top_school_module: true,
  //         state: this.state.state,
  //         levelCodes: [str],
  //         sort: "rating",
  //         extras: ["students_per_teacher", "review_summary", "students_per_teacher"],
  //         limit: 5,   
  //         with_rating: true
  //       },
  //       {}
  //     )
  //       .then(res =>
  //         this.setState({
  //           schools: res.items,
  //           isLoading: false,
  //           levelCodes: str
  //         })
  //       )
  //       .fail((xhr, status, error) =>
  //         alert("Request timed out. Please try again.")
  //       );
  //   }
  // }

  render() {
    return (
       <TopSchools
        schools={this.state.schools}
        schoolLevels={this.props.schoolLevels}
        // schools={this.state.schoolsData.schools}
        handleGradeLevel={this.handleGradeLevel}
        isLoading={this.state.isLoading}
        size={this.props.size}
        levelCodes={this.state.levelCodes}
        state={this.state.state}
        city={this.state.city}
        community={this.props.community}
        schoolsData={this.props.schoolsData}
      />
    );
  }
}

export default TopSchoolsStateful;