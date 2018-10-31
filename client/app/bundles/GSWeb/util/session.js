// Requires gon
// Requires jQuery
// Requires jQuery.cookie

import memoizeAjaxRequest from './memoize_ajax_request';
import { get as getCookie } from 'js-cookie';

export const isSignedIn = function() {
  return $.cookie('community_www') != null || $.cookie('community_dev') != null;
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
  const numSavedSchools = getSavedSchoolsFromCookie().length;
  document.querySelectorAll('a.saved-schools-nav span:last-child').forEach(node => {
    node.innerHTML = numSavedSchools !== 0 ? `(${numSavedSchools})` :  null;
  });
  document.querySelectorAll('a.saved-schools-nav span:first-child').forEach(node => {
    if (numSavedSchools === 0 && node.classList.contains("icon-heart")){
      node.classList.remove("icon-heart");
      node.classList.add("icon-heart-outline");
    } else if (numSavedSchools !== 0 && node.classList.contains("icon-heart-outline")){
      node.classList.remove("icon-heart-outline");
      node.classList.add("icon-heart");
    }
  });
}

export const COOKIE_NAME = 'gs_saved_schools';
