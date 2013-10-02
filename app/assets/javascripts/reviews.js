$(function () {
    $(".js_reviewsGetNextTen").on("click", function(){
        $(this).addClass("dn");
        var offset = $(this).data( "offset" );
        var limit = $(this).data( "limit" );
        var totalCount = $(this).data( "total-count" );

        jQuery.ajax({
            type:'GET',
            url:"/ajax/reviews_pagination",
            data:{offset:offset, limit:limit},
            dataType:'html',
            async:true
        }).done(function (html) {
                $(".js_reviewsList").append(html);
        }.gs_bind(this));
        var new_offset = offset+limit;
        $(this).data( "offset", new_offset );
        if(totalCount > new_offset){
           $(this).removeClass("dn");
        }
    });
});