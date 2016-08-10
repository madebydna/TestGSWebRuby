
$(function() {
    if (gon.pagename == "User Email Preferences") {
      $('.js-user-preferences-form-container .js-checkbox').on('click', function() {
        $(this)
          .toggleClass('active')
          .toggleClass('i-16-blue-check-box i-grey-unchecked-box');
      });

      $('.js-user-preferences-form-container form').on('submit', function() {
        var $form = $(this);
        $form.find('div.active input').each(function() {
          $(this).prop('disabled', false);
        });
      });

      $('.js-user-preferences-form-container').on('click', '.js-greatkidsnews-grades-checkbox:not(.active)', function() {
        var $greatkidsnewsCheckbox = $('.js-greatkidsnews-checkbox');
        if (!($greatkidsnewsCheckbox.hasClass('active'))) {
          $greatkidsnewsCheckbox.trigger('click');
        }
      });

      $('.js-user-preferences-form-container').on('click', '.js-greatkidsnews-grades-checkbox.active', function () {
        var $greatkidsnewsCheckbox = $('.js-greatkidsnews-checkbox');
        var activeItems = $('.js-greatkidsnews-grades-checkbox.active');
        if (activeItems.length < 2) {
          $greatkidsnewsCheckbox.trigger('click');
        }
      });
    }
});
