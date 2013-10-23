var GS = GS || {};
GS.bootstrap = GS.bootstrap || function($) {
    var initializeBootstrapExtensions = function () {
        $( ".js_bootstrapExtButtonSelect").on("click", "button", function( index ) {
            $(this).siblings().removeClass("active");
            $(this).addClass("active");
        });
    };
    return {
        initializeBootstrapExtensions: initializeBootstrapExtensions
    }
}(jQuery);

$(function () {
    GS.bootstrap.initializeBootstrapExtensions();
});