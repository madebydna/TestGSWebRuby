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
//            $(".js-gs-review-comment").trigger("showSubmit")
        }
        else {
//            $(".js-gs-review-comment").trigger("hideSubmit")
        }
    }

    var backToCheckBoxes = function(reviewContainer) {
        $(reviewContainer).find('.js-gs-topical-reviews-checkbox-selections').hide();
        $(reviewContainer).find('.js-gs-topical-reviews-checkboxes').show();
    }

    var optionSelected = function (reviewContainer){
        $(reviewContainer).find('.js-gs-results-snapshot').hide();
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
        backToCheckBoxes: backToCheckBoxes,
        optionSelected: optionSelected,
        getRadioValue: getRadioValue,
        backToRadioButtons: backToRadioButtons
    };
})();

$(function() {

    $('.js-gs-checkbox-topical').on('click', function () {
        var reviewContainer = $(this).parents('.js-topical-review-container');
        GS.topicalReview.reviewQuestion.optionSelected(reviewContainer);
    });

    $('.js-topical-radio').on('click', function () {
        var reviewContainer = $(this).parents('.js-topical-review-container');
        GS.topicalReview.reviewQuestion.optionSelected(reviewContainer);
    });

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
        currentContainer.hide();
        $(topicContainers[nextContainerIndex]).show();
    })
});


