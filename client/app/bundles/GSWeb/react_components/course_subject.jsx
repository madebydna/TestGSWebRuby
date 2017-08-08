import React, { PropTypes } from 'react';

export default class CourseSubject extends React.Component {

  static propTypes = {
    name: PropTypes.string,
    rating: PropTypes.number,
    courses: PropTypes.array
  }
  static defaultProps = {
    courses: []
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

  renderCoursesCount(){
    var underline_none = 'none';
    var text_no_underline = {textDecoration: underline_none};
    let carets = 'icon-caret-down rotate-text-270 show-classes'
    if ( this.state.open ) {
      carets = 'icon-caret-down show-classes'
    }
    let course_word = '';
    if (this.props.courses.length === 1) {
      course_word = this.t('course');
    } else {
      course_word = this.t('courses');
    }
    if( this.props.courses.length > 0 ){
      return (
          <span>
            <a href="javascript:void(0)" style={text_no_underline}>{this.props.courses.length} <span>{ course_word }</span>
            <span className={carets} /></a>
          </span>
      );
    }
    else{
      var white = '#FFFFFF';
      var colorWhite = {color: white};
      return (
          <span>
            {this.props.courses.length} <span>{this.t('courses')}</span>
            <span className={carets} style={colorWhite} />
          </span>
      );
    }
  }

  render() {
    return (
      <div className="rating-container__score-item">
        <div className="course-subject" onClick={this.toggle}>
          <span>{this.props.name}</span>
          <span>
            <span className={'gs-rating-inline circle-rating--xtra-small circle-rating--' + this.props.rating}>{this.props.rating}<span className="denominator">/10</span></span>
          </span>
          {this.renderCoursesCount()}
        </div>
        { this.state.open && this.props.courses.length > 0 &&
          <ul>
            {this.listOfCourses()}
          </ul>
        }
      </div>
    )
  }
}
