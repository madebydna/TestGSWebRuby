var cta_profile_offset;
$(function () {
  $(window).on('scroll', _.throttle(manageFixedPositions, 100));
  // may also need to call this after ads load...
  recaluculateOffsetForCTA();
  $(window).on('resize', _.debounce(recaluculateOffsetForCTA, 100));
});

function recaluculateOffsetForCTA() {
  cta_profile_offset = $("#cta").offset().top + 30;
}


function manageFixedPositions() {
  // console.log("throttle execute");

  // console.log("cta_profile_offset:"+cta_profile_offset);
  var cta = $("#cta");
  // console.log("offset:"+cta.offset().top);
  // console.log("scrollTop"+$(window).scrollTop());
  if (cta_profile_offset <= $(window).scrollTop()) {
    // after cta is scrolled to the top
    var ctaBottomOffset = cta.parent().height() - cta.height() - 60 + cta_profile_offset;
    // console.log('ctaBottomOffset:'+ctaBottomOffset);
    // console.log('scrolltop:'+$(window).scrollTop());

    if (ctaBottomOffset <= $(window).scrollTop()) {
      cta.removeClass('cta-fixed-top');
      cta.removeClass('cta-non-fixed-top');
      cta.addClass('cta-align-bottom');
    }
    else {
      cta.removeClass('cta-non-fixed-top');
      cta.removeClass('cta-align-bottom');
      cta.addClass('cta-fixed-top');
    }
  }
  else {
    // before cta is scrolled to the top
    cta.removeClass('cta-fixed-top');
    cta.removeClass('cta-align-bottom');
    cta.addClass('cta-non-fixed-top');
  }

  //
  // console.log("cta_profile_offset:"+cta_profile_offset);
  // console.log("scrolltop:"+$(window).scrollTop());
  // console.log("parentHeight:"+parentHeight);
  // console.log("cta height:"+cta.height());

//  when we reach top most point for cta and ad - add a class to fix them.
// Then when we scroll within a distance of the map or footer we remove the fixed position and
// have the components align to the bottom of the column
//
//  wait another idea - when the column or parent hits the top we fix our positions
//  when we are a certain distance from the bottom of the column we remove fixed and
//  align to the bottom of the column. - so we base everything on the columns position.
}