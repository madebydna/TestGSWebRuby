import { readCookie } from './utils';
import iconClose from 'icons/times-solid-white.svg';

export const init = () => {
  const declineBanner = readCookie('declineBanner');

  if(!declineBanner){
    const header = document.querySelector('.un.clearfix');

    const banner = document.createElement('div');

    banner.id = 'home-page-banner';

    banner.innerHTML = `<span class="title">Black Lives Matter.&nbsp;</span>\
      Changes comes from within. <a class="link" href = "#">What we\'re doing\
      </a><img src="${iconClose}" class="banner-cancel"/>`;

    header.parentNode.insertBefore(banner, header.nextSibling);

    if (window.innerWidth < 768) {
      const hero = document.querySelector('.dark-gray-bg.pr');
      const height = document.querySelector('#home-page-banner').offsetHeight;
      hero.style.marginTop = `${height}px`;
      activateRemoveMarginListener(hero);
    }

    activateBannerCloseListener();
  }
}

const activateBannerCloseListener = () => {
  document.querySelector('.banner-cancel').addEventListener('click', () => {
    const banner = document.querySelector('#home-page-banner');
    document.cookie = "declineBanner=true;expires=0;path=/";
    banner.classList.add('dn');
  })
}

const activateRemoveMarginListener = (hero) => {
  document.querySelector('.banner-cancel').addEventListener('click', () => {
    hero.style.marginTop = "0px";
  })
}
