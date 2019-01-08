import React from 'react';
import { t, capitalize } from 'util/i18n';

export const SCHOOL_DISTRICTS = 'school districts';
export const SCHOOLS = 'schools';
export const REVIEWS = 'Reviews';
export const COMMUNITY_RESOURCES = 'community_resources';
export const ACADEMICS = 'academics';
export const CALENDAR = 'calendar';

const schools = {
  key: SCHOOLS,
  label: t(SCHOOLS),
  anchor: '#schools',
  selected: true
}

const schoolDistricts = {
  key: SCHOOL_DISTRICTS,
  label: t(SCHOOL_DISTRICTS),
  anchor: '#districts',
  selected: false
}

const academics = {
  key: 'academics',
  label: capitalize(t(ACADEMICS)),
  anchor: '#Academics',
  selected: false
}

const calendar = {
  key: 'calendar',
  label: capitalize(t(CALENDAR)),
  anchor: '#calendar',
  selected: false
}

const communityResources = {
  key: 'community resources',
  label: capitalize(t(COMMUNITY_RESOURCES)),
  anchor: '#mobility',
  selected: false
}

const nearbyHomesForSale = {
  key: 'nearby homes for sale & rent',
  label: t('nearby homes for sale & rent'),
  anchor: '#homes-and-rentals',
  selected: false
}

const reviews = {
  key: 'Reviews',
  label: t(REVIEWS),
  anchor: '#reviews',
  selected: false
}

export {
  schools,
  schoolDistricts,
  academics,
  calendar,
  communityResources,
  nearbyHomesForSale,
  reviews
}