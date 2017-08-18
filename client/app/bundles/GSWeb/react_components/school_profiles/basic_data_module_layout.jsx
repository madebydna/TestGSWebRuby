import React from 'react';


const BasicDataModuleLayout = ({
  id, className, icon, title, subtitle, body, footer, tabs
}) => {
  return (
    <div>
      <a className="anchor-mobile-offset" name={id}></a>
      <div id={id} className={'rating-container ' + className } data-ga-click-label={title}>
        <div className="rating-container__rating">
          <div className="module-header">
            <div className="icon">{icon}</div>
            <div className="title-container">
              <span className="title">{title}</span>
              <div dangerouslySetInnerHTML={{__html: subtitle}}/>
            </div>
          </div>

          { tabs }

          { body &&
            <div className="panel">
              {body}
            </div>
          }

          <div className="module-footer">
            {footer}
          </div>
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
