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
  var dataUrl = '/gsr/ajax/community-scorecard/get-school-data';
  var ajaxOptions = { preserveLanguage: true };

  var scorecard      = '.js-communityScorecard';
  var tablePlacement = '#community-scorecard-table';
  var tableBody      = tablePlacement + ' table tbody';
  var tableHeaderPartial = 'community_scorecards/table_header';
  var tablePartial   = 'community_scorecards/table';
  var rowPartial     = 'community_scorecards/table_row';
  var showMore       = '.js-showMore';
  var offsetInterval = 10;

  var init = function() {
    this.options = new GS.CommunityScorecards.Options(currentPageData());
    initReadMoreToggleHandler();
    drawTableHeader();
    redrawTable();

    $(scorecard).on('click', '.selectpicker > li > a > span', function (e) {
      var sortField = $(e.target).text();
      GS.CommunityScorecards.Page.options.set('sortBreakdown', sortField);
      redrawTable();
    });

    $(scorecard).on('click', '.js-drawTable', function (e) {
      _({ 'sort-asc-or-desc': 'sortAscOrDesc', 'sort-by': 'sortBy', 'highlight-index': 'highlightIndex' }).forEach(function(optionsKey, dataKey) {
        var dataVal = $(e.target).data(dataKey);
        if(dataVal !== undefined) {
          GS.CommunityScorecards.Page.options.set(optionsKey, dataVal)
        };
      });

      redrawTable();
    });

    $(scorecard).on('click', showMore, appendToTable);
  };

  var drawTableHeader = function() {
    $(tablePlacement).before(GS.handlebars.partialContent(tableHeaderPartial));
  }

  var redrawTable = function() {
    var params = GS.CommunityScorecards.Page.options.to_h();
    GS.util.ajax.request(dataUrl, params, ajaxOptions).success(function (data) {
      $(tablePlacement).html(GS.handlebars.partialContent(tablePartial, data));
      var highlightIndex = GS.CommunityScorecards.Page.options.get('highlightIndex');
      $('.js-CommunityScorecardTable').removeClass('highlight0 highlight1 highlight2').addClass('highlight' + highlightIndex);
    });
  };

  var appendToTable = function() {
    var params = GS.CommunityScorecards.Page.options.to_h();
    params.offset += offsetInterval;
    GS.util.ajax.request(dataUrl, params, ajaxOptions).success(function (data) {
      if (data.school_data) {
        _.each(data.school_data, function(school) {
          $(tableBody).append(GS.handlebars.partialContent(rowPartial, school));
        });
        GS.CommunityScorecards.Page.options.set('offset', params.offset);
        if (!data.more_results) {
          $(showMore).addClass('dn');
        }
      }
    });
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
      collectionId: 15,
      gradeLevel: 'h',
      sortBy: 'graduation_rate',
      sortBreakdown: 'white',
      sortAscOrDesc: 'desc',
      offset: 0,
      data_sets: gon.scorecard_data_types
    };
  };

  var initReadMoreToggleHandler = function() {
    var readMoreText = '.js-readMoreText';
    $(scorecard).on('click', '.js-readMoreLink', function(e) {
      $(e.target).addClass('dn');
      $(e.target).removeClass('visible-xs');
      $('.js-readMoreText').removeClass('hidden-xs');
    });
  };

  return {
    init: init,
    pageName: 'GS:CommunityScorecard',
  }
})();
