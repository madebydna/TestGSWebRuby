export const findCalendarWithNCES = (url, nces, entity) => {
  // entity is `school` or `district` per tandem api
  return $.ajax({
    type: 'GET',
    url,
    data:{
      type: 'calendar',
      sub_type: entity,
      api_version: '2019-06-21',
      event_type: 'yearly',
      id: nces,
      data_type: 'jcal'
    },
    timeout: 6000
  });
};

export const findOverviewData = (url, nces, entity) => (
    //entity can be `school` or `districts`
    $.ajax({
        type: 'GET',
        url,
        data: {
            type: entity,
            api_version: '2019-06-21',
            nces_id: nces,
            details: 't',
            data_type: 'json'
        },
        timeout: 6000
    })
);
