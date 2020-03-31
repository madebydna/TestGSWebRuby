import { readCookie } from './utils';
import { translateWithDictionary } from 'util/i18n';
import { throttle } from 'lodash';

export const t = translateWithDictionary({
  en:{
    coronavirus_html: "<div class='opensans-semibold'>We’re here for you. <a class= 'toast-anchorlink' href='/gk/coronavirus-school-closure-support/'>Find our latest COVID- 19 school closure resources here.</a><span class='toast-cancel icon-close'/></div>"
  },
  es: {
    coronavirus_html: "<div class='opensans-semibold'> Estamos aqui para ti. <a class='toast-anchorlink' href='/gk/coronavirus-school-closure-support/?lang=es'> Aquí encontrarás nuestros últimos recursos para el cierre de escuelas por COVID-19. </a> <span class='toast-cancel icon-close'/></div>"
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
    }else{
      toast.style.top = 0;
    }
  }
}, 100);


export { init };