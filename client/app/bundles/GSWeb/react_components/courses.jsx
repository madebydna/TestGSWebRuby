import React, { PropTypes } from 'react';
import CourseSubject from './course_subject';
import Drawer from './drawer';

export default class Courses extends React.Component {

  static propTypes = {
    course_enrollments_and_ratings: PropTypes.object 
  }

  constructor(props) {
    super(props);
  }

  sourcesToHtml() {
    let html = '<h1 style="text-align:center; font-size:22px; font-family:RobotoSlab-Bold;">GreatSchools profile data sources &amp; information</h1>';
    html += '<div style="padding: 40px 40px 20px 40px">';
      html += '<h4 style="font-family:RobotoSlab-Bold;">' + GS.I18n.t('Advanced courses') + '</h4>';
      Object.entries(this.props.sources).forEach(([sourceNameAndYear, courses]) => {
        sourceNameAndYear = JSON.parse(sourceNameAndYear);
        let name = sourceNameAndYear[0];
        let year = sourceNameAndYear[1];
        let commaSeparatedCourses = courses.join(', ');
        html += '<div style="margin-bottom:10px; font-weight:bold;">' + commaSeparatedCourses + '</div>';
        html += '<div style="padding-bottom:40px;">';
        html += '<span>Source: ' + name + ', ' + year +'</span>';
        html += '</div>';
      });
    html += '</div>';
    return html;
  }

  render() {
    let subjects = Object.keys(this.props.course_enrollments_and_ratings);
    let courseSubjects = subjects.slice(0,3).map((subject) => <CourseSubject name={subject} {...this.props.course_enrollments_and_ratings[subject]} />);
    let courseSubjectsForDrawer = subjects.slice(4).map((subject) => <CourseSubject name={subject} {...this.props.course_enrollments_and_ratings[subject]} />);

    return <div id="advanced-courses" className="rating-container">
      <a className="anchor-mobile-offset" name="Advanced_courses"></a>
      <div className="rating-container__rating">
        <div className="module-header">
            <span className={'gs-rating circle-rating--medium circle-rating--' + this.props.rating}>{this.props.rating}<span class="denominator">/10</span></span>
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
        {courseSubjectsForDrawer.length > 0 && <Drawer content={courseSubjectsForDrawer} /> }
      </div>
      <a data-remodal-target="modal_info_box"
         data-content-type="info_box"
         data-content-html={this.sourcesToHtml()}
         href="javascript:void(0)">
        <span className="">{GS.I18n.t('See notes')}</span>
      </a>
    </div>
  }
}
