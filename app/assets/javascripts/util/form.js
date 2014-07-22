GS.guidedsearch = GS.guidedsearch || {};

$(function() {
    $('.js-gs-radio').on('click',function(){
        var self = $(this);
        var hidden_field = self.siblings(".js-gs-radio-value");
        var gs_radio = self.data('gs-radio');
        hidden_field.val(gs_radio);
        self.siblings().removeClass('active');
        self.addClass('active');

    });

    $('.js-gs-checkbox').on('click',function(){
        var self=$(this);
        var checkbox = self.children(".js-icon");
        var hidden_field = self.siblings(".js-gs-checkbox-value");
        var gs_checkBox= self.data('gs-checkbox');
        if (hidden_field.val()== '') {
            checkbox.removeClass('i-24-checkmark-off').addClass('i-24-checkmark-on');
            hidden_field.val(gs_checkBox);
        }else {
            checkbox.removeClass('i-24-checkmark-on').addClass('i-24-checkmark-off');
            hidden_field.val('');
        }

    });
    $('.js-gs-popover').on('click',function(){
        alert('I am here');
        var self=$(this);
        var checkbox = self.children(".js-icon");
        var hidden_field = self.siblings(".js-gs-popover-value");
        var gs_popover= self.data('gs-popover');
        if (hidden_field.val()== '') {
            checkbox.removeClass('i-24-checkmark-off').addClass('i-24-checkmark-on');
            hidden_field.val(gs_popover);
        }else {
            checkbox.removeClass('i-24-checkmark-on').addClass('i-24-checkmark-off');
            hidden_field.val('');
        }

    });
});
