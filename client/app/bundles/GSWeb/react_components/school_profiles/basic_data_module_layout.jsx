import React from 'react';


const BasicDataModuleLayout = ({
  className, icon, title, subtitle, body, footer
}) => {
  return (
    <div id="CollegeReadiness" className={'rating-container ' + className }>
      <a className="anchor-mobile-offset" name="College_readiness"></a>
      <div className="rating-container__rating">

        <div className="module-header">
          <div className="icon">{icon}</div>
          <div className="title-container">
            <span className="title">{title}</span>
            <div>{subtitle}</div>
          </div>
        </div>

        { body &&
          <div className="panel">
            {body}
          </div>
        }

        <div>
          {footer}
        </div>
      </div>
    </div>
  );
};

BasicDataModuleLayout.PropTypes = {
  className: React.PropTypes.string,
  icon: React.PropTypes.object,
  title: React.PropTypes.object,
  titleTooltip: React.PropTypes.object,
  subtitle: React.PropTypes.object,
  body: React.PropTypes.object,
  footer: React.PropTypes.object
}

export default BasicDataModuleLayout;
