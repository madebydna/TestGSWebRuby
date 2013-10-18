var GS = GS || {};
GS.reviews = GS.reviews || function($) {
    var initializeReviewHandlers = function () {
        // the next ten button
        var nextTenButton = $(".js_reviewsGetNextTen");
        var filterByGroup = $(".js_reviewFilterButton");
        var selectOrderDropDown = $(".js_reviewFilterDropDown");
        var selectOrderDropDownText = $(".js_reviewFilterDropDownText");
        var reviewContentLayer = $(".js_reviewsList");

        nextTenButton.on("click", function(){
            $(this).addClass("dn");
            var offset = $(this).data( "offset" );
            var limit = $(this).data( "limit" );
            var totalCount = $(this).data( "total-count" );
            var filter_by = filterByGroup.data( "group-selected" );
            var order_by = selectOrderDropDown.data( "order-selected" );
            callReviewsAjax(offset, limit, totalCount, filter_by, order_by);
        });

        filterByGroup.on("click", "button", function(){
            if(filterByGroup.data( "group-selected"  ) != $(this).data( "group-name" )){
                nextTenButton.addClass("dn");
                var offset = 0;
                var limit = nextTenButton.data( "limit" );
                var filter_by_group = $(this).data( "group-name" );
                var totalCount = nextTenButton.data( "all-count" );
                if(filter_by_group == "parent"){
                    totalCount = nextTenButton.data( "parent-count" );
                }
                else{
                   if(filter_by_group == "student"){
                       totalCount = nextTenButton.data( "student-count" );
                   }
                }
                nextTenButton.data( "total-count", totalCount );
                reviewContentLayer.html('');
                $(this).siblings().removeClass("active");
                $(this).addClass("active");
                filterByGroup.data( "group-selected", filter_by_group);
                var order_by = selectOrderDropDown.data( "order-selected" );
                callReviewsAjax(offset, limit, totalCount, filter_by_group, order_by);
            }
        });
        selectOrderDropDown.on("click", "a", function(){
            nextTenButton.addClass("dn");
            var order_by = $(this).data( "order-review" );

            if(selectOrderDropDown.data( "order-selected"  ) != order_by){
                selectOrderDropDown.data( "order-selected", order_by);
                selectOrderDropDownText.html($(this).html()+' <b class="caret"></b>');
                var offset = 0;
                var limit = nextTenButton.data( "limit" );
                var totalCount = nextTenButton.data( "total-count" );
                var filter_by = filterByGroup.data( "group-selected" );
                reviewContentLayer.html('');
                callReviewsAjax(offset, limit, totalCount, filter_by, order_by);
            }
        });
        var callReviewsAjax = function(offset, limit, totalCount, filter_by, order_by){
            jQuery.ajax({
                type:'GET',
                url:"/ajax/reviews_pagination",
                data:{
                    state: GS.uri.Uri.getFromQueryString('state'),
                    schoolId: GS.uri.Uri.getFromQueryString('schoolId'),
                    offset: offset,
                    limit: limit,
                    filter_by: filter_by,
                    order_by: order_by
                },
                dataType:'text',
                async:true
            }).done(function (html) {
                reviewContentLayer.append(html);
            }.gs_bind(this));

            var new_offset = offset+limit;
            nextTenButton.data( "offset", new_offset );
            if(totalCount > new_offset){
                nextTenButton.removeClass("dn");
            }
        };

    };
    return {
        initializeReviewHandlers: initializeReviewHandlers
    }
}(jQuery);

$(function () {
    GS.reviews.initializeReviewHandlers();
});

