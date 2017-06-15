import React from 'react';
import BasicDataModuleLayout from './basic_data_module_layout';
import { PieCircleIcon } from './circle_icons';
import Tooltip from './tooltip';
import QuestionMarkTooltip from './question_mark_tooltip';

const StemModule = ({}) => {
  let title = (
    <span>
      Advanced STEM courses <QuestionMarkTooltip content="foo bar baz" />
    </span>
  );

  let footer = <Tooltip content="foo bar baz" >Sources</Tooltip>

  return <BasicDataModuleLayout
    title = 'Advanced STEM courses'
    className='stem-module'
    icon = { <PieCircleIcon /> }
    title = { title }
    subtitle = 'Donec id elit non mi porta gravida at eget metus. Morbi leo risus, porta ac consectetur ac, vestibulum at eros.'
    footer = { footer }
  />
};

StemModule.PropTypes = {
  className: React.PropTypes.string
}

export default StemModule;
