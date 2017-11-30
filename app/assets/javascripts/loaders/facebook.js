$.getScript('//connect.facebook.net/en_US/sdk.js', function(){
  var appId = gon.facebook_app_id;
  FB.init({
    appId: appId,
    version    : 'v2.2',
    status     : true, // check login status
    cookie     : true, // enable cookies to allow the server to access the session
    xfbml      : true  // parse XFBML
  });
  GS.facebook.init();
});