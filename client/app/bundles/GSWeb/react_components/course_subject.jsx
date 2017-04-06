import React, { PropTypes } from 'react';

export default class CourseSubject extends React.Component {

  static propTypes = {
    name: PropTypes.string,
    rating: PropTypes.number,
    courses: PropTypes.array
  }

  constructor(props) {
    super(props);
    this.state = {
      open: false
    }
    this.toggle = this.toggle.bind(this);
  }

  listOfCourses() {
    return this.props.courses.map((course) => <li>{course.name}</li>);
  }

  toggle() {
    this.setState({
      open: !this.state.open
    });
  }

  render() {
    return (
      <div className="rating-container__score-item">
        <div className="course-subject" onClick={this.toggle}>
          <span>{this.props.name}</span>
          <span>
            <span className={'gs-rating circle-rating--xtra-small circle-rating--' + this.props.rating}>{this.props.rating}<span class="denominator">/10</span></span>
          </span>
          <span><a href="javascript:void(0)">{this.props.courses.length} courses</a></span>
        </div>
        { this.state.open &&
          <ul>
            {this.listOfCourses()}
          </ul>
        }
      </div>
    )
  }
}
