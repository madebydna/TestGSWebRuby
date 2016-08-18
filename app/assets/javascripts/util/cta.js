GS.school_profiles = GS.school_profiles || {};

GS.school_profiles.CTA = GS.school_profiles.CTA || (function () {
      var cta_profile_offset;
      var cta;
      var transitionToMobile = 767;

      var init = function () {
        cta_profile_offset = 0;
        cta = $("#cta");

        // only init when cta is on the page. :)
        if (cta.val() !== undefined) {
          // set listener to scroll and resize events
          $(window).on('scroll', _.throttle(manageFixedPositions, 50));
          $(window).on('resize', _.debounce(recalculateCtaResize, 100));
          // may also need to call this after ads load...
          recalculateCtaResize();
        }
      };

      var recalculateCtaResize = function () {
        cta_profile_offset = cta.parent().offset().top;
        if ($(window).width() > transitionToMobile) {
          setCTARowHeightToParent();
    }
    else {
          $("#cta").parent().height('auto');
    }
        manageFixedPositions();
      };

      var setCTARowHeightToParent = function () {
        cta.parent().height(cta.parent().parent().height());
      };

      var manageFixedPositions = function () {
        // console.log("cta_profile_offset:" + cta_profile_offset);
        // console.log("scrolltop:" + $(window).scrollTop());
        // cta_profile_offset = offset from top of window to cta
        // window.scrolltop = current scroll position of page
        if ($(window).width() > transitionToMobile) {
          if (cta_profile_offset <= $(window).scrollTop()) {
            // after cta is scrolled to the top
            //  console.log("cta.parent().height():" + cta.parent().height());
            //  console.log("cta.height():" + cta.height());
            //  console.log("cta_profile_offset:" + cta_profile_offset);
            var ctaBottomOffset = cta.parent().height() - cta.height() + cta_profile_offset;

            if (ctaBottomOffset <= $(window).scrollTop()) {
              // desktop align to the bottom of the right rail when scroll reaches bottom of right rail
              cta.removeClass('fixed-top').removeClass('non-fixed-top').addClass('align-bottom');
            }
            else {
              // desktop fix cta to top when scroll reaches the top of window
              cta.removeClass('non-fixed-top').removeClass('align-bottom').addClass('fixed-top');
            }
          }
          else {
            // desktop default before cta is scrolled to the top
            cta.removeClass('fixed-top').removeClass('align-bottom').addClass('non-fixed-top');
          }
        }
        else {
          cta.removeClass('fixed-top').removeClass('align-bottom').removeClass('non-fixed-top');
        }
      };

      return {
        init: init
      };
    })();

$(function () {
  GS.school_profiles.CTA.init();
});