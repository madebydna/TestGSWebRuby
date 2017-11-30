import { removeClass } from './utils';

const init = function() {
  var featuredSection = document.querySelector('.js-featured');
  if (featuredSection === null) {
    return;
  }
  var pathsWithoutNavSearch = ['/'];
  var i = pathsWithoutNavSearch.length;
  var matchesAnyPaths = false;
  while (i--) {
    if (pathsWithoutNavSearch[i] == window.location.pathname) {
      matchesAnyPaths = true;
    }
  }
  if (matchesAnyPaths == false) {
    removeClass(featuredSection, 'dn');
  }
}

export { init }
