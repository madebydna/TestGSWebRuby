GS.guidedsearch = GS.guidedsearch || {};

$(function() {
    $('.js-gs-radio').on('click',function(){
        var self = $(this);
        var hidden_field = self.parent().siblings(".js-gs-radio-value");
        var gs_radio = self.data('gs-radio');
        hidden_field.val(gs_radio);
        self.siblings().removeClass('active');
        self.addClass('active');

    });

    $("body").on('click','.js-pull-down',function(){

        var self=$(this);
        var gs_pull_down = self.data('pull-down-content');
        var pull_down_layer = $(gs_pull_down);
        var pull_down_button = pull_down_layer.siblings('.js-pull-down');
        pull_down_layer.slideToggle();
        var is_pull_down_selected =false;
        pull_down_layer.find('.js-gs-checkbox-value').each(function(){
            if ($(this).val() != ''){
                 is_pull_down_selected = true ;
             }
         });
        if (is_pull_down_selected == true) {
            pull_down_button.find('.js-icon').removeClass('i-24-checkmark-off').addClass('i-24-checkmark-on');
        }else {
            pull_down_button.find('.js-icon').removeClass('i-24-checkmark-on').addClass('i-24-checkmark-off');
        }

    });

    $("body").on('click','.js-gs-checkbox',function(){

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
    $('.js-gs-checkbox-search').on('click',function(){
        var self=$(this);
        var checkbox = self.children(".js-icon");
        var hidden_field = self.siblings(".js-gs-checkbox-value");
        var gs_checkBox= self.data('gs-checkbox-value');
        var gs_checkBoxCategory= self.data('gs-checkbox-category');
        if (hidden_field.val()== '') {
            checkbox.removeClass('i-grey-unchecked-box').addClass('i-16-blue-check-box');
            hidden_field.attr("value", gs_checkBox).attr("name", gs_checkBoxCategory);
        } else {
            checkbox.removeClass('i-16-blue-check-box').addClass('i-grey-unchecked-box');
            hidden_field.removeAttr("value").removeAttr("name");
        }
    });

     $('.js-gs-checkbox-search-dropdown').on('click',function(){
        var self=$(this);
        var checkbox = self.children(".js-icon");
        var hidden_field = self.siblings(".js-gs-checkbox-search-collapsible-box");
        if (hidden_field.css('display') == 'none') {
            checkbox.removeClass('i-grey-unchecked-box').addClass('i-16-blue-check-box');
            hidden_field.show('slow')
        } else {
            checkbox.removeClass('i-16-blue-check-box').addClass('i-grey-unchecked-box');
            hidden_field.hide('fast');
        }
    });

    $('.js-guidedSearch').on('submit',function() {
        $(this).find("input").each( function () {
            if (!$.trim($(this).val())) {
                $(this).removeAttr("name");
            }
        });
    });
});
