GS.guidedSearch = GS.guidedSearch || {};

$(function() {

    $('.js-guided-search-next').on('click',function(){
       var next_tab= $(this).data('next-tab');
       changeTabs(next_tab);

    });
    $('.js-guided-search-back').on('click',function(){
        var previous_tab= $(this).data('previous-tab');
        changeTabs(previous_tab);

    });

 var changeTabs=function(tab){
     $(".tab_"+tab).siblings().removeClass('active');
     $(".tab_"+tab).addClass('active');
     $("#"+tab).siblings().removeClass('active');
     $("#"+tab).addClass('active');

 }
});
