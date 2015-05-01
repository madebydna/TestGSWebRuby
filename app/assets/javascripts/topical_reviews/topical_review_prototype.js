GS.topicalReview = GS.topicalReview || {};

GS.topicalReview.starRating = (function () {
    var YELLOW_STAR_SELECTOR = 'i-48-orange-star';
    var BLUE_STAR_SELECTOR = 'i-48-blue-star';
    var INDIVIDUAL_STAR_CONTAINER = '.js-topicalReviewStarContainer';
    var INDIVIDUAL_STAR_SELECTOR = '.js-topicalReviewStar';
    var LABEL_BOLD_CLASS = 'open-sans_sb';
    var HIDDEN_FIELDS_DATA_SELECTOR = 'fields';

    var applyStarRating = function (container, hiddenField) {

        var selectStar = function (rating) {

            $(container).find(INDIVIDUAL_STAR_SELECTOR).each(function (index) {
                var star_rating = index + 1;
                if (star_rating <= rating) {
                    $(this).addClass(YELLOW_STAR_SELECTOR);
                    $(this).removeClass(BLUE_STAR_SELECTOR);
                } else {
                    $(this).addClass(BLUE_STAR_SELECTOR);
                    $(this).removeClass(YELLOW_STAR_SELECTOR);
                }
                if (star_rating === rating) {
                    $(this).siblings('.js-topicalReviewLabel').addClass(LABEL_BOLD_CLASS);
                    $(this).siblings('.js-topicalReviewLabel').removeClass('gray-dark');
                }
                else {
                    $(this).siblings('.js-topicalReviewLabel').removeClass(LABEL_BOLD_CLASS);
                    $(this).siblings('.js-topicalReviewLabel').addClass('gray-dark');
                }
            });

        };

        $(container).on('click', INDIVIDUAL_STAR_CONTAINER, function () {
            $this = $(this);
            var hiddenFieldsContainer = $(".js-starHiddenFields");
            hiddenFieldsContainer.empty();
            var rating = $this.index() + 1;
            var hidden_field = $this.data('fields');
            hiddenFieldsContainer.append(hidden_field);
            $(hiddenField).val(rating);
            selectStar(rating);
        });

        $(container).on('mouseover', INDIVIDUAL_STAR_CONTAINER, function () {
            selectStar($(this).index() + 1);
        });

        $(container).on('mouseout', INDIVIDUAL_STAR_CONTAINER, function () {
            var rating = $('.js-starHiddenFields').find('input').val()
            selectStar(rating);
            var selectedStar = $(container).find(INDIVIDUAL_STAR_CONTAINER).get(rating - 1);
            $(selectedStar).children('.js-topicalReviewLabel').addClass(LABEL_BOLD_CLASS);
            $(selectedStar).children('.js-topicalReviewLabel').removeClass('gray-dark');
        });
    };

    return {
        applyStarRating: applyStarRating
    }

})();

GS.topicalReview.checkBoxes = (function () {
    var CHECKBOX_CONTAINER = '.js-checkboxContainer';
    var ICON_SELECTOR = '.js-icon';
    var HIDDEN_FIELDS_DATA_SELECTOR = 'fields';

    var init = function () {

        var selectCheckBox = function (self, checkBox) {
//            add hidden field for checkbox stored in data-field
            var hidden_field = self.data(HIDDEN_FIELDS_DATA_SELECTOR);
            self.append(hidden_field);
            checkBox.removeClass('i-grey-unchecked-box').addClass('i-16-blue-check-box');
        };

        var unSelectCheckBox = function (self, checkBox) {
//            remove fieldset for checkbox when unselected so no is value submitted with form
            self.children('fieldset').remove();
            checkBox.removeClass('i-16-blue-check-box').addClass('i-grey-unchecked-box');
        };

        var isCheckboxNotSelected = function (self) {
            return self.children('fieldset').length === 0
        };

        var toggleCheckbox = function (self) {
            var checkBox = self.children(ICON_SELECTOR);
            if (isCheckboxNotSelected(self)) {
                selectCheckBox(self, checkBox);
            } else {
                unSelectCheckBox(self, checkBox);
            }
        };

        $(CHECKBOX_CONTAINER).on('click', function () {
            var self = $(this);
            var reviewContainer = self.parents('.js-topicalReviewContainer');
            GS.topicalReview.reviewQuestion.optionSelected(reviewContainer);
            toggleCheckbox(self);
        });

//        Ajax submission for checkBox question
        $('.new_review').on('ajax:success', function (event, xhr, status, error) {
            var redirect_url = xhr.redirect_url;
            if (redirect_url !== undefined && redirect_url !== '') {
                window.location = redirect_url;
            }
            var reviewContainer = $(this).parents('.js-topicalReviewContainer');
            $(reviewContainer).addClass('js-reviewComplete');
            var carousel = $('.js-reviewQuestionCarousel')
            carousel.slick('slickNext')
        }).on('ajax:error', function (event, xhr, status, error) {
            alert(xhr.responseText);
        });
    };

    return {
        init: init
    }

})();

GS.topicalReview.questionCarousel = (function () {

    var getSlideIdForFirstTopicQuestion = function (topicId) {
        var topicSelector = '.js-topicalReviewContainer[data-review-topic="' + topicId + '"]';
        var matchingQuestions = $(topicSelector);
        var topicQuestions = filterOutClonedQuestions(matchingQuestions);
        var question = topicQuestions.first();
        return question.data('slickIndex') || 0;
    }

    var filterOutClonedQuestions = function (matchingQuestions) {
        return $(matchingQuestions).filter(function () {
            return !$(this).hasClass('slick-cloned')
        })
    }

    var getTopicId = function () {
        return GS.uri.Uri.getHashValue().slice(5);
    }

    var init = function () {

        var $questionCarousel = $('.js-reviewQuestionCarousel').slick({
            infinite: true,
            speed: 300,
            slidesToShow: 1,
            adaptiveHeight: true,
            draggable: false,
            appendArrows: ".js-topicalQuestionNavigation",
            prevArrow: ".js-previous-topic",
            nextArrow: ".js-next-topic"
        });

        var topicId = getTopicId();
        var slideId = getSlideIdForFirstTopicQuestion(topicId);
        $questionCarousel.slick('slickGoTo', Number(slideId));
    };

    return {
        init: init
    }
})();

GS.topicalReview.characterCount = (function () {
    var TOPICAL_REVIEW_CONTAINER = '.js-topicalReviewContainer';
    var CHARACTER_MESSAGE_DISPLAY = '.js-reviewCharacterDisplay';
    var CHARACTER_COUNT_DISPLAY = '.js-reviewCharacterCount'
    var MAX_CHARACTERS = 2400;

    var init = function (textField) {
        var reviewContainer = $(textField).parents(TOPICAL_REVIEW_CONTAINER);
        var characterDisplay = $(CHARACTER_MESSAGE_DISPLAY);
        var characterCountDisplay = $(reviewContainer).find(CHARACTER_COUNT_DISPLAY);
        var characterCount = textField.value.length;
        var maxCharacters = MAX_CHARACTERS;
        var remainingCharacters = maxCharacters - characterCount;
        if (characterCount > 0) {
            $(characterDisplay).show();
            $(characterCountDisplay).text(remainingCharacters);
        }
        else {
            $(characterDisplay).hide();
        }
    };

    return {
        init: init
    }
})();

GS.topicalReview.radioButton = GS.topicalReview.radioButton || (function () {

    var RADIO_BUTTON = '.js-topicalRadioButton';

    var init = function () {
        $(RADIO_BUTTON).on('change', function () {
            var self = $(this);
            var reviewContainer = self.parents('.js-topicalReviewContainer');
            showCommentField(reviewContainer);
        });
    };

    var showCommentField = function (reviewContainer) {
        $(reviewContainer).find('.js-gs-results-snapshot').hide();
        $(reviewContainer).find('.js-topicalReviewComment').show();
    };

    return {
        init: init
    };
})();

$(function () {

    GS.topicalReview.radioButton.init();

    GS.topicalReview.starRating.applyStarRating('.js-topicalReviewStars', '#js-topicalOverallRating');

    GS.topicalReview.checkBoxes.init();

    GS.topicalReview.questionCarousel.init();
});


