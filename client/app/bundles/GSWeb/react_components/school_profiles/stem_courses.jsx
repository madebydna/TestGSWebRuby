import React from 'react';
import PropTypes from 'prop-types';
import BasicDataModuleLayout from './basic_data_module_layout';
import { MicroscopeCircleIcon } from './circle_icons';
import Tooltip from './tooltip';
import InfoBox from './info_box';
import QuestionMarkTooltip from './question_mark_tooltip';
import ParentTip from './parent_tip';
import PersonBar from '../visualizations/person_bar';
import BarGraphBase from '../equity/graphs/bar_graph_base';
import BasicDataModuleRow from '../school_profiles/basic_data_module_row';
import InfoTextAndCircle from '../info_text_and_circle';
import GiveUsFeedback from './give_us_feedback';
import { t } from '../../util/i18n';

const stateAverageLabel = function(stateAverageValue) {
  let f = parseFloat(stateAverageValue);
  if(isNaN(f)) {
    return stateAverageValue;
  } else {
    return Math.round(f).toString();
  }
}
function footer(sources, qualaroo_module_link) {
  return (
    <div>
      <InfoBox content={sourcesToHtml(sources)} >{ t('See notes') }</InfoBox>
      <GiveUsFeedback content={qualaroo_module_link} />
    </div>
  )
}


const visualizationMap = {
  'PersonBar': PersonBar,
  'SingleBar': BarGraphBase
};

const listOfVisualizations = function(courses) {
  return courses.map((course, index) => {
    let Vis = visualizationMap[course.visualization];
    return <BasicDataModuleRow {...course} key={index}>
      <Vis {...course} state_average_label={stateAverageLabel(course.state_average)} />
    </BasicDataModuleRow>
  });
}

const sourcesToHtml = function(sources) {
  let html = '<div class="sourcing">';
  html += '<h1>GreatSchools profile data sources &amp; information</h1>';
  html += '<div>';
  html += sources.map((source) => {
    return '<div>'+
      '<h4>' + source.data_type + '</h4>' +
      '<p>' +
      '<span class="emphasis">Source:</span> ' + source.source_name + ', ' + source.source_year +
      '</p>' +
    '</div>';
  }).join('');
  html += '</div>';
  return html;
}

const StemModule = ({title, titleTooltipText, parentTip, subtitle, faqCta, faqContent, courses, sources, qualaroo_module_link, share_content }) => {


  let titleElement = <span>
    {title}&nbsp;<QuestionMarkTooltip content={titleTooltipText} element_type="toptooltip" />
  </span>;

  let body = <div>
    <ParentTip><span dangerouslySetInnerHTML={{__html: parentTip}}/></ParentTip>
    {listOfVisualizations(courses)}
    <InfoTextAndCircle cta={faqCta} content={faqContent} />
  </div>



  return <div>
    <a className="anchor-mobile-offset" name="Advanced_courses"></a>
    <BasicDataModuleLayout
      share_content = {share_content}
      className='stem-module'
      icon = { <MicroscopeCircleIcon /> }
      title = { titleElement }
      subtitle = { subtitle }
      footer = { footer(sources, qualaroo_module_link) }
      body = { body }
    />
  </div>
};

StemModule.propTypes = {
  className: PropTypes.string
}

export default StemModule;
