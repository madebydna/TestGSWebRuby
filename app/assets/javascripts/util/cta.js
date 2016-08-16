$(window).on('scroll', _.throttle(manageFixedPositions, 100));

function manageFixedPositions() {
  console.log("throttle execute");
//  when we reach top most point for cta and ad - add a class to fix them.
// Then when we scroll within a distance of the map or footer we remove the fixed position and
// have the components align to the bottom of the column
//
//  wait another idea - when the column or parent hits the top we fix our positions
//  when we are a certain distance from the bottom of the column we remove fixed and
//  align to the bottom of the column. - so we base everything on the columns position.
}