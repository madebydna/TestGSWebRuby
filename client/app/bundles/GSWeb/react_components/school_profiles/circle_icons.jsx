import React from 'react';

const CircleIcon = ({icon}) => {
  let iconClass = 'icon-' + icon;
  let color = 'blue';
  return <div className={'rating-layout circle-rating--equity-' + color}>
    <span className={iconClass}></span>
  </div>
};
CircleIcon.PropTypes = {
  icon: React.PropTypes.string
};
export default CircleIcon;


export const PieCircleIcon = () => <CircleIcon icon='pie'/>
export const MicroscopeCircleIcon = () => <CircleIcon icon='microscope'/>
