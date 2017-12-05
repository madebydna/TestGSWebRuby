import React from 'react';
import { t } from '../../util/i18n';

const BasicDataModuleLayout = ({
  id, className, icon, title, subtitle, body, feedback, footer, tabs, no_data_cta, sharing_modal
}) => {
  return (
    <div>
      <div id={id} className={'rating-container ' + className } data-ga-click-label={title}>
        <a className="anchor-mobile-offset" name={id}></a>
        <div className="profile-module">
          <div className="module-header">
            <div className="row">
              <div className={sharing_modal ? 'col-xs-12 col-md-10' : 'col-xs-12'}>
                <div className="icon">{icon}</div>
                <div className="title-container">
                  <span className="title">{title}</span>
                  <div dangerouslySetInnerHTML={{__html: subtitle}} />
                  { no_data_cta }
                </div>
              </div>
              { sharing_modal && 
                <div className="col-xs-12 col-md-2 show-share-button">
                  <div>{sharing_modal}</div>
                </div>
              }
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
  sharing_modal: React.PropTypes.node,
  icon: React.PropTypes.object,
  title: React.PropTypes.object,
  titleTooltip: React.PropTypes.object,
  subtitle: React.PropTypes.object,
  body: React.PropTypes.object,
  feedback: React.PropTypes.object,
  footer: React.PropTypes.object
}

export default BasicDataModuleLayout;
