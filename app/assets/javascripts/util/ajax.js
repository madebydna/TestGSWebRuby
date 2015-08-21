GS.util = GS.util || {};

GS.util.ajax = {
  request: function(url, params, options) {
    if (options.preserveLanguage) {
      url = GS.I18n.preserveLanguageParam(url);
    }
    var type = options.type || 'GET';
    var dataType = options.dataType || 'json';
    var async = options.async || true;

    return $.ajax({
      type: type,
      url: url,
      data: params,
      dataType: dataType,
      async: async
    });
  }
};
