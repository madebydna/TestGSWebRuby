import 'util/deprecated_parsley';
import { loadFacebook } from 'util/facebook_loader';
import ReactOnRails from 'react-on-rails';
import { preserveLanguageParam } from 'util/i18n';
import { signinToFacebookThenGreatSchools } from 'components/facebook_auth';
import SearchBox from 'react_components/search_box';
import withViewportSize from 'react_components/with_viewport_size';
import commonPageInit from './common';

const SearchBoxWrapper = withViewportSize({ propName: 'size' })(SearchBox);
ReactOnRails.register({
  SearchBoxWrapper,
});

$(commonPageInit);
loadFacebook();


  $(function() {
    const $joinForm = $('.js-join-form');
    const $signinForm = $('.js-signin-form');
    const $joinSubmitButton = $joinForm.find('button[type="submit"]');
    const $signinSubmitButton = $signinForm.find('button');

    const preventInteractions = function preventInteractions() {
      $joinSubmitButton.prop('disabled', true);
      $signinSubmitButton.prop('disabled', true);
    };

    const allowInteractions = function allowInteractions() {
      $joinSubmitButton.prop('disabled', false);
      $signinSubmitButton.prop('disabled', false);
    };

    const facebookSignInSuccessHandler = function facebookSignInSuccessHandler(data) {
      window.location.pathname = preserveLanguageParam('/account/');
    };

    const facebookSignInFailHandler = function facebookSignInFailHandler(data) {
      let defaultMessage = 'Oops! There was an error signing into your facebook account.';
      $('.js-facebook-signin-errors').html(data || defaultMessage);
    };

    $('.join-and-login').on('click', '.js-facebook-signin', function() {
      preventInteractions();

      signinToFacebookThenGreatSchools().
        done(facebookSignInSuccessHandler).
        fail(facebookSignInFailHandler).
        always(allowInteractions);

      return false;
    });
  });

  const showJoin = function showJoin() {
    let $loginTab = $('#login-tab');
    let $joinTab = $('#join-tab');
    $loginTab.removeClass('active in');
    $joinTab.addClass('active in');
  };

  const showLogin = function showLogin() {
    let $loginTab = $('#login-tab');
    let $joinTab = $('#join-tab');
    $joinTab.removeClass('active in');
    $loginTab.addClass('active in');
  };

  $(function () {
    if (location.hash.substr(1) === "join") {
      showJoin();
    }

    $('.js_login_tab').on('click',function(){
        location.hash = '';
        showLogin();
        return false;
    });

    $('.js_join_tab').on('click',function(e){
        location.hash = 'join';
        showJoin();
        return false;
    });



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
        url: "/gsr/validations/validate_user_can_log_in",
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