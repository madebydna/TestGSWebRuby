$(document).ready(function () {
    $('.js-search-list-view').on("click", function () {
        $('#js-map-canvas').hide('fast');
        $(this).children('span').addClass('i-24-orange-star').removeClass('i-24-grey-star');
        $(this).siblings('.js-search-map-view').children('span').addClass('i-24-grey-star').removeClass('i-24-orange-star');
    });
    $('.js-search-map-view').on("click", function () {
        $('#js-map-canvas').show('slow');
        $(this).children('span').addClass('i-24-orange-star').removeClass('i-24-grey-star');
        $(this).siblings('.js-search-list-view').children('span').addClass('i-24-grey-star').removeClass('i-24-orange-star');
    });
});
