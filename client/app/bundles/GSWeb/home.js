import commonPageInit from './common';
import 'js-cookie';
import 'vendor/fastclick';
import * as backToTop from 'components/back_to_top';

import desktop_home_image from 'home/slideshow/home_1600_6.jpg';
import mobile_home_image from 'home/slideshow/home_480_6.jpg';
import desktop_milestone_image from 'home/milestone_background-sm.jpg';
import mobile_milestone_image from 'home/milestone_background_mobile.jpg';
import { setupImages } from 'util/responsive_images';
import "jquery-unveil";
import SearchBox from 'react_components/search_box';
import withViewportSize from 'react_components/with_viewport_size';
import { t } from 'util/i18n';

const SearchBoxWrapper = withViewportSize({ propName: 'size' })(SearchBox);
ReactOnRails.register({
  SearchBoxWrapper,
});

$(function() {
  // $('#state-dropdown').on('change', function () {
  //   var url = $(this).val();
  //   if (url) {
  //     window.location = url;
  //   }
  //   return false;
  // });
  const dropdownList = document.querySelector('.dropdown-container ul')

  $('#home_state_select_wrapper .state-btn').on('click', function () {
    $('.dropdown-container ul').toggleClass('hide-state-list')
  });
  

  $('#show-more-for-footer').on('click', 'a', function(e) {
    e.preventDefault();
    var extraLinks = $('#home-city-footer').find('.extra');
    extraLinks.toggleClass('js-showing');
    
    if ($(this).text() == t('show_more')) {
      $(this).text(t('show_less'));
    } else {
      $(this).text(t('show_more'));
    }
  });

  commonPageInit({includeFeatured: false});
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

  backToTop.init();
});

