// Requires gon
import memoizeAjaxRequest from 'util/memoize_ajax_request';

export const getCurrentSession = function() {
  var uri = gon.links.session;
  if (uri === undefined) {
    throw new Error('uri is undefined in getCurrentSession');
  }
  return memoizeAjaxRequest(
    'session',
    function() {
      return $.get(uri, null, 'json')
    }
  ).then(
    ({user} = {}) => user,
    ({responseJSON} = {}) => responseJSON.errors // array of error strings
  );
};


