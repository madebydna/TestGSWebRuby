import { readCookie } from './utils';
import { translateWithDictionary } from 'util/i18n';
import { throttle } from 'lodash';
import iconClose from 'icons/times-solid.svg';

// const iconClose = "<svg class='toast-cancel' aria-hidden='true' focusable='false' data-prefix='fas' data-icon='times' class='svg-inline--fa fa-times fa-w-11' role='img' xmlns='http://www.w3.org/2000/svg' viewBox='0 0 352 512'><path fill='#313639' fill-opacity='0.90' d='M242.72 256l100.07-100.07c12.28-12.28 12.28-32.19 0-44.48l-22.24-22.24c-12.28-12.28-32.19-12.28-44.48 0L176 189.28 75.93 89.21c-12.28-12.28-32.19-12.28-44.48 0L9.21 111.45c-12.28 12.28-12.28 32.19 0 44.48L109.28 256 9.21 356.07c-12.28 12.28-12.28 32.19 0 44.48l22.24 22.24c12.28 12.28 32.2 12.28 44.48 0L176 322.72l100.07 100.07c12.28 12.28 32.2 12.28 44.48 0l22.24-22.24c12.28-12.28 12.28-32.19 0-44.48L242.72 256z'></path></svg>"

export const t = translateWithDictionary({
  en:{
    coronavirus_html: String.raw`<div class='opensans-semibold'>We’re here for you. <a class= 'toast-anchorlink' href='/gk/coronavirus-school-closure-support/'>Find our latest COVID- 19 school closure resources here.</a><img src='${iconClose}' class='toast-cancel'/></div>`
  },
  es: {
    coronavirus_html: String.raw`<div class='opensans-semibold'> Estamos aqui para ti. <a class='toast-anchorlink' href='/gk/coronavirus-school-closure-support/?lang=es'> Aquí encontrarás nuestros últimos recursos para el cierre de escuelas por COVID-19. </a><img src='${iconClose}' class='toast-cancel'/></div>`
  }
})

const init = () => {
  const declineToast = readCookie('declineToast');

  if (!declineToast){
    const body = document.querySelector('body');
    const header = document.querySelector('.header_un');
    let height;
    if(header){
      height = header.offsetHeight;
    }
    const toast = document.createElement('div');
    toast.classList.add('toast')
    toast.style.top = `${height || '65'}px`;
    toast.innerHTML = t('coronavirus_html')
    body.append(toast);
    activateListeners();
  }
}

const activateListeners = () => {
  document.querySelector('.toast-cancel').addEventListener('click', (e) => {
    document.cookie = "declineToast=true;expires=0;path=/";
    closeToast(e.target.parentElement);
  })

  document.querySelector('.toast-anchorlink').addEventListener('click', ()=> {
    fireoffAnalytics(window.location.pathname);
  })
  window.addEventListener('scroll', readjustToastHeight)
}

const closeToast = (node) =>{
  debugger
  window.removeEventListener('scroll', readjustToastHeight);
  node.classList.add('dn');
}

const fireoffAnalytics = (pathName) => {
  analyticsEvent(
    'interaction',
    'Clicked Promo Banner',
    pathName
  )
}


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