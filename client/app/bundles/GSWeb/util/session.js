// Requires gon
// Requires jQuery
// Requires jQuery.cookie

import memoizeAjaxRequest from './memoize_ajax_request';
import { get as getCookie } from 'js-cookie';

export const isSignedIn = function() {
  return getCookie('community_www') != null || getCookie('community_dev') != null;
};

export const getSchoolUserDigest = function() {
  var uri = gon.links.school_user_digest;
  var schoolData =  {
      state: gon.school.state,
      school_id: gon.school.id
  };
  var memoizeId = 'gs_school_user_digest' + schoolData.state + schoolData.school_id;

  if (uri === undefined) {
    throw new Error('uri is undefined in getCurrentSession');
  }
  
  return memoizeAjaxRequest(
    memoizeId,
    function() {
      return $.get(uri, schoolData, 'json')
    }
  );
};

export const getSavedSchoolsFromCookie = () => {
  const savedSchoolsCookie = getCookie(COOKIE_NAME);
  return savedSchoolsCookie ? JSON.parse(savedSchoolsCookie) : [];
}

export const updateNavbarHeart = () => {
  document.querySelectorAll('a.saved-schools-nav span:last-child').forEach(node => node.innerHTML = `(${getSavedSchoolsFromCookie().length})`);
}

export const COOKIE_NAME = 'gs_saved_schools';
