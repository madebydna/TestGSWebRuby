import React from 'react';
import PropTypes from 'prop-types';
import {
  getStudentGrades,
  deleteStudentGrade,
  addStudentGrade
} from 'api_clients/subscriptions';
import { filter, debounce } from 'lodash';

const allGrades = [
  'PK',
  'KG',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '10',
  '11',
  '12'
];

class GradeLevelSelectable extends React.Component {
  static propTypes = {};
  static defaultProps = {};

  constructor(props) {
    super(props);
    const grades = props.grades || [];
    this.state = {
      grades: [...grades],
      UIgrades: [...grades]
    };
    this.makeStudentGradeRequestFuncs = {};
  }

  componentDidMount() {
    if (!this.state.grades || this.state.grades.length === 0) {
      getStudentGrades().done(grades => {
        this.setState({ grades });
      });
    }
  }

  isGradeChosenOnServer(grade) {
    return this.state.grades.includes(grade);
  }

  isGradeChecked(grade) {
    return this.state.UIgrades.includes(grade);
  }

  toggleStudentGradeFunc(grade) {
    return () => {
      // we update this components state with the new grade before
      // we initiate a request to the api, so that the user needs
      // an immediate response within the UI. If the request fails,
      // the user will see their selection revert itself
      if (this.isGradeChecked(grade)) {
        this.setState(
          {
            UIgrades: filter(this.state.UIgrades, g => g !== grade)
          },
          () => this.makeStudentGradeRequestFunc(grade)()
        );
      } else {
        this.setState(
          {
            UIgrades: [...this.state.UIgrades, grade]
          },
          () => this.makeStudentGradeRequestFunc(grade)()
        );
      }
    };
  }

  makeStudentGradeRequestFunc(grade) {
    // memoize one function per grade, which will either add or remove the grade
    // depending on current UI state compared with server state
    // Debounce each function to prevent multiple clicks from spamming API

    this.makeStudentGradeRequestFuncs[grade] =
      this.makeStudentGradeRequestFuncs[grade] ||
      debounce(() => {
        if (this.isGradeChecked(grade) && !this.isGradeChosenOnServer(grade)) {
          addStudentGrade(grade).done(grades => this.setState({ grades }));
        } else if (
          !this.isGradeChecked(grade) &&
          this.isGradeChosenOnServer(grade)
        ) {
          deleteStudentGrade(grade).done(grades => this.setState({ grades }));
        }
      }, 500);

    return this.makeStudentGradeRequestFuncs[grade];
  }

  render() {
    return allGrades.map(grade =>
      this.props.children({
        grade,
        active: this.isGradeChecked(grade),
        toggle: this.toggleStudentGradeFunc(grade)
      })
    );
  }
}

export default GradeLevelSelectable;
