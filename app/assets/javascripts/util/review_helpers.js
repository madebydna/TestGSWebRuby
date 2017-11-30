var GS = GS || {};

// Has methods for formatting cached test score data
GS.reviewHelpers = GS.reviewHelpers || (function() {
  var scrollToReviewSummary = function() {
    event.preventDefault();
    var scroll_duration = 500;
    var review_top = $(".review-summary").offset();
    $('html, body').animate({scrollTop: review_top.top}, scroll_duration);
    return false;
  };

  return {
    scrollToReviewSummary: scrollToReviewSummary
  }
})();
