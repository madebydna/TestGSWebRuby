import React from 'react';
import { t, capitalize } from 'util/i18n';

const getHomesForSaleHref = (state, address) => {
  if (state && address && address.zip) {
    // let homesForSaleHref = null;
    return `https://www.zillow.com/${state}-${
      address.zip.split('-')[0]
    }?cbpartner=Great+Schools&utm_source=GreatSchools&utm_medium=referral&utm_campaign=schoolsearch`;
    // return homesForSaleHref;
  }
  return null;
};

const studentsPhrase = enrollment => {
  if (!enrollment) {
    return null;
  }
  return (
    <span key="enrollment">
      <span className="open-sans_semibold">{enrollment}</span>
      {` ${enrollment > 1 ? t('students') : t('student')}`}
    </span>
  );
};

const levelCodeLong = (lc) => {
  if (lc == 'e') return 'Elementary';
  if (lc == 'm') return 'Middle';
  if (lc == 'h') return 'High';
  if (lc == 'p') return 'PreK';
}

const clarifySchoolType = schoolType => {
  const clarifiedSchoolType = {
    public: 'Public district',
    charter: 'Public charter'
  }[schoolType.toLowerCase()];
  return t(`school_types.${clarifiedSchoolType || schoolType}`);
};

const schoolTypePhrase = (schoolType, gradeLevels) => (
  <span key="school-type" className="open-sans_semibold">
    {`${capitalize(clarifySchoolType(schoolType))}, ${gradeLevels}`}
  </span>
);

export {
  getHomesForSaleHref,
  studentsPhrase,
  schoolTypePhrase,
  clarifySchoolType,
  levelCodeLong
};
