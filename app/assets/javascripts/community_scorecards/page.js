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

  // Selectors
  var showMore           = '.js-showMore';
  var tableSort          = '.js-tableSort';
  // Partials
  var tableHeaderPartial = 'community_scorecards/table_header';
  var tablePartial       = 'community_scorecards/table';
  var rowPartial         = 'community_scorecards/table_row';
  var mobilePartial      = 'community_scorecards/mobile';
  var mobileRowPartial   = 'community_scorecards/mobile_row';
  // Defaults
  var offsetInterval     = 10;
  var shouldDraw = true;
  var pageOptions;

  var init = function() {
    initPageSelectors();
    initPageOptions();
    initReadMoreToggleHandler();
    redrawTable();

    $scorecard().on('click', '.js-drawTable', function (e) {
      if (shouldDraw) {
        shouldDraw = false;
        var $target = $(e.target);
        var isNewOptionSet = setOptions($target);

        isNewOptionSet ? redrawTable() : shouldDraw = true;
      }
    });

    $scorecard().on('click', showMore, function() {
      if (shouldDraw) {
        shouldDraw = false;
        appendToTable();
      }
    });

    $scorecard().on('click', tableSort, function (e) {
      if (shouldDraw) {
        shouldDraw = false;
        setSortTypeToggleState($(e.target));
        shouldDraw = true;
      }
    });

  };

  var setOptions = function($target) {
    var newOptionsSet = false;
    _({
      'sort-asc-or-desc': 'sortAscOrDesc',
      'sort-by':          'sortBy',
      'highlight-index':  'highlightIndex',
      'sort-breakdown':   'sortBreakdown'
    }).forEach(function(optionsKey, dataKey) {
      var dataVal = $target.data(dataKey);
      if(dataVal !== undefined) {
        if (pageOptions.set(optionsKey, dataVal)) newOptionsSet = true;
      };
    });

    return newOptionsSet
  }

  //when appropriate look into not having a hardcoded list of highlight classes. Regex?
  //https://github.com/ronen/jquery.classMatch/blob/master/jquery.classMatch.js
  var redrawTable = function() {
    pageOptions.set('offset', 0);
    var params = pageOptions.to_h();
    var tableDataRequest = GS.util.ajax.request(dataUrl, params, ajaxOptions);
    tableDataRequest
      .success(drawTableWithData)
      .error(displayFatalErrorMessage);
  };

  var drawTableWithData = function(data) {
    console.log(data);
    $tablePlacement().html(GS.handlebars.partialContent(tablePartial, data));
    $mobilePlacement().html(GS.handlebars.partialContent(mobilePartial, dataForMobile(data)));

    setSortTypeToggleState(sortToggleFor(pageOptions.get('sortAscOrDesc')));
    calculateHighlightIndex();
    var highlightIndex = pageOptions.get('highlightIndex');
    $scorecard().find('table').removeClass('highlight0 highlight1 highlight2').addClass('highlight' + highlightIndex);
    pageOptions.addValuesToURL();
    shouldDraw = true;
  };

  var displayFatalErrorMessage = function() {
    var message = GS.I18n.t('fatal_error');
    $tablePlacement().html(message);
    $mobilePlacement().html(message);
  };

  var dataForMobile = function(data) {
    _(data.school_data).forEach(schoolDataForMobile);
    return data;
  };

  var schoolDataForMobile = function(data) {
    var dataSet = pageOptions.get('sortBy')
    data.data_for_mobile = {
      value: data[dataSet]['value'],
      state_average: data[dataSet]['state_average'],
      performance_level: data[dataSet]['performance_level'],
      show_no_data_symbol: data[dataSet]['show_no_data_symbol']
    }
    return data;
  };

  var appendToTable = function() {
    var params = pageOptions.to_h();
    params.offset += offsetInterval;
    var tableDataRequest = GS.util.ajax.request(dataUrl, params, ajaxOptions);
    tableDataRequest
      .success(appendDataToTable)
      .error(displayFatalErrorMessage);
  };

  var appendDataToTable = function(data) {
    if (data.school_data) {
      var $tableBody = $scorecard().find('tbody');
      var $mobileShowMore = $scorecard().find('#js-showMoreMobile');
      _.each(data.school_data, function(school) {
        $tableBody.append(GS.handlebars.partialContent(rowPartial, school));
        $mobileShowMore.before(GS.handlebars.partialContent(mobileRowPartial, schoolDataForMobile(school)));
      });
      pageOptions.set('offset', params.offset);
      if (!data.more_results) {
        $scorecard().find(showMore).addClass('dn');
      }
    }
    shouldDraw = true;
  };

  var initPageOptions = function() {
    var pageData = {};
    _.extend(pageData, gon.community_scorecard_params);
    pageOptions = new GS.CommunityScorecards.Options(pageData);
  };

  var calculateHighlightIndex = function() {
    if (! pageOptions.get('highlightIndex')) {
      var sortBy = pageOptions.get('sortBy');
      var $header = $scorecard().find('thead').find('th[data-sort-by="' + sortBy + '"]');
      var highlightIndex = $header.data('highlightIndex');
      if (highlightIndex) {
        pageOptions.set('highlightIndex', highlightIndex);
      }
    }
  };

  var initReadMoreToggleHandler = function() {
    var $readMoreText = $('.js-readMoreText');
    $scorecard().on('click', '.js-readMoreLink', function(e) {
      $(e.target).addClass('dn').removeClass('visible-xs');
      $readMoreText.removeClass();
    });
  };

  var sortToggleFor = function(sortType) {
    return $scorecard().find(tableSort + '[data-sort-asc-or-desc="' + sortType + '"]');
  };

  var setSortTypeToggleState = function($sortToggle) {
    $scorecard().find(tableSort).addClass('sort-link');
    $sortToggle.removeClass('sort-link');
  };

  var initPageSelectors = function() {
    GS.CommunityScorecards.Page.$scorecard = $('#community-scorecard');
    GS.CommunityScorecards.Page.$tablePlacement = $('#community-scorecard-table');
    GS.CommunityScorecards.Page.$mobilePlacement = $('#community-scorecard-mobile');
  };

  var $scorecard = function() {
    return GS.CommunityScorecards.Page.$scorecard;
  };

  var $tablePlacement = function() {
    return GS.CommunityScorecards.Page.$tablePlacement;
  };

  var $mobilePlacement = function() {
    return GS.CommunityScorecards.Page.$mobilePlacement;
  };

  return {
    init: init,
    pageName: 'GS:CommunityScorecard',
  }
})();
