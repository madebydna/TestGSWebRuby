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
            dataType:'text',
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
    $(".js_reviewFilterButton").on("click", "button", function(){
        console.log($(this).data( "group-name" ));
        console.log($(this).parent().data( "group-selected"  ));

        if($(this).parent().data( "group-selected"  ) != $(this).data( "group-name" )){
            $(this).siblings().removeClass("active");
            $(this).addClass("active");
            $(this).parent().data( "group-selected", $(this).data( "group-name" ))
            console.log("call ajax and replace reviews list");
            console.log("update button on the bottom with correct data and hide if appropriate");
        }
//
//        $(this).addClass("dn");
//        var offset = $(this).data( "offset" );
//        var limit = $(this).data( "limit" );
//        var totalCount = $(this).data( "total-count" );
//
//        jQuery.ajax({
//            type:'GET',
//            url:"/ajax/reviews_pagination",
//            data:{offset:offset, limit:limit},
//            dataType:'text',
//            async:true
//        }).done(function (html) {
//                $(".js_reviewsList").append(html);
//            }.gs_bind(this));
//        var new_offset = offset+limit;
//        $(this).data( "offset", new_offset );
//        if(totalCount > new_offset){
//            $(this).removeClass("dn");
//        }
    });
    $(".js_reviewFilterDropDown").on("click", "a", function(){
        console.log($(this).data( "order-review" ));
        if($(this).parent().parent().data( "order-selected"  ) != $(this).data( "order-review" )){

            $(this).addClass("active");
            $(this).parent().parent().data( "order-selected", $(this).data( "order-review" ))
            console.log("call ajax and replace reviews list");
            console.log("update button on the bottom with correct data and hide if appropriate");
        }
//
//        $(this).addClass("dn");
//        var offset = $(this).data( "offset" );
//        var limit = $(this).data( "limit" );
//        var totalCount = $(this).data( "total-count" );
//
//        jQuery.ajax({
//            type:'GET',
//            url:"/ajax/reviews_pagination",
//            data:{offset:offset, limit:limit},
//            dataType:'text',
//            async:true
//        }).done(function (html) {
//                $(".js_reviewsList").append(html);
//            }.gs_bind(this));
//        var new_offset = offset+limit;
//        $(this).data( "offset", new_offset );
//        if(totalCount > new_offset){
//            $(this).removeClass("dn");
//        }
    });

});