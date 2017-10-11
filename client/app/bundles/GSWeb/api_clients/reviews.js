export function getAnswerCountsForQuestion(state, schoolId, questionId) {
  return $.get(
    '/gsr/api/reviews/count',
    {
      state: state,
      school_id: schoolId,
      review_question_id: questionId,
      fields: ['answer_value'].join(',')
    },
    null,
    'json'
  ).then((data) => data.result);
}

export function postReview(data) {
  return $.ajax({
    url: "/gsr/reviews",
    method: 'POST',
    data: data,
    dataType: 'json'
  }).then(
    (result) => result,
    (xhr) => {
      let formErrors = JSON.parse(xhr.responseText);
      if(formErrors && formErrors.reviews) {
        let reviewsErrors = formErrors.reviews[0];
        if (reviewsErrors) {
          return reviewsErrors;
        }
      }
      return {};
    }
  );
}
