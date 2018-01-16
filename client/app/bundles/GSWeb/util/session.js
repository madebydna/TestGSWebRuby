// Requires gon
// Requires jQuery
// Requires jQuery.cookie

import memoizeAjaxRequest from './memoize_ajax_request';

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