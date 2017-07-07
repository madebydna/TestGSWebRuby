import React from 'react';


const BasicDataModuleLayout = ({
  id, className, icon, title, subtitle, body, footer
}) => {
  return (
    <div id={id} className={'rating-container ' + className } data-ga-click-label={title}>
      <a className="anchor-mobile-offset" name={id}></a>
      <div className="rating-container__rating">

        <div className="module-header">
          <div className="icon">{icon}</div>
          <div className="title-container">
            <span className="title">{title}</span>
            <div dangerouslySetInnerHTML={{__html: subtitle}}/>
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
