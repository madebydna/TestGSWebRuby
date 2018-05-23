import 'jquery';
import 'jquery.cookie';
import 'jquery-unveil';
import 'vendor/fastclick';
import 'vendor/remodal';
import { init as initHeader } from 'header';
import * as remodal from 'util/remodal';
import * as footer from 'components/footer';
import * as validatingInputs from 'components/validating_inputs';
import * as backToTop from 'components/back_to_top';

import desktop_home_image from 'home/slideshow/home_1600_6.jpg';
import mobile_home_image from 'home/slideshow/home_480_6.jpg';
import desktop_milestone_image from 'home/milestone_background-sm.jpg';
import mobile_milestone_image from 'home/milestone_background_mobile.jpg';
import { setupImages } from 'util/responsive_images';

$(function() {
  initHeader({includeFeatured: false});
  remodal.init();
  footer.setupNewsletterLink();
  setupImages(
    {
      selector: '.is-scaled',
      desktopImage: desktop_home_image,
      mobileImage: mobile_home_image,
      classes: 'scaling'
    }
  );
  setupImages(
    {
      selector: '.is-scaled-banner',
      desktopImage: desktop_milestone_image,
      mobileImage: mobile_milestone_image,
      classes: 'scaling'
    }
  );

  // TODO: duplicated in school_profiles.js. needs new home
  let $body = $('body');
  $body.on('click', '.multi-select-button-group button', function() {
    var $label = $(this);
    var $hiddenField = $label.closest('fieldset').find('input[type=hidden]');
    var values = $hiddenField.val().split(',');
    if ($hiddenField.val() == "") {
      values = [];
    }
    var value = $label.data('value').toString();
    var index = values.indexOf(value);
    if(index == -1) {
      values.push(value);
    } else {
      values.splice(index, 1);
    }
    $hiddenField.val(values.join(','));
    $label.toggleClass('active');
  });

  // TODO: duplicated in school_profiles.js. maybe needs new home
  validatingInputs.addFilteringEventListener('body');

  backToTop.init();
});

