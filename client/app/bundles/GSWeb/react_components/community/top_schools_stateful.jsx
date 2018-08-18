import React from "react";
import PropTypes from "prop-types";
import TopSchools from "./top_schools";
import School from "react_components/search/school";
import { S, validSizes as validViewportSizes } from "util/viewport";
import * as APISchools from 'api_clients/schools';

class TopSchoolsStateful extends React.Component {
  static propTypes = {
    schools: PropTypes.arrayOf(PropTypes.shape(School.propTypes)).isRequired,
    // size: PropTypes.oneOf(validViewportSizes).isRequired,
  };

  static defaultProps = {
    schools: []
  };

  constructor(props) {
    super(props);
    this.state = this.props;
    this.state = {
      isLoading: false,
      size: null,
      levelCodes: 'e'
    };
    this.handleGradeLevel = this.handleGradeLevel.bind(this);
  }

  componentDidMount() {
    this.setState({
      schools: this.props.schools
    });
    // temp solution until I can figure out how to use size
    this.tempFindSize()
  }

  tempFindSize(){
    const size = window.innerWidth;
    if (size !== this.state.size) {
      this.setState({size})
    }
  }

  handleGradeLevel(str) {
    this.setState({ 
      isLoading: true,
    });
    APISchools.find(
      {
        city: this.props.schools[0].address.city,
        state: this.props.schools[0].state,
        levelCodes: [str],
        sort: "rating",
        extras: ["students_per_teacher", "review_summary"],
        limit: 5
      },
      {}
    ).then(res =>
      this.setState({
        schools: res.items,
        isLoading: false,
        levelCodes: str
      })
    );
  }

  render() {
    return (
      <TopSchools
        schools={this.state.schools}
        handleGradeLevel={this.handleGradeLevel}
        isLoading={this.state.isLoading}
        size={this.state.size}
        levelCodes={this.state.levelCodes}
      />
    );
  }
}

export default TopSchoolsStateful;