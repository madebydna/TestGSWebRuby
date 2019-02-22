import ReactOnRails from "react-on-rails";
import District from "./react_components/community/district";
import City from "./react_components/community/city";
import commonPageInit from './common';

ReactOnRails.register({
  District,
  City
});

$(() => {
  commonPageInit();
  $('body').on('click', '.js-test-score-details', function () {
    var grades = $(this).closest('.bar-graph-display').parent().find('.grades');
    if(grades.css('display') == 'none') {
      grades.slideDown();
      $(this).find('span').removeClass('rotate-text-270');
    }
    else{
      grades.slideUp();
      $(this).find('span').addClass('rotate-text-270');
    }
  });
});