
$(function() {
    if (gon.pagename == "User Email Preferences") {
      var $formContainer = $('.js-user-preferences-form-container');

      $formContainer.find('.js-checkbox').on('click', function() {
        $(this)
          .toggleClass('active')
          .toggleClass('i-16-blue-check-box i-grey-unchecked-box');
      });

      $('#tab-news-en').click(function() {
        $("#news-en").addClass("active");
        $(this).addClass("tab-selected");
        $("#news-es").removeClass("active");
        $("#tab-news-es").removeClass("tab-selected");
      });

      $('#tab-news-es').click(function() {
        $("#news-es").addClass("active");
        $(this).addClass("tab-selected");
        $("#news-en").removeClass("active");
        $("#tab-news-en").removeClass("tab-selected");
      });

      $formContainer.on('click', '.js-greatkidsnewsCheckbox', function() {
        if (!$(this).hasClass('active')) {
          $(this).parent().siblings().find('.js-gradeCheckbox').each(function() {
            $(this).removeClass('active');
          })
        }
      });

      // $formContainer.find('.js-gradeCheckbox').each(function() {
      //   if (!$(this).hasClass('active')) {
      //     let siblings = $(this).siblings().find('.js-gradeCheckbox.active');
      //     if (siblings.length < 1) {
      //       let parentCheckbox = $(this).parent().siblings().find('.js-greatkidsnewsCheckbox');
      //       parentCheckbox.removeClass('active');
      //     }
      //   }
      // });

      $formContainer.find('form').on('submit', function() {
        let $form = $(this);
        let grades = [];
        let subscriptions = [];
        let schools = [];

        $form.find('.js-gradeCheckbox.active').each(function () {
          grades.push([$(this).data('grade'), $(this).data('language'), $(this).data('districtId'), $(this).data('districtState')]);
        });
        $('.js-gradeSubmitValue').val(JSON.stringify(grades));

        $form.find('.js-subscriptionCheckbox.active').each(function () {
          subscriptions.push([$(this).data('list'), $(this).data('language')]);
        });
        $('.js-subscriptionSubmitValue').val(JSON.stringify(subscriptions));

        console.log("form: " + $('.js-subscriptionSubmitValue').val());

        $form.find('.js-mssSubscriptionCheckbox.active').each(function () {
          schools.push([$(this).data('list'), $(this).data('language'), $(this).data('state'), $(this).data('schoolId')]);
        });
        $('.js-schoolSubmitValue').val(JSON.stringify(schools));

        console.log("schools: " + $('.js-schoolSubmitValue').val());


        $form.find('.js-inverted-checkbox').each(function() {
          $(this).toggleClass('active');
        });

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
