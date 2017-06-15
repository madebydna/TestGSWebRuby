import React from 'react';
import BasicDataModuleLayout from './basic_data_module_layout';
import { PieCircleIcon } from './circle_icons';
import Tooltip from './tooltip';
import QuestionMarkTooltip from './question_mark_tooltip';
import ParentTip from './parent_tip';

function t(string) {
  if (window.GS && GS.I18n && GS.I18n.t) {
    return GS.I18n.t(string) || string;
  } else {
    return string;
  }
}

const listOfVisualizations = function(dataPoints) {
  return (
    <div className="row bar-graph-display"><div className="test-score-container clearfix"><div className="col-xs-12 col-sm-5 subject">Data point label</div><div className="col-sm-1"></div><div className="col-xs-9 col-sm-4"><div className="bar-graph-container"><div className="score">36%</div><div className="item-bar"><div className="single-bar-viz"><div className="color-row" style={{'width': '36%', 'background-color': 'rgb(210, 184, 27)'}}></div><div className="grey-row" style={{width: '64%'}}></div><div className="arrow-up"><span style={{left: '19%', top: '11px'}}></span></div></div></div></div><div className="state-average">State avg:19%</div></div><div className="col-xs-3 col-sm-2"></div></div></div>
  );
}

const StemModule = ({title, parentTip, subtitle}) => {
  title = 'Advanced STEM courses';
  parentTip = 'Many successful high school students end up in remedial math courses in college. Is your student prepared for college-level math? Ask this school how they ensure that students are well prepared.';
  subtitle = 'A rigorous STEM course load can help your student prepare for and get into college. Find out more about why STEM coursework is so important for today’s students.'

  data = [
    {
      breakdown: 'data point label',
      score: 90,
      label: '>90%',
      state_average: 95,
      state_average_label: '>95%'
    },
    {
      breakdown: 'data point label',
      score: 90,
      label: '>90%',
      state_average: 95,
      state_average_label: '>95%'
    }
  ]


  let titleElement = <span>
    {title} <QuestionMarkTooltip content="foo bar baz" />
  </span>;

  let body = <div>
    <ParentTip>{parentTip}</ParentTip>
    {listOfVisualizations()}
  </div>

  let footer = <Tooltip content="foo bar baz" >{ t('Sources') }</Tooltip>

  return <BasicDataModuleLayout
    className='stem-module'
    icon = { <PieCircleIcon /> }
    title = { titleElement }
    subtitle = { subtitle }
    footer = { footer }
    body = { body }
  />
};

StemModule.PropTypes = {
  className: React.PropTypes.string
}

export default StemModule;
