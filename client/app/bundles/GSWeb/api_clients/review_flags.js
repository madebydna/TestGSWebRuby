GS = GS || {};

GS.postReviewFlag = function(uri, comment) {
  return $.post(
    uri,
    {
      review_flag: {
        comment: comment
      }
    },
    null,
    'json'
  );
}
