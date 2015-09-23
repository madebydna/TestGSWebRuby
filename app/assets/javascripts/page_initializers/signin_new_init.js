if(gon.pagename == 'signin/new'){

    var JOIN_PAGENAME = 'GS:Admin:CreateAccount';
    var JOIN_HIER = 'Account,SignUp';
    var SIGNIN_PAGENAME = 'GS:Admin:Login';
    var SIGNIN_HIER = 'Account,LogIn';

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
            omnitureObject.pageName = SIGNIN_PAGENAME;
            omnitureObject.hier1 = SIGNIN_HIER;
            sendToOmniture(omnitureObject);
            location.hash = '';
        });

        $('#js_join_tab').on('click',function(){
            //Since we are sending data to omniture asynchronously on clicking of the tabs,
            //do not modify the underlying global GS.track.baseOmnitureObject. Instead clone it, set
            // variables on the clone and send to omniture.
            var omnitureObject = GS.track.getOmnitureObject();
            omnitureObject.pageName = JOIN_PAGENAME;
            omnitureObject.hier1 = JOIN_HIER;
            sendToOmniture(omnitureObject);
            location.hash = '#';
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


        //TODO do this using parsley.remote.js after updating parsley version.
        $('#email').on('blur', function() {
            $.ajax({
            type: 'GET',
            url: "/gsr/validations/email_provisional",
            data: {email: $('.js-signin-form #email').val()},
            dataType: 'json',
            async: true
        }).done(function (data) {
              var $emailErrorsElem = $('.js-signin-email-errors');
              var $emailFormGroup = $emailErrorsElem.closest('.form-group');

              $emailErrorsElem.empty();
              $emailFormGroup.removeClass('has-error');
              if (data.error_msg && data.error_msg !== '') {
                $emailFormGroup.addClass('has-error');
                $emailErrorsElem.append("<div class='parsley-error-list'><div class='required' style='display: block;'>"+data.error_msg+"</div></div>");
              }

          });
        });

    });

}