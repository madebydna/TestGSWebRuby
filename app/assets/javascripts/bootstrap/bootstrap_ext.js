var GS = GS || {};
GS.bootstrap = GS.bootstrap || function($) {
    var initializeBootstrapExtensions = function () {
        initBootstrapButtonSelect();
//        initBootstrapDropdownText();
    };
    // use class js_bootstrapExtButtonSelect on any button group to allow selection to stick
    var initBootstrapButtonSelect = function () {
        $( ".js_bootstrapExtButtonSelect").on("click", "button", function( index ) {
            $(this).siblings().removeClass("active");
            $(this).addClass("active");
        });
    };
    // use class js_bootstrapExtDropdownText on any drop down to swap out default text
//    var initBootstrapDropdownText = function () {
//        $( ".js_bootstrapExtDropdownText").on("click", "a", function(){
//            console.log("Stinky");
//            var order_by = $(this).data( "order-review" );
//            var selectOrderDropDownText = $(this).closest('button');
//            selectOrderDropDownText.html($(this).html()+' <b class="caret"></b>');
//        });
//    };

    return {
        initializeBootstrapExtensions: initializeBootstrapExtensions
    }
}(jQuery);

$(function () {
    GS.bootstrap.initializeBootstrapExtensions();
});