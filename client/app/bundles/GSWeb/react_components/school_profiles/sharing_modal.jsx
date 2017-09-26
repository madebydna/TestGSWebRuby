import React from 'react';
import ContentForSharingModal from './content_for_sharing_modal';
import { t } from '../../util/i18n';

const SharingModal = (content) => {
  return (
    <a data-remodal-target="modal_info_box"
       data-content-type="info_box"
       data-content-html={ContentForSharingModal(content)}
       className="gs-tipso"
       data-tipso-offsetX="50"
       data-tipso-offsetY="60"
       data-tipso-width="318"
       data-tipso-position="left"
       href="javascript:void(0)">
      <div class="dib">
        share
      </div>
    </a>
  );
};

SharingModal.PropTypes = {
  content: React.PropTypes.string.isRequired
};

export default SharingModal;