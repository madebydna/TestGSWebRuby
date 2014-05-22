if(gon.pagename == 'signin/new'){

    $(function () {
        
        if (location.hash.substr(1) == "join") {
            $('.tab-pane').button('toggle');
            $('.js-login-tab').button('toggle');
            $('.js-join-tab').button('toggle');
        }

        $('#js_login_tab').on('click',function(){
            //Since we are sending data to omniture asynchronously on clicking of the tabs,
            //do not modify the underlying global GS.track.baseOmnitureObject. Instead clone it, set
            // variables on the clone and send to omniture.
            var omnitureObject = GS.track.getOmnitureObject();
            omnitureObject.pageName = 'GS:Admin:Login';
            omnitureObject.hier1 = 'Account,LogIn';
            sendToOmniture(omnitureObject);
            location.hash = '';
        });

        $('#js_join_tab').on('click',function(){
            //Since we are sending data to omniture asynchronously on clicking of the tabs,
            //do not modify the underlying global GS.track.baseOmnitureObject. Instead clone it, set
            // variables on the clone and send to omniture.
            var omnitureObject = GS.track.getOmnitureObject();
            omnitureObject.pageName = 'GS:Admin:CreateAccount';
            omnitureObject.hier1 = 'Account,SignUp';
            sendToOmniture(omnitureObject);
            location.hash = '#join';
        });

        var sendToOmniture = function(omnitureObject){
            var s_code = s.t(omnitureObject);
            if (s_code)document.write(s_code);
        };

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