import React, { PropTypes } from 'react';
import CourseSubject from './course_subject';
import Drawer from './drawer';
import NoDataModuleCta from './no_data_module_cta';

export default class Courses extends React.Component {

  static propTypes = {
    course_enrollments_and_ratings: PropTypes.object,
    sources: PropTypes.object,
    rating: PropTypes.string
  };

  static defaultProps = {
    sources: {}
  };

  constructor(props) {
    super(props);
  }

  sourcesToHtml() {
    let html = '<h1 style="text-align:center; font-size:22px; font-family:RobotoSlab-Bold;">GreatSchools profile data sources &amp; information</h1>';
    html += '<div style="padding: 40px 40px 20px 40px">';
      html += '<h4 style="font-family:RobotoSlab-Bold;">' + this.t('Advanced courses') + '</h4>';
      Object.keys(this.props.sources).forEach((sourceNameAndYear) => {
        let courses = this.props.sources[sourceNameAndYear];
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

  t(string) {
    if (window.GS && GS.I18n && GS.I18n.t) {
      return GS.I18n.t(string);
    } else {
      return string;
    }
  }

  render() {
    let subjects = Object.keys(this.props.course_enrollments_and_ratings);
    let courseSubjects = subjects.slice(0,3).map((subject, i) => <CourseSubject name={subject} key={i} {...this.props.course_enrollments_and_ratings[subject]} />);
    let courseSubjectsForDrawer = subjects.slice(3).map((subject, i) => <CourseSubject name={subject} key={i} {...this.props.course_enrollments_and_ratings[subject]} />);

    if (subjects.length > 0)
      return (<div id="advanced-courses" className="rating-container">
        <a className="anchor-mobile-offset" name="Advanced_courses"></a>
        <div className="rating-container__rating">
          <div className="module-header">
              <span className={'gs-rating circle-rating--medium circle-rating--' + this.props.rating}>{this.props.rating}<span className="denominator">/10</span></span>
            <div className="title-container">
              <div className="title">{this.t('Advanced courses')}</div>
                <span dangerouslySetInnerHTML={{__html: this.t('advanced_courses_subheading_html')}}>
                </span>
            </div>
          </div>
        </div>
        <div>
          <div className="rating-container__score-item course-subject-header">
            <span dangerouslySetInnerHTML={{__html: this.t('subjects')}}></span>
            <span>
              <span dangerouslySetInnerHTML={{__html: this.t('rating_html')}}></span>
              <a data-remodal-target="modal_info_box"
                data-content-type="info_box"
                data-content-html={this.t('advanced_courses_rating_tooltip')}
                className="gs-tipso info-circle tipso_style"
                href="javascript:void(0)">
                <span className="icon-question"></span>
              </a>
            </span>
          </div>
          {courseSubjects}
          {courseSubjectsForDrawer.length > 0 &&
          <div className="rating-container__more-items"><Drawer content={courseSubjectsForDrawer} /> </div>}
        </div>
        <a data-remodal-target="modal_info_box"
           data-content-type="info_box"
           data-content-html={this.sourcesToHtml()}
           href="javascript:void(0)">
          <span className="">{this.t('See notes')}</span>
        </a>
      </div>)
    else
      return <div id="advanced-courses" className="rating-container">
      <a className="anchor-mobile-offset" name="Advanced_courses"></a>
        <div className="rating-container__rating">
          <div className="module-header">
            <div className="circle-rating--equity-blue circle-rating--medium">
              <span className="icon-user"></span>
            </div>
            <div className="title-container">
              <div className="title">{this.t('Advanced courses')}</div>
              <span dangerouslySetInnerHTML={{__html: this.t('advanced_courses_subheading_html')}}></span>
              <NoDataModuleCta moduleName="Advanced courses"/>
            </div>
          </div>
        </div>
      </div>
  }
}
