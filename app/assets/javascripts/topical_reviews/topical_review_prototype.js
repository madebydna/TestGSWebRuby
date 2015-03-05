GS.topicalReview = GS.topicalReview || {};


GS.topicalReview.reviewQuestion = GS.topicalReview.reviewQuestion|| (function() {

    var getCheckboxValues = function ( ) {
        var checkbox_values = [];
        $('.js-gs-checkbox-value').each(function (index) {
            if (this.value != "") {
                checkbox_values.push(this.value);
            }
        });
        return checkbox_values.join(', ');
    }

    var GS_countCharacters = function (textField) {
        var text = textField.value;
        if (text.length > 0) {
            $(".js-gs-review-comment").trigger("showSubmit")
        }
        else {
            $(".js-gs-review-comment").trigger("hideSubmit")
        }
    }

    return {
        getCheckboxValues: getCheckboxValues,
        GS_countCharacters: GS_countCharacters
    };
})();

$(function() {

    $('.js-gs-checkbox-topical').on('click', function () {
        var answer_selected;
        $('.js-gs-checkbox-value').each(function (index) {
            if (this.value != "") {
                answer_selected = true;
            }
        })
        if (answer_selected) {
            $(".js-review-question-submit").show();
        } else {
            $(".js-review-question-submit").hide();
        }
    });

    $('.js-gs-checkbox-submit').click(function (event) {
        event.preventDefault();
        $('.js-gs-topical-reviews-checkboxes').hide();
        $('.js-gs-topical-reviews-checkbox-selections').show();
        $('.js-gs-checkbox-selections').text(GS.topicalReview.reviewQuestion.getCheckboxValues())
        $('.js-gs-results-snapshot').hide();
        $('.js-gs-review-comment').show();
    });

    $('.js-back-to-checkboxes').click(function (event) {
        event.preventDefault();
        $('.js-gs-topical-reviews-checkbox-selections').hide();
        $('.js-gs-topical-reviews-checkboxes').show();
        $('.js-gs-review-comment').hide();
        $('.js-gs-results-snapshot').show();
    });

    $('.js-gs-review-comment').on('showSubmit', function(){
        $('.js-gs-next-topic').hide();
        $('.js-gs-submit-comment').show();
    })

    $('.js-gs-review-comment').on('hideSubmit', function(){
        $('.js-gs-submit-comment').hide();
        $('.js-gs-next-topic').show();
    })

});


