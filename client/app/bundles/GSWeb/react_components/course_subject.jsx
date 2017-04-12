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
    return this.props.courses.map((course) => <li>{course}</li>);
  }

  toggle() {
    this.setState({
      open: !this.state.open
    });
  }

  t(string) {
    if (window.GS && GS.I18n && GS.I18n.t) {
      return GS.I18n.t(string);
    } else {
      return string;
    }
  }

  render() {
    return (
      <div className="rating-container__score-item">
        <div className="course-subject" onClick={this.toggle}>
          <span>{this.props.name}</span>
          <span>
            <span className={'gs-rating-inline circle-rating--xtra-small circle-rating--' + this.props.rating}>{this.props.rating}<span class="denominator">/10</span></span>
          </span>
          { this.props.courses && <span><a href="javascript:void(0)">{this.props.courses.length} <span>{this.t('courses')}</span></a></span> }
          <span className="icon-caret-down show-classes" />
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
