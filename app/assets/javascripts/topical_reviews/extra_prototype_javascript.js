//GS.topicalReview = GS.topicalReview || {};
//
//GS.topicalReview.starRating = (function() {
//    var YELLOW_STAR_SELECTOR = 'i-52-orange-star';
//    var GREY_STAR_SELECTOR = 'i-52-grey-star';
//    var INDIVIDUAL_STAR_CONTAINER = '.js-topicalReviewStarContainer';
//    var INDIVIDUAL_STAR_SELECTOR = '.js-topicalReviewStar';
//    var LABEL_BOLD_CLASS = 'open-sans_sb';
//
//    var applyStarRating = function(container, hiddenField) {
//
//        var selectStar = function(rating) {
//
//            $(container).find(INDIVIDUAL_STAR_SELECTOR).each(function(index) {
//                var star_rating = index + 1;
//                if (star_rating <= rating) {
//                    $(this).addClass(YELLOW_STAR_SELECTOR);
//                    $(this).removeClass(GREY_STAR_SELECTOR);
//                } else {
//                    $(this).addClass(GREY_STAR_SELECTOR);
//                    $(this).removeClass(YELLOW_STAR_SELECTOR);
//                }
//                if (star_rating === rating) {
//                    $(this).siblings('.js-topicalReviewLabel').addClass(LABEL_BOLD_CLASS);
//                    $(this).siblings('.js-topicalReviewLabel').removeClass('gray-dark');
//                }
//                else {
//                    $(this).siblings('.js-topicalReviewLabel').removeClass(LABEL_BOLD_CLASS);
//                    $(this).siblings('.js-topicalReviewLabel').addClass('gray-dark');
//                }
//            });
//
//        };
//
//        $(container).on('click', INDIVIDUAL_STAR_CONTAINER, function() {
//            $this = $(this);
//            var rating = $this.index() + 1;
//            $(hiddenField).val(rating);
//            selectStar(rating);
//        });
//
//        $(container).on('mouseover', INDIVIDUAL_STAR_CONTAINER, function() {
//            selectStar($(this).index() + 1);
//        });
//
//        $(container).on('mouseout', INDIVIDUAL_STAR_CONTAINER, function() {
//            var rating = $(hiddenField).val();
//            selectStar(rating);
//            var selectedStar = $(container).find(INDIVIDUAL_STAR_CONTAINER).get(rating - 1);
//            $(selectedStar).children('.js-topicalReviewLabel').addClass(LABEL_BOLD_CLASS);
//            $(selectedStar).children('.js-topicalReviewLabel').removeClass('gray-dark');
//        });
//    };
//
//    return {
//        applyStarRating: applyStarRating
//    }
//
//})();
//
//GS.topicalReview.checkbox = (function (){
//    var CHECKBOX_CONTAINER = '.js-checkboxContainer';
//    var ICON_SELECTOR =  '.js-icon';
//    var HIDDEN_FIELDS_DATA_SELECTOR = 'fields';
////   var HIDDEN_FIELD_SELECTOR = '.js-topicalHiddenField';
//
//    var initCheckBoxes = function () {
//
//        var selectCheckBox = function (self, checkbox) {
//            var hidden_field = self.data(HIDDEN_FIELDS_DATA_SELECTOR);
//            self.append(hidden_field);
//            checkbox.removeClass('i-grey-unchecked-box').addClass('i-16-blue-check-box');
//        }
//
//        var unSelectCheckBox = function (self, checkbox) {
//            self.children('fieldset').remove();
//            checkbox.removeClass('i-16-blue-check-box').addClass('i-grey-unchecked-box');
//        }
//
//        var toggleCheckbox = function (self) {
//            var checkbox = self.children(ICON_SELECTOR);
//            if (isCheckboxNotSelected(self)) {
//                selectCheckBox(self, checkbox);
//            } else {
//                unSelectCheckBox(self, checkbox);
//            }
//        }
//
//        var isCheckboxNotSelected = function (self) {
//            return self.children('fieldset').length === 0
//        }
//
//        $(CHECKBOX_CONTAINER).on('click', function () {
//            var self = $(this);
//            var reviewContainer = self.parents('.js-topicalReviewContainer');
//            GS.topicalReview.reviewQuestion.optionSelected(reviewContainer);
//            toggleCheckbox(self);
//        });
//
//        $('.new_review').on('ajax:success', function(event, xhr, status, error) {
//            var reviewContainer = $(this).parents('.js-topicalReviewContainer');
//            $(reviewContainer).addClass('js-reviewComplete');
//            $(reviewContainer).hide();
//            GS.topicalReview.reviewQuestion.navigateNextTopic(reviewContainer);
//        }).on('ajax:error', function(event, xhr, status, error){
//        })
//    }
//
//    return {
//        initCheckBoxes: initCheckBoxes
//    }
//
//})();
//
//GS.topicalReview.reviewQuestion = GS.topicalReview.reviewQuestion|| (function() {
//
//    var isNoCheckboxValues = function (reviewContainer) {
//        var checkBoxQuestion = $(reviewContainer).find('.js-gs-topical-reviews-checkboxes').length > 0;
//        var checkbox_values = [];
//        $(reviewContainer).find('.js-gs-checkbox-value').each(function (index) {
//            if (this.value != "") {
//                checkbox_values.push(this.value);
//            }
//        });
//        return checkbox_values.length == 0 && checkBoxQuestion;
//    }
//
//    var GS_countCharacters = function (textField) {
//        var reviewContainer = $(textField).parents('.js-topicalReviewContainer');
//        var characterDisplay = $('.js-review-character-display');
//        var characterCountDisplay = $(reviewContainer).find(".js-review-character-count");
//        var characterCount = textField.value.length;
//        var maxCharacters = 2400;
//        var remainingCharacters = maxCharacters - characterCount;
//        if (characterCount > 0) {
//            $(characterDisplay).show();
//            $(characterCountDisplay).text(remainingCharacters);
//        }
//        else {
//            $(characterDisplay).hide();
//        }
//    }
//
//    var textBoxCharacters = function(textBox) {
//        var reviewContainer = $(textBox).parents('.js-topicalReviewContainer');
//        var characterCount = textBox.value.length;
//        if (characterCount > 0) {
//            $(reviewContainer).find('.js-gs-results-snapshot').hide();
//            $(reviewContainer).find('.js-topicalReviewComment').show();
//        }
//        else {
//            $(reviewContainer).find('.js-topicalReviewComment').hide();
//            $(reviewContainer).find('.js-gs-results-snapshot').show();
//        }
//    }
//
////    var backToCheckBoxes = function(reviewContainer) {
////        $(reviewContainer).find('.js-gs-topical-reviews-checkbox-selections').hide();
////        $(reviewContainer).find('.js-gs-topical-reviews-checkboxes').show();
////    }
//
//    var optionSelected = function (reviewContainer){
//        $(reviewContainer).find('.js-gs-results-snapshot').hide();
//        $(reviewContainer).find('.js-topicalReviewComment').show();
//    }
//
//    var dropdownOptionSelected = function (reviewContainer) {
//        if (isDropdownValueEmpty(reviewContainer)) {
//            $(reviewContainer).find('.js-topicalReviewComment').hide();
//            $(reviewContainer).find('.js-gs-results-snapshot').show();
//        } else {
//            $(reviewContainer).find('.js-gs-results-snapshot').hide();
//            $(reviewContainer).find('.js-topicalReviewComment').show();
//        }
//    }
//
//    var isDropdownValueEmpty = function(reviewContainer) {
//        return $(reviewContainer).find ('select option:selected').val() === "";
//    }
//
//    var getRadioValue = function (reviewContainer){
//        var selectedRadioValue = $(reviewContainer).find('input[type=radio]:checked').val();
//        return selectedRadioValue;
//    }
//
////    var backToRadioButtons = function (reviewContainer) {
////        var radioQuestions = $(reviewContainer).find('.js-gs-topical-reviews-radio');
////        var radioSelections = $(reviewContainer).find('.js-topical-reviews-radio-selections');
////        $(radioSelections).hide();
////        $(radioQuestions).show();
////
////    }
//
////    var checkForSubmitError = function(reviewContainer) {
////        var errorMessage = $(reviewContainer).find('.js-review-submit-errors');
////        if (isNoCheckboxValues(reviewContainer)) {
////            errorMessage.show();
////        }
////        else {
////            errorMessage.hide();
////            navigateNextTopic(reviewContainer);
////        }
////    }
//
//    var navigateNextTopic = function (reviewContainer) {
//        var reviewContainers = $('.js-topicalReviewContainer');
//        if (isMultipleQuestions()) {
//            var nextContainer = getNextReviewContainer(reviewContainers, reviewContainer);
//            removeOrHideQuestions(reviewContainer);
//            $(nextContainer).show();
//        }
//        else {
//            GS.topicalReview.reviewQuestion.hideQuestionNavigation();
//            removeOrHideQuestions(reviewContainer);
//        }
//    }
//
//    var navigatePreviousTopic = function (reviewContainer) {
//        var reviewContainers = $('.js-topicalReviewContainer');
//        if (isMultipleQuestions()) {
//            var previousContainer = getPreviousReviewContainer(reviewContainers, reviewContainer);
//            removeOrHideQuestions(reviewContainer);
//            $(previousContainer).show();
//        } else {
//            GS.topicalReview.reviewQuestion.hideQuestionNavigation();
//            removeOrHideQuestions(reviewContainer);
//        }
//    }
//
//    var removeOrHideQuestions = function(reviewContainer) {
//        if (reviewContainer.hasClass('js-reviewComplete')) {
//            $(reviewContainer).remove();
//            oneQuestionCheck();
//            noQuestionsCheck();
//        } else {
//            reviewContainer.hide();
//            oneQuestionCheck();
//        }
//    }
//
//    var noQuestionsCheck = function () {
//        if (isNoQuestions()) {
//            hideQuestionNavigation();
//            showQuestionsComplete();
//        }
//    }
//
//    var oneQuestionCheck = function () {
//        if ($('.js-topicalReviewContainer').length === 1) {
//            hideQuestionNavigation();
//        }
//    }
//
//    var getNextReviewContainer = function (reviewContainers, reviewContainer) {
//        var nextContainerIndex;
//        reviewContainers.each(function (index, container) {
//            if ($(container).is(reviewContainer)) {
//                nextContainerIndex = index + 1;
//            }
//        })
//        if (nextContainerIndex >= reviewContainers.length) {
//            nextContainerIndex = 0;
//        }
//        return $(reviewContainers[nextContainerIndex]);
//    }
//
//    var getPreviousReviewContainer = function (reviewContainers, reviewContainer) {
//        var previousContainerIndex;
//        reviewContainers.each(function (index, container) {
//            if ($(container).is(reviewContainer)) {
//                previousContainerIndex = index - 1;
//            }
//        })
//        if (previousContainerIndex < 0) {
//            previousContainerIndex = reviewContainers.length - 1;
//        }
//        return $(reviewContainers[previousContainerIndex]);
//    }
//
//    var hideQuestionNavigation = function() {
//        var questionNavigation = $('.js-topicalQuestionNavigation');
//        $(questionNavigation).hide();
//    }
//
//    var isMultipleQuestions = function() {
//        return $('.js-topicalReviewContainer').length > 1;
//    }
//
//    var isNoQuestions = function() {
//        return $('.js-topicalReviewContainer').length === 0;
//    }
//
//    var showQuestionsComplete= function() {
//        $('.js-QuestionsComplete').show();
//    }
//
//
//
//    return {
//        GS_countCharacters: GS_countCharacters,
////        backToCheckBoxes: backToCheckBoxes,
//        optionSelected: optionSelected,
//        getRadioValue: getRadioValue,
////        backToRadioButtons: backToRadioButtons,
//        dropdownOptionSelected: dropdownOptionSelected,
//        isDropdownValueEmpty: isDropdownValueEmpty,
//        textBoxCharacters: textBoxCharacters,
//        navigateNextTopic: navigateNextTopic,
//        navigatePreviousTopic: navigatePreviousTopic,
////        checkForSubmitError: checkForSubmitError,
//        isMultipleQuestions: isMultipleQuestions,
//        hideQuestionNavigation: hideQuestionNavigation,
//        isNoQuestions: isNoQuestions,
//        showQuestionsComplete: showQuestionsComplete
//    };
//})();
//
//$(function() {
//
////    $('.js-topical-radio').on('click', function () {
////        var reviewContainer = $(this).parents('.js-topicalReviewContainer');
////        GS.topicalReview.reviewQuestion.optionSelected(reviewContainer);
////    });
////
////
////    $('.js-topcial-review-dropdown').change(function () {
////        var reviewContainer = $(this).parents('.js-topicalReviewContainer');
////        GS.topicalReview.reviewQuestion.dropdownOptionSelected(reviewContainer);
////    });
//
////    $('.js-topicalReviewComment').on('showSubmit', function(){
////        $('.js-gs-next-topic').hide();
////        $('.js-gs-submit-comment').show();
////    })
////
////    $('.js-topicalReviewComment').on('hideSubmit', function(){
////        $('.js-gs-submit-comment').hide();
////        $('.js-gs-next-topic').show();
////    })
//
//    $('.js-topicalReviewContainer').first().show();
//
//
//    $('.js-previous-topic').on('click', function(e){
//        e.preventDefault();
//        var reviewContainer = $(this).parents('.js-topicalReviewContainer');
//        GS.topicalReview.reviewQuestion.navigatePreviousTopic(reviewContainer);
//
//    })
//
//    $('.js-next-topic').on('click', function(e){
//        e.preventDefault();
//        var reviewContainer = $(this).parents('.js-topicalReviewContainer');
//        GS.topicalReview.reviewQuestion.navigateNextTopic(reviewContainer);
//    })
//
//    $(document).ready(function() {
//        if (!GS.topicalReview.reviewQuestion.isMultipleQuestions()) {
//            GS.topicalReview.reviewQuestion.hideQuestionNavigation();
//        }
//        if (GS.topicalReview.reviewQuestion.isNoQuestions()) {
//            GS.topicalReview.reviewQuestion.showQuestionsComplete();
//        }
//    });
//
//    GS.topicalReview.starRating.applyStarRating('.js-topicalReviewStars', '#js-topicalOverallRating')
//    GS.topicalReview.checkbox.initCheckBoxes();
//});
//
//
// navigation prototype javascript removed


//GS.topicalReview.reviewQuestion = GS.topicalReview.reviewQuestion|| (function() {


//    var navigateNextTopic = function (reviewContainer) {
//        var reviewContainers = $('.js-topicalReviewContainer');
//        if (isMultipleQuestions()) {
//            var nextContainer = getNextReviewContainer(reviewContainers, reviewContainer);
//            removeOrHideQuestions(reviewContainer);
//            $(nextContainer).show();
//        }
//        else {
//            GS.topicalReview.reviewQuestion.hideQuestionNavigation();
//            removeOrHideQuestions(reviewContainer);
//        }
//    };
//
//    var navigatePreviousTopic = function (reviewContainer) {
//        var reviewContainers = $('.js-topicalReviewContainer');
//        if (isMultipleQuestions()) {
//            var previousContainer = getPreviousReviewContainer(reviewContainers, reviewContainer);
//            removeOrHideQuestions(reviewContainer);
//            $(previousContainer).show();
//        } else {
//            GS.topicalReview.reviewQuestion.hideQuestionNavigation();
//            removeOrHideQuestions(reviewContainer);
//        }
//    };
//
//    var removeOrHideQuestions = function(reviewContainer) {
//        if (reviewContainer.hasClass('js-reviewComplete')) {
//            $(reviewContainer).remove();
//            oneQuestionCheck();
//            noQuestionsCheck();
//        } else {
//            reviewContainer.hide();
//            oneQuestionCheck();
//        }
//    };
//
//    var noQuestionsCheck = function () {
//        if (isNoQuestions()) {
//            hideQuestionNavigation();
//            showQuestionsComplete();
//        }
//    };
//
//    var oneQuestionCheck = function () {
//        if ($('.js-topicalReviewContainer').length === 1) {
//            hideQuestionNavigation();
//        }
//    };
//
//    var getNextReviewContainer = function (reviewContainers, reviewContainer) {
//        var nextContainerIndex;
//        reviewContainers.each(function (index, container) {
//            if ($(container).is(reviewContainer)) {
//                nextContainerIndex = index + 1;
//            }
//        });
//        if (nextContainerIndex >= reviewContainers.length) {
//            nextContainerIndex = 0;
//        }
//        return $(reviewContainers[nextContainerIndex]);
//    };
//
//    var getPreviousReviewContainer = function (reviewContainers, reviewContainer) {
//        var previousContainerIndex;
//        reviewContainers.each(function (index, container) {
//            if ($(container).is(reviewContainer)) {
//                previousContainerIndex = index - 1;
//            }
//        });
//        if (previousContainerIndex < 0) {
//            previousContainerIndex = reviewContainers.length - 1;
//        }
//        return $(reviewContainers[previousContainerIndex]);
//    };
//
//    var hideQuestionNavigation = function() {
//        var questionNavigation = $('.js-topicalQuestionNavigation');
//        $(questionNavigation).hide();
//    };
//
//    var isMultipleQuestions = function() {
//       return $('.js-topicalReviewContainer').length > 1;
//    };
//
//    var isNoQuestions = function() {
//        return $('.js-topicalReviewContainer').length === 0;
//    };

//    var showQuestionsComplete = function() {
//        $('.js-QuestionsComplete').show();
//    };

//return {
//        navigateNextTopic: navigateNextTopic,
//        navigatePreviousTopic: navigatePreviousTopic,
//        isMultipleQuestions: isMultipleQuestions,
//        hideQuestionNavigation: hideQuestionNavigation,
//        isNoQuestions: isNoQuestions,
//        showQuestionsComplete: showQuestionsComplete
//};
//})();
//
// var textBoxCharacters = function(textBox) {
//    var reviewContainer = $(textBox).parents('.js-topicalReviewContainer');
//    var characterCount = textBox.value.length;
//    if (characterCount > 0) {
//        $(reviewContainer).find('.js-gs-results-snapshot').hide();
//        $(reviewContainer).find('.js-topicalReviewComment').show();
//    }
//    else {
//        $(reviewContainer).find('.js-topicalReviewComment').hide();
//        $(reviewContainer).find('.js-gs-results-snapshot').show();
//    }
//};
//
//

//    $('.js-topicalReviewContainer').first().show();
//
//    $(document).ready(function() {
//        if (!GS.topicalReview.reviewQuestion.isMultipleQuestions()) {
//            GS.topicalReview.reviewQuestion.hideQuestionNavigation();
//        }
//        if (GS.topicalReview.reviewQuestion.isNoQuestions()) {
//            GS.topicalReview.reviewQuestion.showQuestionsComplete();
//        }
//    });
//    $('.js-previous-topic').on('click', function(e){
//        e.preventDefault();
//        var reviewContainer = $(this).parents('.js-topicalReviewQuestionsContainer ').find('.js-topicalReviewContainer:visible')
//        GS.topicalReview.reviewQuestion.navigatePreviousTopic(reviewContainer);
//
//    });

//    $('.js-next-topic').on('click', function(e){
//        e.preventDefault();
//        var reviewContainer = $(this).parents('.js-topicalReviewQuestionsContainer ').find('.js-topicalReviewContainer:visible')
//        GS.topicalReview.reviewQuestion.navigateNextTopic(reviewContainer);
//    });

//});