import ReactOnRails from 'react-on-rails';
import configureStore from './store/appStore';
import Search from './react_components/search/search';
import CollegeSuccessAward from './react_components/college_success_award';
import commonPageInit from './common';

window.store = configureStore({
  search: gon.search
});

ReactOnRails.register({
  Search,
  CollegeSuccessAward
});

const popupCenter = (url, title, w, h) => {
  // Fixes dual-screen position                         Most browsers      Firefox
  const dualScreenLeft = window.screenLeft !== undefined ? window.screenLeft : screen.left;
  const dualScreenTop = window.screenTop !== undefined ? window.screenTop : screen.top;

  const width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? document.documentElement.clientWidth : screen.width;
  const height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : screen.height;

  const left = ((width / 2) - (w / 2)) + dualScreenLeft;
  const top = ((height / 2) - (h / 2)) + dualScreenTop;
  const newWindow = window.open(url, title, 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,width=' + w + ',height=' + h + ',top=' + top + ',left=' + left);

  // Puts focus on the newWindow
  if (window.focus) {
    newWindow.focus();
  }
}

const touchDevice = () => (('ontouchstart' in window) || (navigator.maxTouchPoints > 0) || (navigator.msMaxTouchPoints > 0));

/**
 * ! Please do not use jQuery to add new event handlers
 * Currently this is required since we're rendering react components
 * as a string and passing that to Tipso, in which case any
 * events added via React don't persist. 
 */
$('body').on('click', '.js-emailSharingLinks', function () {
  window.location.href = ($(this).data("link"));
  return false;
})

/**
 * ! Please do not use jQuery to add new event handlers
 * Currently this is required since we're rendering react components
 * as a string and passing that to Tipso, in which case any
 * events added via React don't persist. 
 */
$('body').on('click', '.js-sharingLinks', function () {
  var url = $(this).data("link")
  if($(this).data("url") !== undefined) {
    url += encodeURIComponent($(this).data("url"));
  }
  if($(this).data("siteparams") !== undefined) {
    url +=  $(this).data("siteparams");
  }
  popupCenter(url, $(this).data("type"), 700, 300)
  return false;
})

/**
 * ! Please do not use jQuery to add new event handlers
 * Currently this is required since we're rendering react components
 * as a string and passing that to Tipso, in which case any
 * events added via React don't persist. 
 */
$('body').on('click', '.js-permaLink', function () {
  if(!touchDevice()) {
    $(this).focus();
    $(this).select();
    document.execCommand("copy");
    $(this).siblings().css('display', 'block');
  }
  return false;
});

$(commonPageInit());
