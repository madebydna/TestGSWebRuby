import React from "react";
import PropTypes from "prop-types";
import TopSchools from "./top_schools";
import School from "react_components/search/school";

class TopSchoolsStateful extends React.Component {
  static propTypes = {
    schools: PropTypes.arrayOf(PropTypes.shape(School.propTypes)).isRequired
  };

  constructor(props) {
    super(props);
    this.state = this.props
    this.handleGradeLevel = this.handleGradeLevel.bind(this);
  }

  handleGradeLevel(str){

  }

  render() {
    return(
      <TopSchools 
        schools={this.state.schools}
        handleGradeLevel={this.handleGradeLevel}
      />
    );
  }
}

export default TopSchoolsStateful;