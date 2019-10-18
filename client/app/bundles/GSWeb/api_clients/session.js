// Requires gon
import memoizeAjaxRequest from 'util/memoize_ajax_request';

export const getCurrentSession = function(options) {
  const uri = '/gsr/api/session';
  if (uri === undefined) {
    throw new Error('uri is undefined in getCurrentSession');
  }
  return memoizeAjaxRequest('session', () => $.get(uri, options, 'json')).then(
    ({ user } = {}) => user,
    ({ responseJSON = {} } = {}) => responseJSON.errors // array of error strings
  );
};

export const changePassword = password =>
  $.ajax({
    url: '/account/password/',
    data: {
      new_password: password,
      confirm_password: password
    },
    type: 'POST',
    dataType: 'json',
    timeout: 6000
  });
