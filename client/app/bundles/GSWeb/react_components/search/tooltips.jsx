import React from 'react';
import ModalTooltip from 'react_components/modal_tooltip';
import { levelCodeLong } from 'util/school';
import { t } from 'util/i18n';

const renderAssignedTooltip = (lc) => {
  let school_level = lc.split(',').filter(s => s !== 'p').map(levelcode => t(levelCodeLong(levelcode)))

  if (school_level.length == 2){
    school_level = school_level.join(` ${t('and')} `)
  } else if (school_level.length > 2){
    school_level = school_level.slice(0, school_level.length - 2).join(` ${t('and')} `).concat(school_level[school_level.length - 1])
  }

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