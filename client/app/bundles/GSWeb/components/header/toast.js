import { readCookie } from './utils';
import { translateWithDictionary } from 'util/i18n';
import { throttle } from 'lodash';
import iconClose from 'icons/times-solid.svg';

export const t = translateWithDictionary({
  en:{
    coronavirus_html: String.raw`<div class='toast-body opensans-semibold'>We’re here for you. <a class= 'toast-anchorlink' href='/gk/coronavirus-school-closure-support/'>Find COVID-19 at-home learning resources here.</a><img src='${iconClose}' class='toast-cancel'/></div>`
  },
  es: {
    coronavirus_html: String.raw`<div class='toast-body opensans-semibold'> Estamos aqui para ti. <a class='toast-anchorlink' href='/gk/coronavirus-school-closure-support/?lang=es'> Encuentra los recursos de aprendizaje en el hogar durante COVID-19 aquí. </a><img src='${iconClose}' class='toast-cancel'/></div>`
  }
});

const init = () => {
  const declineToast = readCookie('declineToast');
  const suppressToast = window.location.pathname.includes('/gk/coronavirus-school-closure-support/') || window.location.pathname.includes('/gk/recursos-durante-coronavirus/');

  if (!declineToast && !suppressToast){
    const body = document.querySelector('body');
    const header = document.querySelector('.header_un');
    let height;
    if(header){
      height = header.offsetHeight;
    }
    const toast = document.createElement('div');
    toast.classList.add('toast');
    toast.style.top = `${height || '65'}px`;
    toast.innerHTML = t('coronavirus_html');

    // target only the toast on profile page due to weird z-indexing from other modules
    if(gon && gon.ad_set_targeting && gon.ad_set_targeting.page_name === "GS:SchoolP"){
      const toastBody = toast.querySelector('.toast-body');
      if (window.innerWidth > 991 && window.innerWidth < 1100) {
        toastBody.style.maxWidth = '400px';
      } else if (window.innerWidth >= 1100) {
        toastBody.style.maxWidth = '575px';
      }
    }
    body.append(toast);
    activateListeners();
  }
};

const activateListeners = () => {
  document.querySelector('.toast-cancel').addEventListener('click', (e) => {
    document.cookie = "declineToast=true;expires=0;path=/";
    closeToast(e.target.parentElement);
  });

  document.querySelector('.toast-anchorlink').addEventListener('click', ()=> {
    fireoffAnalytics(window.location.pathname);
  });
  window.addEventListener('scroll', readjustToastHeight);
};

const closeToast = (node) =>{
  window.removeEventListener('scroll', readjustToastHeight);
  node.classList.add('dn');
};

const fireoffAnalytics = (pathName) => {
  analyticsEvent(
    'interaction',
    'Clicked Promo Banner',
    pathName
  );
};


const readjustToastHeight = throttle(() => {
  const ele = document.querySelector('.header_un');
  const toast = document.querySelector('.toast');

  if(toast){
    const headerBoundingBox = ele.getBoundingClientRect();
    if (headerBoundingBox.bottom > 0){
      toast.style.top = `${headerBoundingBox.bottom}px`;
    } else if(gon && gon.ad_set_targeting && gon.ad_set_targeting.page_name === "GS:SchoolP"){
      toast.style.top = '50px';
      toast.style.zIndex = 14;
    }else{
      toast.style.top = 0;
    }
  }
}, 100);


export { init };