GS.search = GS.search || {};

$(function() {
    $('.js-gs-checkbox').on('click',function(){
        var self=$(this);
        var checkbox = self.children(".js-icon");
        var siblings = self.siblings(".js-gs-checkbox-value");
        var gs_checkBox= self.data('gs-checkbox');
        if (siblings.val()== '') {
            checkbox.removeClass('i-24-checkmark-off').addClass('i-24-checkmark-on');
            siblings.val(gs_checkBox);
        }else {
            checkbox.removeClass('i-24-checkmark-on').addClass('i-24-checkmark-off');
            siblings.val('');
        }

    });
});
