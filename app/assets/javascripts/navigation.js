//$(function() {
//    var sticky = $('.sticky');
//    if (sticky.css('position') !== 'sticky') {
//        var stickyTop = sticky.offset().top;
//        $(window).on('scroll', function () {
//            $(document).scrollTop() >= stickyTop ?
//                sticky.addClass('fixed') :
//                sticky.removeClass('fixed');
//        });
//    }
//});
$(function () {
    $(window).resize(function () {
        if ($(window).width() > 767) {
            $.sidr('close', 'sidr-main');
        }
    });
    var source_sidr = '#navigation';
    if ($("#navigation2").length > 0){
        source_sidr = '#navigation2, #navigation';
    }

    $('#responsive-menu-button').sidr({
        name: 'sidr-main',
        source: source_sidr
    });

//        var sticky = $('.sticky');
//        var stickyTop = $('.sticky').offset().top;
//        var stickyTopp = $('.sticky').position().top;
//        console.log("stickyTop", stickyTop);
//        console.log("stickyTopp", stickyTopp);

    $('#navigation2').affix({
        offset: {
            top: 135
        }
    });


});