import React, { PropTypes } from 'react';
import InfoCircle from '../info_circle';
import InfoTextAndCircle from '../info_text_and_circle'
import SectionNavigation from './tabs/section_navigation';
import SubSectionToggle from './sub_section_toggle';
import InfoBox from '../school_profiles/info_box';
import GiveUsFeedback from '../school_profiles/give_us_feedback';

import { handleAnchor } from '../../components/anchor_router';

export default class EquitySection extends React.Component {

  static propTypes = {
    sources: React.PropTypes.string,
    qualaroo_module_link: React.PropTypes.string,
    equity_config: React.PropTypes.shape({
      section_info: React.PropTypes.object,
      section_content: React.PropTypes.arrayOf(React.PropTypes.shape({
        subject: React.PropTypes.string,
        component: React.PropTypes.object,
        explanation: React.PropTypes.element
      }))
    }),
    faq: PropTypes.shape({
      cta: PropTypes.string.isRequired,
      content: PropTypes.string.isRequired
    })
  };

  constructor(props) {
    super(props);
    this.state = {
      active: 0,
      defaultSubSectionTab: null
    }
  }

  footer(sources, qualaroo_module_link) {
    return (
        <div>
          <InfoBox content={sources} >{ GS.I18n.t('See notes') }</InfoBox>
          <GiveUsFeedback content={qualaroo_module_link} />
        </div>
    )
  }

  componentDidMount() {
    let mapping = {
      'Raza/etnicidad': 'Race_ethnicity',
      'Race/ethnicity': 'Race_ethnicity',
      'Low-income students': 'Low-income_students',
      'De bajos Ingresos': 'Low-income_students',
      'Estudiantes con discapacidades': 'Students_with_Disabilities',
      'Students with Disabilities': 'Students_with_Disabilities'
    };
    handleAnchor(
      mapping[this.props.equity_config["section_info"].anchor], tokens => {
        let tabNameAnchorMap = {
          'Test scores': 'Test_scores',
          'Graduation rates': 'Graduation_rates',
          'Advanced coursework': 'Advanced_coursework',
          'Discipline & attendance': 'Discipline_and_attendance',
          'Resultados de exámenes': 'Test_scores',
          'Índices de Graduación': 'Graduation_rates',
          'Cursos avanzados': 'Advanced_coursework',
          'Disciplina y asistencia': 'Discipline_and_attendance'
        };
        let section_content = this.props.equity_config["section_content"];
        let index = section_content.findIndex((content) => tabNameAnchorMap[content["section_title"]] == tokens[0]);
        if(index == -1) {
          index = 0;
        }
        this.setState({ active: index });
      }
    );
  }

  selectSectionContent(section_content) {
    let item = section_content[this.state.active];
    return <div className={'tabs-panel tabs-panel_selected'}>
      <SubSectionToggle
          defaultTab={this.state.defaultSubSectionTab}
          key={this.state.active}
          equity_config={item["content"]}
          parent_tab={this.props.equity_config["section_content"][this.state.active].section_title}
      />
    </div>
  }
  drawRatingCircle(rating, icon) {
    let rating_html = '';
    if (rating && rating != '') {
      let circleClassName = 'circle-rating--medium rating-layout circle-rating--'+rating;
      rating_html = <div className={circleClassName}>{rating}<span className="rating-circle-small">/10</span></div>;
    }
    else{
      let circleClassName = 'rating-layout circle-rating--equity-blue';
      rating_html = <div className={circleClassName}><span className={icon}></span></div>;
    }
    return rating_html
  }

  drawInfoCircle(infoText) {
    if (infoText) {
      return(<InfoCircle
        content={infoText}
      />
      );
    } else {
      return null;
    }
  }

  linkName(name){
    return name.split(' ').join('_').replace('/', '_');
  }

  sectionTitle(sectionInfo) {
    var subtitle = '';
    var message = '';
    if (sectionInfo.subtitle) {
      subtitle = sectionInfo.subtitle;
    }
    if (sectionInfo.message) {
      message = sectionInfo.message;
    }
    return (
        <div className="title-container">
          <div className="title">
            {sectionInfo.title}
            {this.drawInfoCircle(sectionInfo.info_text)}
          </div>
          {subtitle}
          {message}
        </div>
    )
  }

  render() {
    let section_info = this.props.equity_config["section_info"];
    let section_content = this.props.equity_config["section_content"];
    let rating = this.drawRatingCircle(section_info.rating, section_info.icon_classes);
    let link_name = this.linkName(section_info.anchor);
    if (section_content) {
      return <div className="equity-section" data-ga-click-label={section_info.title}>
        <a className="anchor-mobile-offset" name={link_name}></a>
        <div className="title-bar">{rating}{this.sectionTitle(section_info)}</div>
        <div className="tab-buttons">
          <SectionNavigation key="sectionNavigation"
                           items={section_content}
                           active={this.state.active}
                           google_tracking={section_info.title}
                           onTabClick={this.handleTabClick.bind(this)}/>
        </div>
        <div className="top-tab-panel">
          {this.selectSectionContent(section_content)}
          <InfoTextAndCircle {...this.props.faq} />
        </div>
        { this.footer(this.props.sources, this.props.qualaroo_module_link) }
      </div>
    }
    else {
      return <div className="equity-section">
        <a className="anchor-mobile-offset" name={link_name}></a>
        <div className="title-bar">{rating}{this.sectionTitle(section_info)}</div>
        </div>
    }
  }

  handleTabClick(index) {
    this.setState({active: index})
  }
};
