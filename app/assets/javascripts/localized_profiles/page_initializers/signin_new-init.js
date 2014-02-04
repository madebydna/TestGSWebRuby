if(gon.pagename == 'signin/new'){

    GS.track.set_common_omniture_data();

    $(function () {
        $('#js_login_tab').on('click',function(){
            //Since we are sending data to omniture asynchronously on clicking of the tabs,
            //do not modify the underlying global GS.track.base_omniture_object. Instead clone it, set
            // variables on the clone and send to omniture.
            var omniture_object = GS.track.get_omniture_object();
            omniture_object.pageName = 'GS:Admin:Login';
            omniture_object.hier1 = 'Account,LogIn';
            send_asynchronously_to_omniture(omniture_object);
        });

        $('#js_signin_tab').on('click',function(){
            //Since we are sending data to omniture asynchronously on clicking of the tabs,
            //do not modify the underlying global GS.track.base_omniture_object. Instead clone it, set
            // variables on the clone and send to omniture.
            var omniture_object = GS.track.get_omniture_object();
            omniture_object.pageName = 'GS:Admin:CreateAccount';
            omniture_object.hier1 = 'Account,SignUp';
            send_asynchronously_to_omniture(omniture_object);
        });

        var send_asynchronously_to_omniture = function(omniture_object){
            var s_code = s.t(omniture_object);
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