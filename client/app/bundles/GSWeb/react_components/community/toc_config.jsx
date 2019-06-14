import { t, capitalize } from 'util/i18n';

export const SCHOOL_DISTRICTS = 'districts';
export const SCHOOLS = 'schools';
export const REVIEWS = 'reviews';
export const COMMUNITY_RESOURCES = 'community_resources';
export const ACADEMICS = 'academics';
export const CALENDAR = 'calendar';
export const STUDENTS = 'students'
export const BROWSE_SCHOOLS = 'browse-schools';
export const AWARD_WINNING_SCHOOLS = 'award-winning-schools';

export const browseSchoolsTocItem = {
  key: BROWSE_SCHOOLS,
  label: t(BROWSE_SCHOOLS),
  anchor: '#browse-schools',
  selected: true
}

export const schoolsTocItem = {
  key: SCHOOLS,
  label: t(SCHOOLS),
  anchor: '#schools',
  selected: true
}

export const awardWinningSchoolsTocItem = {
  key: AWARD_WINNING_SCHOOLS,
  label: t(AWARD_WINNING_SCHOOLS),
  anchor: '#award-winning-schools',
  selected: false
}

export const schoolDistrictsTocItem = {
  key: SCHOOL_DISTRICTS,
  label: t(SCHOOL_DISTRICTS),
  anchor: '#districts',
  selected: false
}

export const academicsTocItem = {
  key: ACADEMICS,
  label: t(ACADEMICS),
  anchor: '#academics',
  selected: false
}

export const studentsTocItem = {
  key: STUDENTS,
  label: capitalize(t(STUDENTS)),
  anchor: '#students',
  selected: false
}

export const calendarTocItem = {
  key: CALENDAR,
  label: capitalize(t(CALENDAR)),
  anchor: '#calendar',
  selected: false
}

export const communityResourcesTocItem = {
  key: 'mobility',
  label: capitalize(t(COMMUNITY_RESOURCES)),
  anchor: '#mobility',
  selected: false
}

export const nearbyHomesForSaleTocItem = {
  key: 'homes-and-rentals',
  label: t('nearby homes for sale & rent'),
  anchor: '#homes-and-rentals',
  selected: false
}

export const reviewsTocItem = {
  key: REVIEWS,
  label: capitalize(t(REVIEWS)),
  anchor: '#reviews',
  selected: false
}