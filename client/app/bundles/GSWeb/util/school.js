import React from 'react';
import { capitalize } from 'util/i18n';

const getHomesForSaleHref = (state, address) => {
  if (state && address && address.zip) {
    // let homesForSaleHref = null;
    return `https://www.zillow.com/${state}-${
        address.zip.split('-')[0]
        }?cbpartner=Great+Schools&utm_source=GreatSchools&utm_medium=referral&utm_campaign=districtbrowsemap`;
    // return homesForSaleHref;
  }
  return null;
};

const studentsPhrase = enrollment => {
  if (!enrollment) {
    return null;
  }
  return (
      <span>
      <span className="open-sans_semibold">{enrollment}</span>
        {enrollment > 1 ? ' students' : ' student'}
    </span>
  );
};

const schoolTypePhrase = (schoolType, gradeLevels) => (
    <span className="open-sans_semibold">{capitalize(schoolType)+', '+gradeLevels}</span>
);

export { getHomesForSaleHref, studentsPhrase, schoolTypePhrase }