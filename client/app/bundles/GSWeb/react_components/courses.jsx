import React, { PropTypes } from 'react';
import CourseSubject from './course_subject';
import Drawer from './drawer';
import InfoTextAndCircle from './info_text_and_circle'
import NoDataModuleCta from './no_data_module_cta';

export default class Courses extends React.Component {

  static propTypes = {
    course_enrollments_and_ratings: PropTypes.object,
    sources: PropTypes.object,
    rating: PropTypes.string,
    narration: PropTypes.string,
    faq: PropTypes.shape({
      cta: PropTypes.string.isRequired,
      content: PropTypes.string.isRequired
    })
  };

  static defaultProps = {
    sources: {}
  };

  constructor(props) {
    super(props);
  }

  sourcesToHtml() {
    let html = '<div class="sourcing">';
    html += '<h1>' + this.t('profile_data_sources_and_info') + '</h1>';
    Object.keys(this.props.sources).forEach((category) => {
      let categorySourceHash = this.props.sources[category];
      html += '<div>';
      html += '<h4>' + category + '</h4>';
      Object.keys(categorySourceHash).forEach((sourceNameAndYear) => {
        let descriptionObj = categorySourceHash[sourceNameAndYear];
        sourceNameAndYear = JSON.parse(sourceNameAndYear);
        let name = sourceNameAndYear[0];
        let year = sourceNameAndYear[1];
        let description = '';
        if (Array.isArray(descriptionObj)) {
          description = descriptionObj.join(', ');
        } else {
          description = descriptionObj;
        }
        html += '<p>' + description + '</p>';
        html += '<p><span class="emphasis">' + this.t('source') + '</span>: ' + name + ', ' + year + '</p>';
      });
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
    let num_courses = subjects.reduce ( (sum, subject) => sum + this.props.course_enrollments_and_ratings[subject].courses.length, 0);
    let courseSubjects = subjects.slice(0,3).map((subject, i) => <CourseSubject name={subject} key={i} {...this.props.course_enrollments_and_ratings[subject]} />);
    let courseSubjectsForDrawer = subjects.slice(3).map((subject, i) => <CourseSubject name={subject} key={i} {...this.props.course_enrollments_and_ratings[subject]} />);
    let ratingHtml = '';
    if (this.props.rating !== null) {
      ratingHtml = <span className={'gs-rating circle-rating--medium circle-rating--' + this.props.rating}>{this.props.rating}<span className="denominator">/10</span></span>
    } else {
      ratingHtml = <span className='circle-rating--equity-blue circle-rating--medium'><span className="icon-advanced"/></span>
    }

    if (subjects.length > 0 && num_courses > 0)
      return (<div id="AdvancedCourses" className="advanced-courses rating-container">
        <a className="anchor-mobile-offset" name="Advanced_courses"></a>
        <div className="rating-container__rating">
          <div className="module-header">
              { ratingHtml }
            <div className="title-container">
              <span className="title">{this.t('Advanced courses')} </span>
              <a data-remodal-target="modal_info_box"
                data-content-type="info_box"
                data-content-html={GS.I18n.t('advanced_courses_tooltip')}
                className="gs-tipso info-circle tipso_style" href="javascript:void(0)">
                <span className="icon-question"></span>
              </a>
              <div dangerouslySetInnerHTML={{__html: this.t('advanced_courses_subheading_html')}}></div>
            </div>
          </div>

        <div className="panel">
          <div className="auto-narration">
            <div dangerouslySetInnerHTML={{__html: this.props.narration}}></div>
          </div>
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
              <div className="rating-container__more-items">
                <Drawer
                  content={courseSubjectsForDrawer}
                  closedLabel={GS.I18n.t('Show more') + ' ' + this.t('Advanced courses')}
                  openLabel={GS.I18n.t('Show less') + ' ' + this.t('Advanced courses')}
                /> 
              </div>
          }
          <InfoTextAndCircle {...this.props.faq} />
        </div>
        <a data-remodal-target="modal_info_box"
           data-content-type="info_box"
           data-content-html={this.sourcesToHtml()}
           href="javascript:void(0)">
          <span className="">{this.t('See notes')}</span>
        </a>
      </div>
      </div>)
    else
      return <div id="AdvancedCourses-empty" className="advanced-courses rating-container">
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