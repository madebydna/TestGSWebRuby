import React from 'react';
import { t, capitalize } from 'util/i18n';

export const SCHOOL_DISTRICTS = 'districts';
export const SCHOOLS = 'schools';
export const REVIEWS = 'Reviews';
export const COMMUNITY_RESOURCES = 'community_resources';
export const ACADEMICS = 'Academics';
export const CALENDAR = 'calendar';
export const BROWSE_SCHOOLS = 'browse-schools';
export const AWARD_WINNING_SCHOOLS = 'award-winning-schools';

const browseSchools = {
  key: BROWSE_SCHOOLS,
  label: t("browse_schools"),
  anchor: '#browse-schools',
  selected: true
}

const schools = {
  key: SCHOOLS,
  label: t(SCHOOLS),
  anchor: '#schools',
  selected: true
}

const awardWinningSchools = {
  key: AWARD_WINNING_SCHOOLS,
  label: t("award_winning_schools"),
  anchor: '#award-winning-schools',
  selected: false
}

const schoolDistricts = {
  key: SCHOOL_DISTRICTS,
  label: t(SCHOOL_DISTRICTS),
  anchor: '#districts',
  selected: false
}

const academics = {
  key: 'academics',
  label: t(ACADEMICS),
  anchor: '#academics',
  selected: false
}

const calendar = {
  key: 'calendar',
  label: capitalize(t(CALENDAR)),
  anchor: '#calendar',
  selected: false
}

const communityResources = {
  key: 'mobility',
  label: capitalize(t(COMMUNITY_RESOURCES)),
  anchor: '#mobility',
  selected: false
}

const nearbyHomesForSale = {
  key: 'homes-and-rentals',
  label: t('nearby homes for sale & rent'),
  anchor: '#homes-and-rentals',
  selected: false
}

const reviews = {
  key: 'reviews',
  label: t(REVIEWS),
  anchor: '#reviews',
  selected: false
}

export {
  browseSchools,
  schools,
  awardWinningSchools,
  schoolDistricts,
  academics,
  calendar,
  communityResources,
  nearbyHomesForSale,
  reviews
}