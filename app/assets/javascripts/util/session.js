GS = GS || {};
GS.session = GS.session || (function(gon) {

  var isSignedIn = function() {
    return $.cookie('community_www') != null || $.cookie('community_dev') != null;
  };

  // returns a jQuery promise
  var getCurrentSession = function() {
    var uri = gon.links.session;
    if (uri === undefined) {
      throw new Error('uri is undefined in getCurrentSession');
    }
    return GS.util.memoizeAjaxRequest(
      'session',
      function() {
        return $.get(uri, null, 'json')
      }
    );
  };

  var getSchoolUserDigest = function() {
    var uri = gon.links.school_user_digest;
    var schoolData =  {
        state: gon.school.state,
        school_id: gon.school.id
    };
    var memoizeId = 'gs_school_user_digest' + schoolData.state + schoolData.school_id;

    if (uri === undefined) {
      throw new Error('uri is undefined in getCurrentSession');
    }
    
    return GS.util.memoizeAjaxRequest(
      memoizeId,
      function() {
        return $.get(uri, schoolData, 'json')
      }
    );
  };

  return {
    isSignedIn: isSignedIn,
    getCurrentSession: getCurrentSession,
    getSchoolUserDigest: getSchoolUserDigest
  };

})(gon);
