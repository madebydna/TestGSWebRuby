export const findDistrictCalendarWithNCES = (url, nces) => (
    $.ajax({
        type: 'GET',
        url: `${url}?sub_type=district&id=${nces}`,
        timeout: 6000
    })
);

//Need a proxy for this API call
export const findDistrictOverviewData = (nces) => (
    $.ajax({
        type: 'GET',
        url: `https://api.tandem.co/rest/index.php?token=greatschoolsftw&api_version=2019-06-21&type=districts&nces_id=${nces}&details=t&data_type=json`,
        timeout: 6000
    })
);