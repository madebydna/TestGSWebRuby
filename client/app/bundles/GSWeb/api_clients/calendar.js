export const findDistrictCalendarWithNCES = (url, nces) => (
    $.ajax({
        type: 'GET',
        url: `${url}?sub_type=district&id=${nces}`
    })
);