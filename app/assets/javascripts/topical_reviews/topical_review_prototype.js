GS.topicalReview = GS.topicalReview || {};


GS.topicalReview.reviewQuestion = GS.topicalReview.reviewQuestion|| (function() {

    var getCheckboxValues = function (reviewContainer) {
        var checkbox_values = [];
        $(reviewContainer).find('.js-gs-checkbox-value').each(function (index) {
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

    var isQuestionCheckBoxSelected = function (reviewContainer) {
        var answer_selected;
        $(reviewContainer).find('.js-gs-checkbox-value').each(function (index) {
            if (this.value != "") {
                answer_selected = true;
            }
        })
        return answer_selected;
    }

    var showCheckBoxSubmit = function (reviewContainer) {
        if (isQuestionCheckBoxSelected(reviewContainer)) {
            $(reviewContainer).find(".js-review-question-submit").show();
        } else {
            $(reviewContainer).find(".js-review-question-submit").hide();
        }
    }

    var hideDuplicateSubmit = function(reviewContainer) {
        debugger;

    }

    var isduplicateSubmitVisible = function(reveiwContainer) {
        $(reviewContainer).find('.js-review-question-submit:visible').length > 1;
    }


    var checkBoxSubmit = function (reviewContainer) {
        $(reviewContainer).find('.js-gs-topical-reviews-checkboxes').hide();
        $(reviewContainer).find('.js-gs-topical-reviews-checkbox-selections').show();
        $(reviewContainer).find('.js-gs-checkbox-selections').text(GS.topicalReview.reviewQuestion.getCheckboxValues(reviewContainer));
        $(reviewContainer).find('.js-gs-results-snapshot').hide();
        $(reviewContainer).find('.js-gs-review-comment').show();

    }

    var backToCheckBoxes = function(reviewContainer) {
        $(reviewContainer).find('.js-gs-topical-reviews-checkbox-selections').hide();
        $(reviewContainer).find('.js-gs-topical-reviews-checkboxes').show();
//        hideDuplicateSubmit(reviewContainer);

    }

    var radioButtonSubmit = function (reviewContainer){
        var radioQuestions = $(reviewContainer).find('.js-gs-topical-reviews-radio');
        var radioSelections = $(reviewContainer).find('.js-topical-reviews-radio-selections');
        $(reviewContainer).find('.js-radio-selections-text').text(GS.topicalReview.reviewQuestion.getRadioValue(reviewContainer));
        $(radioQuestions).hide();
        $(reviewContainer).find('.js-gs-results-snapshot').hide();
        $(radioSelections).show();
        $(reviewContainer).find('.js-gs-review-comment').show();
    }

    var getRadioValue = function (reviewContainer){
        var selectedRadioValue = $(reviewContainer).find('input[type=radio]:checked').val();
        return selectedRadioValue;
    }

    var backToRadioButtons = function (reviewContainer) {
        var radioQuestions = $(reviewContainer).find('.js-gs-topical-reviews-radio');
        var radioSelections = $(reviewContainer).find('.js-topical-reviews-radio-selections');
        $(radioSelections).hide();
        $(radioQuestions).show();

    }

    return {
        getCheckboxValues: getCheckboxValues,
        GS_countCharacters: GS_countCharacters,
        showCheckBoxSubmit: showCheckBoxSubmit,
        checkBoxSubmit: checkBoxSubmit,
        backToCheckBoxes: backToCheckBoxes,
        radioButtonSubmit: radioButtonSubmit,
        getRadioValue: getRadioValue,
        backToRadioButtons: backToRadioButtons
    };
})();

$(function() {

    $('.js-gs-checkbox-topical').on('click', function () {
        var reviewContainer = $(this).parents('.js-topical-review-container');
        GS.topicalReview.reviewQuestion.showCheckBoxSubmit(reviewContainer);
    });

    $('.js-topical-radio').on('click', function () {
        var reviewContainer = $(this).parents('.js-topical-review-container');
        $(reviewContainer).find(".js-review-question-submit").show();
    });

    $('.js-gs-checkbox-submit').click(function (event) {
        event.preventDefault();
        var reviewContainer = $(this).parents('.js-topical-review-container');
        GS.topicalReview.reviewQuestion.checkBoxSubmit(reviewContainer);
   });

    $('.js-back-to-checkboxes').click(function (event) {
        event.preventDefault();
        var reviewContainer = $(this).parents('.js-topical-review-container');
        GS.topicalReview.reviewQuestion.backToCheckBoxes(reviewContainer);
    });

    $('.js-gs-radio-submit').click(function (event) {
        event.preventDefault();
        var reviewContainer = $(this).parents('.js-topical-review-container');
        GS.topicalReview.reviewQuestion.radioButtonSubmit(reviewContainer);
    });

    $('.js-back-to-radio').click(function (event) {
        event.preventDefault();
        var reviewContainer = $(this).parents('.js-topical-review-container');
        GS.topicalReview.reviewQuestion.backToRadioButtons(reviewContainer);
    });
;
    $('.js-gs-review-comment').on('showSubmit', function(){
        $('.js-gs-next-topic').hide();
        $('.js-gs-submit-comment').show();
    })

    $('.js-gs-review-comment').on('hideSubmit', function(){
        $('.js-gs-submit-comment').hide();
        $('.js-gs-next-topic').show();
    })

    $('.js-topical-review-container').first().show();

    $('.js-previous-topic').on('click', function(e){
        e.preventDefault();
        var topicContainers = $('.js-topical-review-container');
        var currentContainer = $(this).parents('.js-topical-review-container');
        var previousContainerIndex;
        topicContainers.each(function (index, container) {
            if ($(container).is(currentContainer)) {
                previousContainerIndex = index - 1;
            }
        })
        if (previousContainerIndex < 0) {
           previousContainerIndex = topicContainers.length - 1;
        }
        currentContainer.hide();
        $(topicContainers[previousContainerIndex]).show();
    })

    $('.js-next-topic').on('click', function(e){
        e.preventDefault();
        var topicContainers = $('.js-topical-review-container');
        var currentContainer = $(this).parents('.js-topical-review-container');
        var nextContainerIndex;
        topicContainers.each(function(index, container){
            if ($(container).is(currentContainer)) {
                nextContainerIndex = index +1;
            }
        })
        if (nextContainerIndex >= topicContainers.length) {
            nextContainerIndex = 0;
        }
//        debugger;
        currentContainer.hide();
        $(topicContainers[nextContainerIndex]).show();
    })
});


