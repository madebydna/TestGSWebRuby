import React from 'react';
import PropTypes from 'prop-types';
import { t } from '../../util/i18n';

const SharingModal = ({content}) => {
  return (
    <a data-remodal-target="modal_info_box"
      data-content-type="info_box"
      data-content-html={content}
      className="share-link gs-tipso"
      data-tipso-width="318"
      data-tipso-position="left"
      href="javascript:void(0)">
      <span className="icon-share"></span>&nbsp;
      {t('Share')}
    </a>
  );
};

SharingModal.PropTypes = {
  content: PropTypes.string.isRequired
}

export default SharingModal;
