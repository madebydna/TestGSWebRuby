GS.guidedSearch = GS.guidedSearch || {};

$(function() {

    $('.js-guided-search-next').on('click',function(){
       var next_tab= $(this).data('next-tab');
        $(".tab_"+next_tab ).trigger( "click" );
    });
    $('.js-guided-search-back').on('click',function(){
        var previous_tab= $(this).data('previous-tab');
        $(".tab_"+previous_tab ).trigger( "click" );
    });


});
