export const isUserEmailVerified= function(email) {
  // path is poorly named
  // returns a 200 if email is available, otherwise 403 if email taken
  let uri = '/gsr/user/user_email_verified';
  let deferred = $.Deferred();

  console.log("isUserEmailVerified");
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
    console.log("isUserEmailVerified aa: "+result);
    if(result == 'true') {
      console.log("isUserEmailVerified result aa: "+JSON.stringify(result));
      deferred.resolve();
    } else {
      console.log("isUserEmailVerified result ab: "+JSON.stringify(result));
      deferred.reject();
    }
  }).fail((result) => {
    console.log("isUserEmailVerified ab: "+JSON.stringify(result));
    deferred.reject();
  });
;

  return deferred.promise();
}