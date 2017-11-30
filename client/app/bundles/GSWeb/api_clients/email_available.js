import $ from 'jquery';

export const isEmailAvailable = function(email) {
  // path is poorly named
  // returns a 200 if email is available, otherwise 403 if email taken
  let uri = '/gsr/validations/need_to_signin';
  let deferred = $.Deferred();

  if(email == undefined || email == '') {
    return deferred.reject().promise();
  }

  $.get(
    uri,
    {
      email: email
    },
    null,
    'json'
  ).done((result) => {
    if(result == false) {
      deferred.resolve();
    } else {
      deferred.reject();
    }
  }).fail((result) => {
    deferred.reject();
  });
;

  return deferred.promise();
}
