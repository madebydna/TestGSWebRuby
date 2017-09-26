import React from 'react';

const ContentForSharingModal = (content) => {
  return (
    <div dangerouslySetInnerHTML={{ _html:
      <div class="sharing-modal">
        <div class="sharing-row">
          <div class="sharing-icon-box">
            <span class="icon-mail"/>
          </div>
          <span class="sharing-row-text">Email</span>
        </div>
        <div class="sharing-row">
          <div class="sharing-icon-box">
            <span class="icon-facebook"/>
          </div>
          <span class="sharing-row-text">Facebook</span>
        </div>
        <div class="sharing-row">
          <div class="sharing-icon-box">
            <span class="icon-twitter"/>
          </div>
          <span class="sharing-row-text">Twitter</span>
        </div>
        <div class="sharing-row">
          <div class="sharing-icon-box">
            <span class="icon-link"/>
          </div>
          <span class="sharing-row-text">Permalink</span>
          <div>
            <input class="permalink" type="text" value="link goes here"/>
          </div>
        </div>
        <div class="sharing-row">
          <div class="sharing-icon-box">
            <span class="icon-share"/>
          </div>
          <span class="sharing-row-text">SMS</span>
        </div>
      </div>
      }} >
    </div>
  );
};

export default ContentForSharingModal;