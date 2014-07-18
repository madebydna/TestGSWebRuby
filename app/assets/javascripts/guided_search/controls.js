GS.guidedSearch = GS.guidedSearch || {};

$(function() {
    var displayNone = 'dn';
    var active = 'active';
    var id_tab_number = '.js-tab-number';
    var id_tab_check = '.js-tab-check';

    $('.js-guided-search-next').on('click',function(){
        var hasError = false;
        $(".js-error-validation").each(function() {
            if ($(this).val() === '') {
                $(this).parent().addClass('has-error');
                $(this).siblings(".js-error-message").removeClass(displayNone);
                hasError = true;
            }else {
                $(this).parent().removeClass('has-error');
                $(this).siblings(".js-error-message").addClass(displayNone);
                hasError = false;

            }
        });
        if (hasError === true){
            return false ;
        }

        var next_tab= $(this).data('next-tab');
        $(".tab_"+next_tab).prev().find(id_tab_number).addClass(displayNone);
        $(".tab_"+next_tab).prev().find(id_tab_check).removeClass(displayNone);
        changeTabs(next_tab);
    });
    $('.js-guided-search-back').on('click',function(){
        var previous_tab= $(this).data('previous-tab');
        $(".tab_"+previous_tab).next().find(id_tab_number).removeClass(displayNone);
        $(".tab_"+previous_tab).next().find(id_tab_check).addClass(displayNone);
        $(".tab_"+previous_tab).find(id_tab_number).removeClass(displayNone);
        $(".tab_"+previous_tab).find(id_tab_check).addClass(displayNone);
        changeTabs(previous_tab);

    });
//    $('.js-guided-search-submit').on('click',function(){
//        var current_tab= $(this).data('current-tab');
//        $(".tab_"+current_tab).find(id_tab_number).addClass(displayNone);
//        $(".tab_"+current_tab).find(id_tab_check).removeClass(displayNone);
//        $(".tab_"+current_tab).removeClass(active);
//
//
//
//    });

 var changeTabs=function(tab){
     $(".tab_"+tab).siblings().removeClass(active);
     $(".tab_"+tab).addClass(active);
     $("#"+tab).siblings().removeClass(active);
     $("#"+tab).addClass(active);
 }
});
