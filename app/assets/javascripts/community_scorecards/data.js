GS = GS || {};
GS.CommunityScorecards = GS.CommunityScorecards || {};
GS.CommunityScorecards.Data = GS.CommunityScorecards.Data || (function() {
  var dataUrl = '/gsr/ajax/community-scorecard/get-school-data';

  var request = function(params) {
    return $.ajax({
      type: 'GET',
      url: preserveLanguage(dataUrl),
      data: params,
      dataType: 'json',
      async: true
    });
    // server needs to tell view when to hide see more button so maybe the
    // response looks like this:
    // {
    //   hasMoreResults: true,
    //   results: [
    //     // results here
    //   ]
    // }
  };


  var preserveLanguage = function(url) {
    var current_url = GS.uri.Uri.getHref();
    // TODO Ask Omega about if we're doing this or through gon
    return GS.uri.Uri.copyParam('lang', current_url, dataUrl);
  };

  return {
    request: request
  };
})();
