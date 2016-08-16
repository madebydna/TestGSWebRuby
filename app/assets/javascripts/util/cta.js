var cta_profile_offset;
$(function () {
  $(window).on('scroll', _.throttle(manageFixedPositions, 50));
  // may also need to call this after ads load...
  recaluculateOffsetForCTA();
  $(window).on('resize', _.debounce(recaluculateOffsetForCTA, 100));
});

function recaluculateOffsetForCTA() {
  cta_profile_offset = $("#cta").offset().top + 30;
}


function manageFixedPositions() {
  var cta = $("#cta");

  if (cta_profile_offset <= $(window).scrollTop()) {
    // after cta is scrolled to the top
    var ctaBottomOffset = cta.parent().height() - cta.height() - 60 + cta_profile_offset;

    if (ctaBottomOffset <= $(window).scrollTop()) {
      cta.removeClass('cta-fixed-top').removeClass('cta-non-fixed-top').addClass('cta-align-bottom');
    }
    else {
      cta.removeClass('cta-non-fixed-top').removeClass('cta-align-bottom').addClass('cta-fixed-top');

    }
  }
  else {
    // before cta is scrolled to the top
    cta.removeClass('cta-fixed-top').removeClass('cta-align-bottom').addClass('cta-non-fixed-top');
  }

//  when we reach top most point for cta and ad - add a class to fix them.
// Then when we scroll within a distance of the map or footer we remove the fixed position and
// have the components align to the bottom of the column
//
//  wait another idea - when the column or parent hits the top we fix our positions
//  when we are a certain distance from the bottom of the column we remove fixed and
//  align to the bottom of the column. - so we base everything on the columns position.
}