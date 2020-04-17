
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

      function changeGbyGState(overallGbyGCheckbox, changeToActive) {
        if (changeToActive) {
          overallGbyGCheckbox.removeClass('i-grey-unchecked-box');
          overallGbyGCheckbox.addClass('active');
          overallGbyGCheckbox.addClass('i-16-blue-check-box');
        } else {
          overallGbyGCheckbox.removeClass('active');
          overallGbyGCheckbox.removeClass('i-16-blue-check-box');
          overallGbyGCheckbox.addClass('i-grey-unchecked-box');
        }
      }

      $formContainer.on('click', '.js-gradeCheckbox', function () {
        let activeGbyG = $(this).parent().parent().find('.active');
        let overallCheckboxParent = $(this).parent().parent().parent().siblings();
        let overallCheckbox = overallCheckboxParent.find('.js-greatkidsnewsCheckbox');
        if (activeGbyG.length == 1) {
          if ($(this).hasClass('active')) {
            changeGbyGState(overallCheckbox, false)
          }
        }
        if (activeGbyG.length == 0) {
          changeGbyGState(overallCheckbox, true)
        }
      });

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

        $form.find('.js-mssSubscriptionCheckbox.active').each(function () {
          schools.push([$(this).data('list'), $(this).data('language'), $(this).data('state'), $(this).data('schoolId')]);
        });
        $('.js-schoolSubmitValue').val(JSON.stringify(schools));

        $form.find('.js-inverted-checkbox').each(function() {
          $(this).toggleClass('active');
        });

        $form.find('div.active input').each(function() {
          $(this).prop('disabled', false);
        });
      });

    }
});
