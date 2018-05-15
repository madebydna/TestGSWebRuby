import React from 'react';
import PropTypes from 'prop-types';
import { t } from '../../util/i18n';

const BasicDataModuleLayout = ({
  id,
  className,
  icon,
  title,
  subtitle,
  body,
  feedback,
  footer,
  tabs,
  no_data_cta,
  sharing_modal,
  csa_badge,
  csaCallout
}) => (
  <div>
    <div
      id={id}
      className={`rating-container ${className}`}
      data-ga-click-label={title}
    >
      <a className="anchor-mobile-offset" name={id} />
      <div className="profile-module">
        <div className="module-header">
          <div className="row">
            <div
              className={sharing_modal ? 'col-xs-12 col-md-10' : 'col-xs-12'}
            >
              <div className="icon">{icon}</div>
              <div className="title-container">
                <span className="title">{title}</span>
                <div dangerouslySetInnerHTML={{ __html: subtitle }} />
                {no_data_cta}
              </div>
            </div>
            {sharing_modal && (
              <div className="col-xs-12 col-md-2 show-share-button">
                <div>{sharing_modal}</div>
              </div>
            )}
          </div>
          {csaCallout}
        </div>

        {tabs}

        {csa_badge}

        {body && <div className="panel">{body}</div>}

        <div className="module-footer">{footer}</div>
      </div>
    </div>
  </div>
);

BasicDataModuleLayout.propTypes = {
  className: PropTypes.string,
  sharing_modal: PropTypes.node,
  icon: PropTypes.object,
  title: PropTypes.object.isRequired,
  titleTooltip: PropTypes.object,
  subtitle: PropTypes.string,
  body: PropTypes.object.isRequired,
  feedback: PropTypes.object,
  footer: PropTypes.object,
  csa_badge: PropTypes.bool,
  tabs: PropTypes.element
};

export default BasicDataModuleLayout;
