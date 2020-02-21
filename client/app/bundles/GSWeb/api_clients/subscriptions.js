export const getStudentGrades = () =>
  $.ajax({
    url: '/gsr/api/students',
    type: 'POST',
    dataType: 'json',
    timeout: 6000
  }).then(result => result.grades);

export const deleteStudentGrade = (grade, options = {}) =>
  $.ajax({
    url: '/gsr/user/delete_grade_selection',
    data: {
      grade,
      ...options
    },
    type: 'POST',
    dataType: 'json',
    timeout: 6000
  }).then(result => result.gradeLevels);

export const addStudentGrade = (grade, options = {}) =>
  $.ajax({
    url: '/gsr/user/save_grade_selection',
    data: {
      grade,
      ...options
    },
    type: 'POST',
    dataType: 'json',
    timeout: 6000
  }).then(result => result.gradeLevels);

export const deleteSubscription = id =>
  $.ajax({
    url: `/gsr/api/subscriptions/${id}/`,
    type: 'DELETE',
    dataType: 'json',
    timeout: 6000
  });

export const addSubscription = (list, state, schoolId, language) =>
  $.ajax({
    url: `/gsr/api/subscriptions/`,
    type: 'POST',
    data: {
      list,
      state,
      schoolId,
      language
    },
    dataType: 'json',
    timeout: 6000
  });
