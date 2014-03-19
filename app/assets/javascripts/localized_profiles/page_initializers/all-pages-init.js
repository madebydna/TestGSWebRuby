$(function() {
    // even though this code is simple, I'd rather it be an actual module, i.e. GS.sendMeUpdates,
    // since it's easier to test
    $('.js-send-me-updates-button-header').on('click', function () {
        $('#js-send-me-updates-form-header').submit();
    });

    $('.js-send-me-updates-button-footer').on('click', function () {
        $('#js-send-me-updates-form-footer').submit();
    });

    $('.js-save-this-school-button').on('click', function () {
        $('#js-save-this-school-form').submit();
    });

    $('.js-button-link').on('click', function() {
        window.location.href = $(this).data("link-value");
    });

    $('.js_toggle_parent_sib').on('click', function(){
        $(this).parent().siblings('div').slideToggle('fast');
        if($(this).html() == 'Close'){
            $(this).html('Learn More &raquo;')
        }
        else{
            $(this).html('Close')
        }
    });
});