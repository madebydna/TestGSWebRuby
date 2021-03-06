import React from 'react';
import PropTypes from 'prop-types';

const CircleIcon = ({icon}) => {
  let iconClass = 'icon-' + icon;
  let color = 'blue';
  return <div className={'rating-layout circle-rating--equity-' + color}>
    <span className={iconClass}></span>
  </div>
};
CircleIcon.propTypes = {
  icon: PropTypes.string
};
export default CircleIcon;


export const PieCircleIcon = () => <CircleIcon icon='pie'/>
export const MicroscopeCircleIcon = () => <CircleIcon icon='microscope'/>
export const GeneralInfoIcon = () => <CircleIcon icon='general-info'/>
