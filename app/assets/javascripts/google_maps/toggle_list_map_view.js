$(document).ready(function () {
    $('.js-search-list-view').on("click", function () {
        $('#js-map-canvas').hide('fast');
        $(this).children('span').addClass('i-16-blue-list-view').removeClass('i-16-grey-list-view');
        $(this).siblings('.js-search-map-view').children('span').addClass('i-16-grey-map-view').removeClass('i-16-blue-map-view');
    });
    $('.js-search-map-view').on("click", function () {
        $('#js-map-canvas').show('slow');
        $(this).children('span').addClass('i-16-blue-map-view').removeClass('i-16-grey-map-view');
        $(this).siblings('.js-search-list-view').children('span').addClass('i-16-grey-list-view').removeClass('i-16-blue-list-view');
});
});
