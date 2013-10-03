$(function () {
    $(".js_reviewsGetNextTen").on("click", function(){
        $(this).addClass("dn");
        var offset = $(this).data( "offset" );
        var limit = $(this).data( "limit" );
        var totalCount = $(this).data( "total-count" );
        var filter_by = $(".js_reviewFilterButton").data( "group-selected" );
        var order_by = $(".js_reviewFilterDropDown").data( "order-selected" );
        callAjax(offset, limit, totalCount, filter_by, order_by);
    });

    $(".js_reviewFilterButton").on("click", "button", function(){
        if($(".js_reviewFilterButton").data( "group-selected"  ) != $(this).data( "group-name" )){
            var offset = 0;
            var limit = $(".js_reviewsGetNextTen").data( "limit" );
            var filter_by_group = $(this).data( "group-name" );
            var totalCount = $(".js_reviewsGetNextTen").data( "all-count" );
            if(filter_by_group == "parent"){
                totalCount = $(".js_reviewsGetNextTen").data( "parent-count" );
            }
            else{
               if(filter_by_group == "student"){
                   totalCount = $(".js_reviewsGetNextTen").data( "student-count" );
               }
            }
            $(".js_reviewsGetNextTen").data( "total-count", totalCount );

            $(".js_reviewsList").html('');

            $(this).siblings().removeClass("active");
            $(this).addClass("active");
            $(".js_reviewFilterButton").data( "group-selected", filter_by_group);

            var order_by = $(".js_reviewFilterDropDown").data( "order-selected" );

            callAjax(offset, limit, totalCount, filter_by_group, order_by);
        }
    });
    $(".js_reviewFilterDropDown").on("click", "a", function(){

        var storeSelectedObj = $(".js_reviewFilterDropDown");
        var selectedText = $(".js_reviewFilterDropDownText");
        var order_by = $(this).data( "order-review" );

        if(storeSelectedObj.data( "order-selected"  ) != order_by){
            storeSelectedObj.data( "order-selected", order_by);
            selectedText.html($(this).html()+' <b class="caret"></b>');
            var offset = 0;
            var limit = $(".js_reviewsGetNextTen").data( "limit" );
            var totalCount = $(".js_reviewsGetNextTen").data( "total-count" );
            var filter_by = $(".js_reviewFilterButton").data( "group-selected" );
            $(".js_reviewsList").html('');
            callAjax(offset, limit, totalCount, filter_by, order_by);
        }
    });
    var callAjax = function(offset, limit, totalCount, filter_by, order_by){
        console.log(offset+":"+limit+":"+totalCount+":"+filter_by+":"+order_by);
        jQuery.ajax({
            type:'GET',
            url:"/ajax/reviews_pagination",
            data:{offset:offset, limit:limit, filter_by:filter_by, order_by:order_by},
            dataType:'text',
            async:true
        }).done(function (html) {
            $(".js_reviewsList").append(html);
        }.gs_bind(this));

        var new_offset = offset+limit;
        $(".js_reviewsGetNextTen").data( "offset", new_offset );
        if(totalCount > new_offset){
            $(".js_reviewsGetNextTen").removeClass("dn");
        }
    };

});