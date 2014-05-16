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
            callReviewsAjax(results, true);
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
                callReviewsAjax(results, false);
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
                callReviewsAjax(results, false);
            }
        });

        var callReviewsAjax = function(results, nextTen){
            jQuery.ajax({
                type:'GET',
                url:"/gsr/ajax/reviews_pagination",
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
                GS.reviewsAd.writeDivAndFillReviews(adStartInt(results['offset'], results['limit'], nextTen));
            }.gs_bind(this));

            var new_offset = results['offset'] + results['limit'];
            nextTenButton.data( "offset", new_offset );
            if(results['totalCount'] > new_offset){
                nextTenButton.removeClass("dn");
            }
        };

        var adStartInt = function(offset, limit, nextTen){
            var retInt = 0;
            if(nextTen){
                retInt = offset / limit * GS.reviewsAd.reviewSlotCount;
            }
            return retInt;
        };
    };



    var reportReviewLink = function(reviewId) {
        return $(".js-report-review-link-" + reviewId);
    };

    var reportReviewCloseLink = function(reviewId) {
        return $(".js-report-review-close-link-" + reviewId);
    };

    var reportReviewLinkClicked = function(reviewId, containerDomSelector) {
        reportReviewLink(reviewId).hide();
        reportReviewCloseLink(reviewId).show();
        showReportReviewForm(reviewId, containerDomSelector);
    };

    var reportReviewCloseLinkClicked = function(reviewId, containerDomSelector) {
        reportReviewLink(reviewId).show();
        reportReviewCloseLink(reviewId).hide();
        closeReportReviewForm(reviewId);
    };

    var showReportReviewForm = function(reviewId, containerDomSelector) {
        var reportFormSelector = '.js-report-review-form-template';

        var form = $(reportFormSelector).clone(true);

        $(containerDomSelector).append(form.html());

        var new_form = $(containerDomSelector + ' form');

        new_form.attr('id', 'js-report-review-form-' + reviewId);

        var old_action = new_form.attr('action');

        var action = old_action.replace(new RegExp('0/$'), reviewId + '/');

        new_form.attr('action', action);

        new_form.parsley( 'addListener', {
            onFieldError: function ( elem ) {
                elem.closest('.form-group').addClass('has-error');
            },
            onFieldSuccess: function ( elem ) {
                elem.closest('.form-group').removeClass('has-error');
            }
        } );

        new_form.find('.js-report-review-form-cancel').on('click', function() {
            reportReviewLink(reviewId).show();
            reportReviewCloseLink(reviewId).hide();
            closeReportReviewForm(reviewId);
        });

        new_form.parent().parent().show();
    };

    var closeReportReviewForm = function(reviewId) {
        var form = $('#js-report-review-form-' + reviewId);
        if (form !== null) {
            form.parent().parent().hide();
            form.remove();
        }
    };

    return {
        initializeReviewHandlers: initializeReviewHandlers,
        showReportReviewForm: showReportReviewForm,
        closeReportReviewForm: closeReportReviewForm,
        reportReviewLinkClicked: reportReviewLinkClicked,
        reportReviewCloseLinkClicked: reportReviewCloseLinkClicked
    }
}(jQuery);