if(gon.pagename == 'signin/new'){

    $(function () {
        $('.js-join-form').parsley({
            excluded: '', // don't exclude hidden fields, since we want to validate the stars
            successClass: 'has-success',
            errorClass: 'has-error',
            errors: {
                errorsWrapper: '<div></div>',
                errorElem: '<div></div>'
            }

        });
        $('.js-signin-form').parsley({
            excluded: '', // don't exclude hidden fields, since we want to validate the stars
            successClass: 'has-success',
            errorClass: 'has-error',
            errors: {
                errorsWrapper: '<div></div>',
                errorElem: '<div></div>'
            }
        });

        $('.js-join-form').parsley('addListener', {
            onFieldError: function (elem) {
                elem.closest('.form-group').addClass('has-error');
            },
            onFieldSuccess: function (elem) {
                elem.closest('.form-group').removeClass('has-error');
            }
        });

        $('.js-signin-form').parsley('addListener', {
            onFieldError: function (elem) {
                elem.closest('.form-group').addClass('has-error');
            },
            onFieldSuccess: function (elem) {
                elem.closest('.form-group').removeClass('has-error');
            }
        });


    });

}