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

  var scorecard          = '.js-communityScorecard';
  var tablePlacement     = '#community-scorecard-table';
  var table              = tablePlacement + ' table';
  var tableHead          = table + ' thead';
  var tableBody          = table + ' tbody';
  var tableHeaderPartial = 'community_scorecards/table_header';
  var tablePartial       = 'community_scorecards/table';
  var rowPartial         = 'community_scorecards/table_row';
  var mobilePlacement    = '#community-scorecard-mobile';
  var mobilePartial      = 'community_scorecards/mobile';
  var mobileRowPartial   = 'community_scorecards/mobile_row';
  var showMoreMobile     = '#js-showMoreMobile'
  var showMore           = '.js-showMore';
  var tableSort          = '.js-tableSort';
  var offsetInterval     = 10;

  var init = function() {
    initPageOptions();
    initReadMoreToggleHandler();
    redrawTable();

    $(scorecard).on('click', '.js-drawTable', function (e) {
      var $target = $(e.target);
      var shouldRedrawTable = false;
      _({
        'sort-asc-or-desc': 'sortAscOrDesc',
        'sort-by':          'sortBy',
        'highlight-index':  'highlightIndex',
        'sort-breakdown':    'sortBreakdown'
      }).forEach(function(optionsKey, dataKey) {
        var dataVal = $target.data(dataKey);
        if(dataVal !== undefined) {
          var isValueSet = GS.CommunityScorecards.Page.options.set(optionsKey, dataVal)
          if (isValueSet) shouldRedrawTable = true;
        };
      });

      if (shouldRedrawTable) redrawTable();
    });

    $(scorecard).on('click', showMore, appendToTable);

    $(scorecard).on('click', tableSort, function (e) {
      setSortTypeToggleState($(e.target));
    });

  };

  //when appropriate look into not having a hardcoded list of highlight classes. Regex?
  //https://github.com/ronen/jquery.classMatch/blob/master/jquery.classMatch.js
  var redrawTable = function() {
    GS.CommunityScorecards.Page.options.set('offset', 0);
    var params = GS.CommunityScorecards.Page.options.to_h();
    GS.util.ajax.request(dataUrl, params, ajaxOptions).success(function (data) {
      $(tablePlacement).html(GS.handlebars.partialContent(tablePartial, data));
      $(mobilePlacement).html(GS.handlebars.partialContent(mobilePartial, dataForMobile(data)));

      setSortTypeToggleState(sortToggleFor(GS.CommunityScorecards.Page.options.get('sortAscOrDesc')));
      calculateHighlightIndex();
      var highlightIndex = GS.CommunityScorecards.Page.options.get('highlightIndex');
      $(table).removeClass('highlight0 highlight1 highlight2').addClass('highlight' + highlightIndex);
    });
  };

  var dataForMobile = function(data) {
    _(data.school_data).forEach(schoolDataForMobile);
    return data;
  };

  var schoolDataForMobile = function(data) {
    var dataSet = GS.CommunityScorecards.Page.options.get('sortBy')
    data.data_for_mobile = {
      value: data[dataSet]['value'],
      state_average: data[dataSet]['state_average'],
      performance_level: data[dataSet]['performance_level'],
      show_no_data_symbol: data[dataSet]['show_no_data_symbol']
    }
    return data;
  };

  var appendToTable = function() {
    var params = GS.CommunityScorecards.Page.options.to_h();
    params.offset += offsetInterval;
    GS.util.ajax.request(dataUrl, params, ajaxOptions).success(function (data) {
      if (data.school_data) {
        _.each(data.school_data, function(school) {
          $(tableBody).append(GS.handlebars.partialContent(rowPartial, school));
          $(showMoreMobile).before(GS.handlebars.partialContent(mobileRowPartial, schoolDataForMobile(school)));
        });
        GS.CommunityScorecards.Page.options.set('offset', params.offset);
        if (!data.more_results) {
          $(showMore).addClass('dn');
        }
      }
    });
  };

  var initPageOptions = function() {
    pageData = {};
    _.extend(pageData, gon.community_scorecard_params);
    GS.CommunityScorecards.Page.options = new GS.CommunityScorecards.Options(pageData);
  };

  var calculateHighlightIndex = function() {
    if (! GS.CommunityScorecards.Page.options.get('highlightIndex')) {
      var sortBy = GS.CommunityScorecards.Page.options.get('sortBy');
      var $header = $($(tableHead).find('th[data-sort-by="' + sortBy + '"]'));
      var highlightIndex = $header.data('highlightIndex');
      if (highlightIndex) {
        GS.CommunityScorecards.Page.options.set('highlightIndex', highlightIndex);
      }
    }
  };

  var initReadMoreToggleHandler = function() {
    var readMoreText = '.js-readMoreText';
    $(scorecard).on('click', '.js-readMoreLink', function(e) {
      $(e.target).addClass('dn');
      $(e.target).removeClass('visible-xs');
      $('.js-readMoreText').removeClass('hidden-xs');
    });
  };

  var sortToggleFor = function(sortType) {
    return $(tableSort + '[data-sort-asc-or-desc="' + sortType + '"]');
  };

  var setSortTypeToggleState = function($sortToggle) {
    $(tableSort).addClass('sort-link');
    $sortToggle.removeClass('sort-link');
  };

  return {
    init: init,
    pageName: 'GS:CommunityScorecard',
  }
})();
