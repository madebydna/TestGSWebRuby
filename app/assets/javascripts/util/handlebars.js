GS = GS || {};

GS.handlebars = GS.handlebars || (function() {
  var partialSelector = '.js-gsHandlebarPartial';

  // Register all included templates as partials that can be used with the
  // {{> partialName}} syntax.
  // The partialName will be the same as a rails partial render, e.g.
  // app/views/handlebars/community_scorecards/_table.html.erb is rendered
  // with {{> community_scorecards/table}}.
  var registerPartials = function() {
    $(partialSelector).each(function () {
      Handlebars.registerPartial(this.id.replace('-','/'), $(this).html());
    });
  };

  var partialContent = function(partial, context) {
    return Handlebars.compile('{{>' + partial + '}}')(context);
  };

  var registerHelpers = function() {
    Handlebars.registerHelper('t', function(key, options) {
      return GS.I18n.t('handlebars.' + options.hash.scope + '.' + key);
    });
  };

  return {
    partialContent: partialContent,
    registerPartials: registerPartials,
    registerHelpers: registerHelpers,
  };
})();

