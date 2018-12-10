import ReactOnRails from "react-on-rails";
import Compare from "./react_components/compare/compare";
import * as tooltips from "./util/tooltip";
import * as remodal from "./util/remodal";
import "./vendor/tipso";
import { init as initHeader } from "./header";

ReactOnRails.register({
  Compare
});

$(() => {
  initHeader();
  ReactOnRails.reactOnRailsPageLoaded();
  tooltips.initialize();
  remodal.init();
  // $('body').on('click', '.js-test-score-details', function () {
  //   var grades = $(this).closest('.bar-graph-display').parent().find('.grades');
  //   if (grades.css('display') == 'none') {
  //     grades.slideDown();
  //     $(this).find('span').removeClass('rotate-text-270');
  //   }
  //   else {
  //     grades.slideUp();
  //     $(this).find('span').addClass('rotate-text-270');
  //   }
  // });
});