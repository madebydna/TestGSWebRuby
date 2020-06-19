import { readCookie } from './utils';
import iconClose from 'icons/times-solid-white.svg';

export const init = () => {
  const declineBanner = readCookie('declineBanner');

  if(!declineBanner){
    const header = document.querySelector('.un.clearfix');

    const banner = document.createElement('div');

    banner.id = 'home-page-banner';

    banner.innerHTML = `<span class="title col-sm-offset-2 col-md-offset-3 col-lg-offset-2">We stand in solidarity with</span>\
      Black Lives Matter. <a class="banner-link" href = "https://blog.greatschools.org/2020/06/05/1220/">Here's what we\'re doing.\
      </a><img src="${iconClose}" class="banner-cancel"/>`;

    header.parentNode.insertBefore(banner, header.nextSibling);

    if (window.innerWidth < 768) {
      const hero = document.querySelector('.dark-gray-bg.pr');
      const height = document.querySelector('#home-page-banner').offsetHeight;
      hero.style.marginTop = `${height}px`;
      activateRemoveMarginListener(hero);
    }

    activateListeners();
  }
}

const activateListeners = () => {
  document.querySelector('.banner-cancel').addEventListener('click', () => {
    const banner = document.querySelector('#home-page-banner');
    document.cookie = "declineBanner=true;expires=0;path=/";
    banner.classList.add('dn');
  })

  document.querySelector('.banner-link').addEventListener('click', () => {
    fireoffAnalytics(window.location.pathname);
  });
}

const activateRemoveMarginListener = (hero) => {
  document.querySelector('.banner-cancel').addEventListener('click', () => {
    hero.style.marginTop = "0px";
  })
}

const fireoffAnalytics = (pathName) => {
  analyticsEvent(
    'interaction',
    'Clicked Homepage Promo Banner',
    pathName
  );
};
