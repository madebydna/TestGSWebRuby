import React from "react";
import PropTypes from "prop-types";
import TopSchools from "./top_schools";
import School from "react_components/search/school";
import { SM, validSizes as validViewportSizes } from "util/viewport";
import * as APISchools from 'api_clients/schools';

class TopSchoolsStateful extends React.Component {
  static propTypes = {
    schools: PropTypes.arrayOf(PropTypes.shape(School.propTypes)).isRequired,
    size: PropTypes.oneOf(validViewportSizes).isRequired,
  };

  static defaultProps = {
    schools: []
  };

  constructor(props) {
    super(props);
    this.state = {
      isLoading: false,
      levelCodes: "e",
    };
    this.handleGradeLevel = this.handleGradeLevel.bind(this);
    this.hydrateState = this.hydrateState.bind(this);
  }

  componentDidMount() {
    this.hydrateState(this.props);
  }

  hydrateState(props){
    this.setState({
      schools: props.schools,
      size: props.size,
      state: props.schools[0].state,
      city: props.schools[0].address.city
    });
  }

  handleGradeLevel(str) {
    this.setState({
      isLoading: true
    });
    APISchools.find(
      {
        city: this.state.city,
        state: this.state.state,
        levelCodes: [str],
        sort: "rating",
        extras: ["students_per_teacher", "review_summary"],
        limit: 5
      },
      {}
    )
      .then(res =>
        this.setState({
          schools: res.items,
          isLoading: false,
          levelCodes: str
        })
      )
      .fail((xhr, status, error) =>
        alert("Request timed out. Please try again.")
      );
  }

  render() {
    return (
      <TopSchools
        schools={this.state.schools}
        handleGradeLevel={this.handleGradeLevel}
        isLoading={this.state.isLoading}
        size={this.props.size}
        levelCodes={this.state.levelCodes}
        state={this.state.state}
        city={this.state.city}
      />
    );
  }
}

export default TopSchoolsStateful;