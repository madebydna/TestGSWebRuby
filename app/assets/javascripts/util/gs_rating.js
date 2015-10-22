var GS = GS || {};
GS.rating = GS.rating || (function(){
  var RATING_TO_PERFORMANCE_LEVEL = {
    1: 'below_average',
    2: 'below_average',
    3: 'below_average',
    4: 'average',
    5: 'average',
    6: 'average',
    7: 'average',
    8: 'above_average',
    9: 'above_average',
    10: 'above_average'
  };

  var getRatingPerformanceLevel = function(ratingNumber) {
    return RATING_TO_PERFORMANCE_LEVEL[ratingNumber];
  };

  return {
    getRatingPerformanceLevel: getRatingPerformanceLevel
  };
})();