export const findDistrictCalendarWithNCES = (url, nces) => (
    $.ajax({
        type: 'GET',
        url: `${url}?type=calendar&sub_type=district&api_version=2019-06-21&event_type=yearly&id=${nces}&data_type=jcal`,
        timeout: 6000
    })
);

//Need a proxy for this API call
export const findDistrictOverviewData = (url, nces) => (
    $.ajax({
        type: 'GET',
        url: `${url}?type=districts&api_version=2019-06-21&nces_id=${nces}&details=t&data_type=json`,
        timeout: 6000
    })
);
