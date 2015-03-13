GS.topicalReview = GS.topicalReview || {};


GS.topicalReview.reviewQuestion = GS.topicalReview.reviewQuestion|| (function() {

    var isNoCheckboxValues = function (reviewContainer) {
        var checkBoxQuestion = $(reviewContainer).find('.js-gs-topical-reviews-checkboxes').length > 0;
        var checkbox_values = [];
        $(reviewContainer).find('.js-gs-checkbox-value').each(function (index) {
            if (this.value != "") {
                checkbox_values.push(this.value);
            }
        });
        return checkbox_values.length == 0 && checkBoxQuestion;
    }

    var GS_countCharacters = function (textField) {
        var reviewContainer = $(textField).parents('.js-topical-review-container');
        var characterDisplay = $('.js-review-character-display');
        var characterCountDisplay = $(reviewContainer).find(".js-review-character-count");
        var characterCount = textField.value.length;
        var maxCharacters = 2400;
        var remainingCharacters = maxCharacters - characterCount;
        if (characterCount > 0) {
            $(characterDisplay).show();
            $(characterCountDisplay).text(remainingCharacters);
        }
        else {
            $(characterDisplay).hide();
        }
    }

    var textBoxCharacters = function(textBox) {
        var reviewContainer = $(textBox).parents('.js-topical-review-container');
        var characterCount = textBox.value.length;
        if (characterCount > 0) {
            $(reviewContainer).find('.js-gs-results-snapshot').hide();
            $(reviewContainer).find('.js-gs-review-comment').show();
        }
        else {
            $(reviewContainer).find('.js-gs-review-comment').hide();
            $(reviewContainer).find('.js-gs-results-snapshot').show();
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

    var dropdownOptionSelected = function (reviewContainer) {
        if (isDropdownValueEmpty(reviewContainer)) {
            $(reviewContainer).find('.js-gs-review-comment').hide();
            $(reviewContainer).find('.js-gs-results-snapshot').show();
        } else {
            $(reviewContainer).find('.js-gs-results-snapshot').hide();
            $(reviewContainer).find('.js-gs-review-comment').show();
        }
    }

    var isDropdownValueEmpty = function(reviewContainer) {
        return $(reviewContainer).find ('select option:selected').val() === "";
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

    var checkForSubmitError = function(reviewContainer) {
        var errorMessage = $(reviewContainer).find('.js-review-submit-errors');
        if (isNoCheckboxValues(reviewContainer)) {
            errorMessage.show();
        }
        else {
            errorMessage.hide();
            navigateNextTopic(reviewContainer);
        }
    }

    var navigateNextTopic = function (reviewContainer) {
        var reviewContainers = $('.js-topical-review-container');
        var nextContainerIndex;
        reviewContainers.each(function(index, container){
            if ($(container).is(reviewContainer)) {
                nextContainerIndex = index +1;
            }
        })
        if (nextContainerIndex >= reviewContainers.length) {
            nextContainerIndex = 0;
        }
        reviewContainer.hide();
        $(reviewContainers[nextContainerIndex]).show();
    }

    var navigatePreviousTopic = function (reviewContainer) {
        var reviewContainers = $('.js-topical-review-container');
        var previousContainerIndex;
        reviewContainers.each(function (index, container) {
            if ($(container).is(reviewContainer)) {
                previousContainerIndex = index - 1;
            }
        })
        if (previousContainerIndex < 0) {
           previousContainerIndex = reviewContainers.length - 1;
        }
        reviewContainer.hide();
        $(reviewContainers[previousContainerIndex]).show();
    }

    return {
        isNoCheckboxValues: isNoCheckboxValues,
        GS_countCharacters: GS_countCharacters,
        backToCheckBoxes: backToCheckBoxes,
        optionSelected: optionSelected,
        getRadioValue: getRadioValue,
        backToRadioButtons: backToRadioButtons,
        dropdownOptionSelected: dropdownOptionSelected,
        isDropdownValueEmpty: isDropdownValueEmpty,
        textBoxCharacters: textBoxCharacters,
        navigateNextTopic: navigateNextTopic,
        navigatePreviousTopic: navigatePreviousTopic,
        checkForSubmitError: checkForSubmitError
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


    $('.js-topcial-review-dropdown').change(function () {
        var reviewContainer = $(this).parents('.js-topical-review-container');
        GS.topicalReview.reviewQuestion.dropdownOptionSelected(reviewContainer);
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

    $('.js-review-question-submit').on('click', function (){
        var reviewContainer = $(this).parents('.js-topical-review-container');
        GS.topicalReview.reviewQuestion.checkForSubmitError(reviewContainer);
    })

    $('.js-previous-topic').on('click', function(e){
        e.preventDefault();
        var reviewContainer = $(this).parents('.js-topical-review-container');
        GS.topicalReview.reviewQuestion.navigatePreviousTopic(reviewContainer);

    })

    $('.js-next-topic').on('click', function(e){
        e.preventDefault();
        var reviewContainer = $(this).parents('.js-topical-review-container');
        GS.topicalReview.reviewQuestion.navigateNextTopic(reviewContainer);
    })
});


