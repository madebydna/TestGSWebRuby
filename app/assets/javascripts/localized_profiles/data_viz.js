var GS = GS || {};

GS.dataViz = GS.dataViz || {};

GS.dataViz.initToggleHandlers = function() {
  var $groupComparisonContainer = $('.js-groupComparisonContainer');
  var $dataDisplayCollections = $('.js-dataDisplayCollection');

  $groupComparisonContainer.on('click', '.js-dataDisplayCollectionToggle', function () {
    var $element      = $(this);
    var title         = $element.data('title');
    var titleSelector = '.js-' + title;

    GS.util.manuallySendAnalyticsEvent($element);
    $dataDisplayCollections.addClass('dn');
    $dataDisplayCollections.filter(titleSelector).removeClass('dn');
  });

  $groupComparisonContainer.on('click', '.js-dataDisplayToggle', function() {
    var $element                = $(this);
    var title                   = $element.data('title');
    var titleSelector           = '.js-' + title;
    var collection              = $element.data('collection');
    var collectionSelector      = '.js-' + collection;
    var $dataDisplayCollection  = $dataDisplayCollections.filter(collectionSelector);

    GS.util.manuallySendAnalyticsEvent($element);
    $dataDisplayCollection.find('.js-dataDisplay').addClass('dn');
    $dataDisplayCollection.find(titleSelector).removeClass('dn');
  });
};
