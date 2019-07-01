import { getState }  from 'store/appStore';
import { links } from '../components/links';

const qualarooLink = function(module) {
  let school = getState().school;
  if(school) {
    return links.qualaroo[module] + 
      '?state=' + school.state + 
      '&school=' + school.id;
  }
  return '';
}

// Collapses 
const minimizeNudges = function() {
  if(window.minimizeQualarooNudges) {
    window.minimizeQualarooNudges();
  }
}

const maximizeNudges = function() {
  // maximizes only if previous minimized
  if(window.maximizeQualarooNudges) {
    window.maximizeQualarooNudges();
  }
}


export { qualarooLink, minimizeNudges, maximizeNudges }
