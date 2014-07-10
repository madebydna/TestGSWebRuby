GS.guidedSearch = GS.guidedSearch || {};

$(function() {

    $('.js-guided-search-next').on('click',function(){
       var next_tab= $(this).data('next-tab');
       changeTabs(next_tab);
        $(".tab_"+next_tab).prev().find('.js-tab-number').addClass('dn');
        $(".tab_"+next_tab).prev().find('.js-tab-check').removeClass('dn');
    });
    $('.js-guided-search-back').on('click',function(){
        var previous_tab= $(this).data('previous-tab');
        console.log( $(".tab_"+previous_tab).next());
        $(".tab_"+previous_tab).next().find('.js-tab-number').removeClass('dn');
        $(".tab_"+previous_tab).next().find('.js-tab-check').addClass('dn');
        $(".tab_"+previous_tab).find('.js-tab-number').removeClass('dn');
        $(".tab_"+previous_tab).find('.js-tab-check').addClass('dn');

        changeTabs(previous_tab);

    });
    $('.js-guided-search-submit').on('click',function(){
//        $(this).find('.js-tab-number').addClass('dn');
//        $(this).find('.js-tab-check').removeClass('dn');


    });

 var changeTabs=function(tab){
     $(".tab_"+tab).siblings().removeClass('active');
     $(".tab_"+tab).addClass('active');
     $("#"+tab).siblings().removeClass('active');
     $("#"+tab).addClass('active');
//     $(".tab_"+tab).prevAll().each(function(){
//         $(this).find('.js-tab-number').addClass('dn');
//         $(this).find('.js-tab-check').removeClass('dn');
//     })
 }
});
