var GS = GS || {};
GS.reviews = GS.reviews || function($) {
    var initializeReviewHandlers = function () {
        // the next ten button
        var nextTenButton = $(".js_reviewsGetNextTen");
        var filterByGroup = $(".js_reviewFilterButton");

        var selectOrderDropDown = $(".js_reviewFilterDropDown");
        var selectOrderDropDownText = $(".js_reviewFilterDropDownText");
        var reviewContentLayer = $(".js_reviewsList");

        var getFieldValues = function(){
            var result = {};
            result['offset'] = nextTenButton.data( "offset" );
            result['limit'] = nextTenButton.data( "limit" );
            result['totalCount'] = nextTenButton.data( "total-count" );
            result['filter_by'] = filterByGroup.data( "group-selected" );
            result['order_by'] = selectOrderDropDown.data( "order-selected" );
            return result;
        };

        // group is the button group selection -  parent, all or student
        var setTotalCountByGroup = function(group){
            var totalCount = nextTenButton.data( "all-count" );
            if(group == "parent"){
                totalCount = nextTenButton.data( "parent-count" );
            }
            else{
                if(group == "student"){
                    totalCount = nextTenButton.data( "student-count" );
                }
            }
            nextTenButton.data( "total-count", totalCount );
        };

        nextTenButton.on("click", function(){
            $(this).addClass("dn");
            var results = getFieldValues();
            callReviewsAjax(results);
        });

        // group is the button group selection -  parent, all or student
        filterByGroup.on("click", "button", function(){
            var groupSelected = $(this).data( "group-name" )
            if(filterByGroup.data( "group-selected"  ) != groupSelected){
                nextTenButton.addClass("dn");
                setTotalCountByGroup(groupSelected);
                reviewContentLayer.html('');
                filterByGroup.data( "group-selected", groupSelected);
                var results = getFieldValues();
                results['offset'] = 0;
                callReviewsAjax(results);
            }
        });

        selectOrderDropDown.on("click", "a", function(){
            nextTenButton.addClass("dn");
            var order_by = $(this).data( "order-review" );
            if(selectOrderDropDown.data( "order-selected"  ) != order_by){
                selectOrderDropDown.data( "order-selected", order_by);
                selectOrderDropDownText.html($(this).html()+' <b class="caret"></b>');
                reviewContentLayer.html('');
                var results = getFieldValues();
                results['offset'] = 0;
                callReviewsAjax(results);
            }
        });

        var callReviewsAjax = function(results){
            jQuery.ajax({
                type:'GET',
                url:"/ajax/reviews_pagination",
                data:{
                    state: GS.stateAbbreviationFromUrl(),
                    schoolId: GS.schoolIdFromUrl(),
                    offset: results['offset'],
                    limit: results['limit'],
                    filter_by: results['filter_by'],
                    order_by: results['order_by']
                },
                dataType:'text',
                async:true
            }).done(function (html) {
                    reviewContentLayer.append(html);
                }.gs_bind(this));

            var new_offset = results['offset'] + results['limit'];
            nextTenButton.data( "offset", new_offset );
            if(results['totalCount'] > new_offset){
                nextTenButton.removeClass("dn");
            }
        };
    };
    return {
        initializeReviewHandlers: initializeReviewHandlers
    }
}(jQuery);