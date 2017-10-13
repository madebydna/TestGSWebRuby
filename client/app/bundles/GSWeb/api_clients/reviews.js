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
    ({responseJSON = {}} = {}) => responseJSON.errors
  );
}
