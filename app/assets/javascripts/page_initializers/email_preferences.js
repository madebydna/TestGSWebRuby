
$(function() {
    if (gon.pagename == "User Email Preferences") {
      var $formContainer = $('.js-user-preferences-form-container');

      $formContainer.find('.js-checkbox').on('click', function() {
        $(this)
          .toggleClass('active')
          .toggleClass('i-16-blue-check-box i-grey-unchecked-box');
      });

      $formContainer.find('form').on('submit', function() {
        var $form = $(this);
        $form.find('div.active input').each(function() {
          $(this).prop('disabled', false);
        });
      });

      $formContainer.on('click', '.js-greatkidsnews-grades-checkbox:not(.active)', function() {
        var $greatkidsnewsCheckbox = $('.js-greatkidsnews-checkbox');
        if (!($greatkidsnewsCheckbox.hasClass('active'))) {
          $greatkidsnewsCheckbox.trigger('click');
        }
      });

      $formContainer.on('click', '.js-greatkidsnews-grades-checkbox.active', function () {
        var $greatkidsnewsCheckbox = $('.js-greatkidsnews-checkbox');
        var activeItems = $('.js-greatkidsnews-grades-checkbox.active');
        if (activeItems.length < 2 && $greatkidsnewsCheckbox.hasClass('active')) {
          $greatkidsnewsCheckbox.trigger('click');
        }
      });
    }
});
