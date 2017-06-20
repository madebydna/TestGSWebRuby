import React from 'react';
import BasicDataModuleLayout from './basic_data_module_layout';
import { PieCircleIcon } from './circle_icons';
import Tooltip from './tooltip';
import QuestionMarkTooltip from './question_mark_tooltip';
import ParentTip from './parent_tip';
import PersonBar from '../visualizations/person_bar';
import BarGraphBase from '../equity/graphs/bar_graph_base';
import BasicDataModuleRow from '../school_profiles/basic_data_module_row';
import InfoTextAndCircle from '../info_text_and_circle';

function t(string) {
  if (window.GS && GS.I18n && GS.I18n.t) {
    return GS.I18n.t(string) || string;
  } else {
    return string;
  }
}

const stateAverageLabel = function(stateAverageValue) {
  let f = parseFloat(stateAverageValue);
  if(isNaN(f)) {
    return stateAverageValue;
  } else {
    return Math.round(f).toString();
  }
}

const visualizationMap = {
  'PersonBar': PersonBar,
  'SingleBar': BarGraphBase
};

const listOfVisualizations = function(courses) {
  return courses.map((course) => {
    let Vis = visualizationMap[course.visualization];
    return <BasicDataModuleRow {...course}>
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

const StemModule = ({title, titleTooltipText, parentTip, subtitle, faqCta, faqContent, courses, sources }) => {

  let titleElement = <span>
    {title} <QuestionMarkTooltip content={titleTooltipText} />
  </span>;

  let body = <div>
    <ParentTip><span dangerouslySetInnerHTML={{__html: parentTip}}/></ParentTip>
    {listOfVisualizations(courses)}
    <InfoTextAndCircle cta={faqCta} content={faqContent} />
  </div>

  let footer = <Tooltip content={sourcesToHtml(sources)} >{ t('Sources') }</Tooltip>

    return <div>
      <a className="anchor-mobile-offset" name="Advanced_courses"></a>
      <BasicDataModuleLayout
        className='stem-module'
        icon = { <PieCircleIcon /> }
        title = { titleElement }
        subtitle = { subtitle }
        footer = { footer }
        body = { body }
      />
    </div>
};

StemModule.PropTypes = {
  className: React.PropTypes.string
}

export default StemModule;
