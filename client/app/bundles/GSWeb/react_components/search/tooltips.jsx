import React from 'react';
import ModalTooltip from 'react_components/modal_tooltip';
import { levelCodeLong } from 'util/school';
import { t } from 'util/i18n';

const renderAssignedTooltip = (lc) => {
  let school_level = t(levelCodeLong(lc));
  const content = (
    <div
  dangerouslySetInnerHTML={{
    __html: t('assigned_description_html', { parameters: { school_level } })
  }}
  />
  );
  return (
    <ModalTooltip content={content}>
    <span className="info-circle icon-info" />
    </ModalTooltip>
  );
};

export { renderAssignedTooltip }