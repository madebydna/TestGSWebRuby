if(gon.pagename == 'reviews/new'){

    var GS = GS || {};
    GS.form = GS.form || {};
    GS.form.starRating = (function() {
        var YELLOW_STAR_SELECTOR = 'i-24-orange-star';
        var GREY_STAR_SELECTOR = 'i-24-grey-star';
        var INDIVIDUAL_STAR_SELECTOR = '.review-star';

        var labelFromRating = function(rating) {
            label = 'Click on stars to rate';
            if (rating == 1) {
                label = 'Unsatisfactory';
            } else if (rating == 2) {
                label = 'Below average';
            } else if (rating == 3) {
                label = 'Average';
            } else if (rating == 4) {
                label = 'Above average';
            } else if (rating == 5) {
                label = 'Excellent';
            }

            return label;
        };

        var applyStarRating = function(container, hiddenField, textLabel) {

            var selectStar = function(rating) {
                $(container).find(INDIVIDUAL_STAR_SELECTOR).each(function(index) {
                    if (index < rating) {
                        $(this).addClass(YELLOW_STAR_SELECTOR);
                        $(this).removeClass(GREY_STAR_SELECTOR);
                    } else {
                        $(this).addClass(GREY_STAR_SELECTOR);
                        $(this).removeClass(YELLOW_STAR_SELECTOR);
                    }

                    $(textLabel).text(labelFromRating(rating));
                });
            };

            $(container).on('click', INDIVIDUAL_STAR_SELECTOR, function() {
                $this = $(this);
                var rating = $this.index() + 1;
                $(hiddenField).val(rating);
                selectStar(rating);
                $(hiddenField).parsley( 'validate' );
            });

            $(container).on('mouseover', INDIVIDUAL_STAR_SELECTOR, function() {
                selectStar($(this).index() + 1);
            });

            $(container).on('mouseout', function() {
                selectStar($(hiddenField).val());
            });
        };

        return {
            applyStarRating: applyStarRating
        }

    })();


    $(function () {
        GS.form.starRating.applyStarRating('.js-review-rating-stars', '#overall_rating', '.js-review-rating-label');

        $( '#new_school_rating' ).parsley( {
            excluded: '', // don't exclude hidden fields, since we want to validate the stars
            successClass: 'has-success',
            errorClass: 'has-error'
        } );


        $( '#new_school_rating' ).parsley( 'addListener', {
            onFieldError: function ( elem ) {
                elem.closest('.form-group').addClass('has-error');
            },
            onFieldSuccess: function ( elem ) {
                elem.closest('.form-group').removeClass('has-error');
                //elem.closest('.form-group').addClass('has-success');
            }
        } );
    });
}