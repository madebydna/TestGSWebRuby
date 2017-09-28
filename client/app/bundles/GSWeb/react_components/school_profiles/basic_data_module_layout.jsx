import React from 'react';


const sharingModal = function(share_content) {
  if(share_content == '' || share_content == null) {
    return;
  }
  return (
      <button>
        <a data-remodal-target="modal_info_box"
           data-content-type="info_box"
           data-content-html={share_content}
           className="gs-tipso"
           data-tipso-width="318"
           data-tipso-position="left"
           href="javascript:void(0)">
          <div className="dib">
            {t('Share')}
          </div>
        </a>
      </button>
  )
}


const BasicDataModuleLayout = ({
  id, className, icon, title, subtitle, body, footer, tabs, share_content
}) => {
  return (
    <div>
      <a className="anchor-mobile-offset" name={id}></a>
      <div id={id} className={'rating-container ' + className } data-ga-click-label={title}>
        <div className="profile-module">
          <div className="module-header">
            <div className="row">
              <div className="col-xs-12 col-md-10">
                <div className="icon">{icon}</div>
                <div className="title-container">
                  <span className="title">{title}</span>
                  <div dangerouslySetInnerHTML={{__html: subtitle}} />
                </div>
              </div>
              <div className="col-xs-12 col-md-2 show-history-button">
                <div>
                  {sharingModal(share_content)}
                </div>
              </div>
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
  share_content: React.PropTypes.string,
  icon: React.PropTypes.object,
  title: React.PropTypes.object,
  titleTooltip: React.PropTypes.object,
  subtitle: React.PropTypes.object,
  body: React.PropTypes.object,
  footer: React.PropTypes.object
}

export default BasicDataModuleLayout;
