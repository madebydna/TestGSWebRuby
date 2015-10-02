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
  var $scorecard;
  var $tablePlacement;
  var $mobilePlacement;
  // Partials
  var tableHeaderPartial = 'community_scorecards/table_header';
  var tablePartial       = 'community_scorecards/table';
  var rowPartial         = 'community_scorecards/table_row';
  var mobilePartial      = 'community_scorecards/mobile';
  var mobileRowPartial   = 'community_scorecards/mobile_row';
  // Defaults
  var offsetInterval     = 10;
  var pageOptions;

  var init = function() {
    GS.CommunityScorecards.Page.shouldDraw = true;
    initPageSelectors();
    initPageOptions();
    initReadMoreToggleHandler();
    redrawTable();

    $scorecard.on('click', '.js-drawTable', function (e) {
      if (GS.CommunityScorecards.Page.shouldDraw) {
        GS.CommunityScorecards.Page.shouldDraw = false;
        var $target = $(e.target);
        var isNewOptionSet = setOptions($target);

        isNewOptionSet ? redrawTable() : GS.CommunityScorecards.Page.shouldDraw = true;
      }
    });

    $scorecard.on('click', showMore, function() {
      if (GS.CommunityScorecards.Page.shouldDraw) {
        GS.CommunityScorecards.Page.shouldDraw = false;
        appendToTable();
      }
    });

    $scorecard.on('click', tableSort, function (e) {
      if (GS.CommunityScorecards.Page.shouldDraw) {
        GS.CommunityScorecards.Page.shouldDraw = false;
        setSortTypeToggleState($(e.target));
        GS.CommunityScorecards.Page.shouldDraw = true;
      }
    });

  };

  var setOptions = function($target) {
    var newOptionsSet = false;
    _({
      'sort-asc-or-desc': 'sortAscOrDesc',
      'sort-by':          'sortBy',
      'highlight-index':  'highlightIndex',
      'sort-breakdown':   'sortBreakdown',
      'grade-level':      'gradeLevel'
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
    if (pageOptions.get('sortBy')) {
      pageOptions.set('offset', 0);
      var params = pageOptions.to_h();
      var tableDataRequest = GS.util.ajax.request(dataUrl, params, ajaxOptions);
      tableDataRequest
        .success(drawTableWithData)
        .error(displayFatalErrorMessage);
    }
    else {
      GS.CommunityScorecards.Page.shouldDraw = true;
    }
  };

  var drawTableWithData = function(data) {
    try {
      $tablePlacement.html(GS.handlebars.partialContent(tablePartial, data));
      $mobilePlacement.html(GS.handlebars.partialContent(mobilePartial, dataForMobile(data)));

      setSortTypeToggleState(sortToggleFor(pageOptions.get('sortAscOrDesc')));
      calculateHighlightIndex();
      var highlightIndex = pageOptions.get('highlightIndex');
      $scorecard.find('table').removeClass('highlight0 highlight1 highlight2 highlight3 highlight4').addClass('highlight' + highlightIndex);
      activateTooltips();
      // Please keep this last. The last thing we should do is change the URL.
      pageOptions.addValuesToURL();
      GS.CommunityScorecards.Page.shouldDraw = true;
    } catch(e) {
      displayFatalErrorMessage();
    }
  };

  var displayFatalErrorMessage = function() {
    var message = GS.I18n.t('fatal_error');
    $tablePlacement.html(message);
    $mobilePlacement.html(message);
  };

  var dataForMobile = function(data) {
    _(data.school_data).forEach(schoolDataForMobile);
    return data;
  };

  var schoolDataForMobile = function(data) {
    var dataSet = pageOptions.get('sortBy');
    if (typeof data[dataSet] === 'object') {
      data.data_for_mobile = data[dataSet];
    }
    return data;
  };

  var appendToTable = function() {
    var params = pageOptions.to_h();
    params.offset += offsetInterval;
    pageOptions.set('offset', params.offset);

    var tableDataRequest = GS.util.ajax.request(dataUrl, params, ajaxOptions);
    tableDataRequest
      .success(appendDataToTable)
      .error(displayFatalErrorMessage);
  };

  var appendDataToTable = function(data) {
    try {
      if (data.school_data) {
        var $tableBody = $scorecard.find('tbody');
        var $mobileShowMore = $scorecard.find('#js-showMoreMobile');
        _.each(data.school_data, function(school) {
          $tableBody.append(GS.handlebars.partialContent(rowPartial, school));
          $mobileShowMore.before(GS.handlebars.partialContent(mobileRowPartial, schoolDataForMobile(school)));
        });
        if (!data.more_results) {
          $scorecard.find(showMore).addClass('dn');
        }
        activateTooltips();
      }
      GS.CommunityScorecards.Page.shouldDraw = true;
    } catch(e) {
      displayFatalErrorMessage();
    }
  };

  var initPageOptions = function() {
    var pageData = {};
    _.extend(pageData, gon.community_scorecard_params);
    pageOptions = new GS.CommunityScorecards.Options(pageData);
  };

  var calculateHighlightIndex = function() {
    if (! pageOptions.get('highlightIndex')) {
      var sortBy = pageOptions.get('sortBy');
      var $header = $scorecard.find('thead').find('th[data-sort-by="' + sortBy + '"]');
      var highlightIndex = $header.data('highlightIndex');
      if (highlightIndex) {
        pageOptions.set('highlightIndex', highlightIndex);
      }
    }
  };

  var initReadMoreToggleHandler = function() {
    var $readMoreText = $('.js-readMoreText');
    $scorecard.on('click', '.js-readMoreLink', function(e) {
      $(e.target).addClass('dn').removeClass('visible-xs');
      $readMoreText.removeClass();
    });
  };

  var sortToggleFor = function(sortType) {
    return $scorecard.find(tableSort + '[data-sort-asc-or-desc="' + sortType + '"]');
  };

  var setSortTypeToggleState = function($sortToggle) {
    $scorecard.find(tableSort).addClass('sort-link');
    $sortToggle.removeClass('sort-link');
  };

  var initPageSelectors = function() {
    $scorecard = $('#community-spotlight');
    $tablePlacement = $('#community-scorecard-table');
    $mobilePlacement = $('#community-scorecard-mobile');
  };

  var activateTooltips = function() {
    $('.gs-tooltip').tooltip();
  };

  return {
    init: init,
    pageName: 'GS:CommunityScorecard',
  }
})();
