import React, { PropTypes } from 'react';
import CourseSubject from './course_subject';

export default class Courses extends React.Component {

  static propTypes = {
    course_enrollments_and_ratings: PropTypes.object 
  }

  constructor(props) {
    super(props);
  }

  render() {
    let subjects = Object.keys(this.props.course_enrollments_and_ratings);
    let courseSubjects = subjects.map((subject) => <CourseSubject name={subject} {...this.props.course_enrollments_and_ratings[subject]} />);
    return <div id="advanced-courses" className="rating-container">
      <div className="rating-container__rating">
        <div className="module-header">
          <div className="circle-rating--equity-blue circle-rating--medium">
            <span className="icon-user"></span>
          </div>
          <div className="title-container">
            <div className="title">{GS.I18n.t('Advanced courses')}</div>
              <span dangerouslySetInnerHTML={{__html: GS.I18n.t('advanced_courses_subheading_html')}}>
              </span>
          </div>
        </div>
      </div>
      <div>
        <div className="rating-container__score-item course-subject-header">
          <span>Subjects</span>
          <span>
            Rating&nbsp;
            <a data-remodal-target="modal_info_box"
              data-content-type="info_box"
              data-content-html={GS.I18n.t('advanced_courses_rating_tooltip')}
              className="gs-tipso info-circle tipso_style"
              href="javascript:void(0)">
              <span className="icon-question"></span>
            </a>
          </span>
          <span></span>
        </div>
        {courseSubjects}
      </div>
    </div>
  }
}
