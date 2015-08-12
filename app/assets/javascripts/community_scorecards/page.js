// The pattern I'm thinking is that there are a few spots on the page that
// when you click, issue the same JS call, which is just a redrawTable() call.
// redrawTable() will read the options off of the URL and page, which
// GS.CommunityScorecards.Page knows how to do) and call getSchoolData() with
// the correction options.
//
// The only different call will be seeMore(), which will do pretty much the
// same thing but also add offset based on the button's data value(s) and do
// an append of rows instead of a whole table redraw.

GS = GS || {};
GS.CommunityScorecards = GS.CommunityScorecards || {};
GS.CommunityScorecards.Page = GS.CommunityScorecards.Page || (function() {
  var tablePlacement = '#community-scorecard-table';
  var tableSelector  = tablePlacement + ' table';
  var tablePartial   = 'community_scorecards/table';
  var rowPartial     = 'community_scorecards/table_row';
  var offsetInterval = 10;

  var init = function() {
    this.options = new GS.CommunityScorecards.Options(currentPageData());

    // Sample click handler for sorting:
    //
    // $(selector).on('click', sub-selector, function () {
    //   var sortField = $(this).data('sortField');
    //   this.options.sortField = sortField;
    //   redrawTable();
    // });
  };

  var redrawTable = function() {
    var params = this.options.to_h();
    GS.CommunityScorecards.Data.request(params).success(function (data) {
      $(tablePlacement).html(GS.handlebars.partialContent(tablePartial, data));
    });
  };

  var appendToTable = function() {
    var params = this.options.to_h();
    params.offset += offsetInterval;
    GS.CommunityScorecards.Data.request(params).success(function (data) {
      $(tableSelector).append(GS.handlebars.partialContent(rowPartial, data));
      this.options.set('offset', params.offset);
    }.gs_bind(this));
  };

  var currentPageData = function() {
    // Something that reads the URL to get the current status on page load.
    // This should also deal with default settings.
    // Potential params
    // - collection id
    // -- Stored on page somewhere? Or from URL?
    // - breakdown
    // -- Value of breakdown dropdown
    // - grade
    // -- Value of grade dropdown
    // - sort data type
    // -- When data type is clicked, JS adds a class to it, which
    //    GS.CommunityScorecards.Data looks for.
    // - sort type (asc or desc)
    // -- From value of sort toggle
    // - offset
    // -- Data value on see more button
    // - lang
    // -- Handled automatically, but is from the URL
    return {
      breakdown: 'blue',
      collectionId: 15,
      dataType: 'a through g',
      grade: 6,
      offset: 0
    };
  };

  return {
    init: init
  }
})();
