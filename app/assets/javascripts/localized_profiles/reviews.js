GS.reviews = GS.reviews || function($) {
    var initializeReviewHandlers = function () {
        // the next ten button
        var nextTenButton = $(".js_reviewsGetNextTen");
        var filterByGroup = $(".js_reviewFilterButton");

        var reviewContentLayer = $(".js_reviewsList");
        var reviewsListHeader = '#js_reviewsListHeader';

        var filterByTopicDropDown = $(".js_reviewTopicFilterDropDown");
        var selectTopicDropDownText = $(".js_reviewTopicFilterDropDownText");

        var filterByTopicLink= $(".js_reviewTopicFilterLink");

        var getFieldValues = function(){
            var result = {};
            result['offset'] = nextTenButton.data( "offset" );
            result['limit'] = nextTenButton.data( "limit" );
            result['totalCount'] = nextTenButton.data( "total-count" );
            result['filter_by_user_type'] = filterByGroup.data( "group-selected" );
            result['filter_by_topic'] = filterByTopicDropDown.data( "topic-selected" );
            return result;
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
                reviewContentLayer.html('');
                filterByGroup.data( "group-selected", groupSelected);
                var results = getFieldValues();
                results['offset'] = 0;
                callReviewsAjax(results, false);
            }
        });

        filterByTopicDropDown.on("click", "a", function(){
            nextTenButton.addClass("dn");
            var topicSelected = $(this).data( "topic-filter" );
             if(filterByGroup.data( "topic-selected"  ) != topicSelected){
                selectTopicDropDownText.html($(this).html()+' <b class="caret"></b>');
                reviewContentLayer.html('');
                filterByTopicDropDown.data( "topic-selected", topicSelected);
                var results = getFieldValues();
                results['offset'] = 0;
                callReviewsAjax(results, false);
            }
        });

        filterByTopicLink.on("click", "a", function () {
            nextTenButton.addClass("dn");
            var topicSelected = $(this).data("topic-filter");
            selectTopicDropDownText.html(topicSelected + ' <b class="caret"></b>');
            reviewContentLayer.html('');
            filterByTopicDropDown.data("topic-selected", topicSelected);
            var results = getFieldValues();
            results['offset'] = 0;
            callReviewsAjax(results, false);
        });

        $("body").on("click", ".js_reviewHelpfulButton", function(){
          var review_id = $(this).data( "review_id" );
          if($.isNumeric(review_id)){
            postReviewVoteOrUnvote(review_id, $(this));
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
                    filter_by_user_type: results['filter_by_user_type'],
                    filter_by_topic: results['filter_by_topic'],
                    order_by: results['order_by']
                },
                dataType:'text',
                async:true
            }).done(function (html) {
                reviewContentLayer.append(html);
                GS.reviewsAd.writeDivAndFillReviews(adStartInt(results['offset'], results['limit'], nextTen));
                toggleNextTenButton(results);
                window.location.href = reviewsListHeader;
                var chartData = $('.js-reviewsListChart').data('topic-chart');
                GS.visualchart.drawBarChartReviewsList(JSON.stringify(chartData),'js_reviews_list_bar_chart_div');
            }.gs_bind(this));
        };

        var toggleNextTenButton = function (results) {
            var new_offset = results['offset'] + results['limit'];
            nextTenButton.data("offset", new_offset);
            if ($('.js-reviewsTotalCount').data('total-count') > new_offset) {
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
        new_form.attr('class', 'rs-report-review-form');

        var old_action = new_form.attr('action');

        var action = old_action.replace(new RegExp('0'), reviewId);

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

    var postReviewVoteOrUnvote = function(reviewId, obj) {
      obj.prop("disabled", true);
      var isActive = obj.hasClass('active');
      var shouldUnvote = !isActive;

      url = '';
      if(shouldUnvote) {
        url = "/gsr/reviews/" + reviewId + "/vote";
      } else {
        url = "/gsr/reviews/" + reviewId + "/unvote";
      }

      jQuery.ajax({
        type: 'POST',
        url: url,
        data: {
          review_id: reviewId
        },
        dataType: "json"
      }).done(function (data) {
        var redirectUrl = data.redirect_url;
        if (redirectUrl !== undefined && redirectUrl !== '') {
          window.location = redirectUrl;
        }

        var count = data[reviewId];
        if(isActive){
          obj.removeClass('active');
        } else {
          obj.addClass('active');
        }
        var people_string = 'people';
        if(count == 1){
          people_string = 'person';
        }

        var response_str = count + ' ' + people_string + ' found this helpful';
        if (isNaN(count)) {
          response_str = '';
        }

        // change button state
        obj.siblings("span").html(response_str);
        obj.prop("disabled", false);

      }.gs_bind(this));
    };

    return {
        initializeReviewHandlers: initializeReviewHandlers,
        showReportReviewForm: showReportReviewForm,
        closeReportReviewForm: closeReportReviewForm,
        reportReviewLinkClicked: reportReviewLinkClicked,
        reportReviewCloseLinkClicked: reportReviewCloseLinkClicked
    }
}(jQuery);