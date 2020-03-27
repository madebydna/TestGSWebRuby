import { readCookie } from './utils';
import { t } from 'util/i18n';

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
    toast.innerHTML = t('toast.coronavirus_html')
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
  // window.addEventListener('scroll')
}

const closeToast = (node) =>{
  node.classList.add('dn');
}

const fireoffAnalytics = (pathName) => {
  analyticsEvent(
    'interaction',
    'Clicked Promo Banner',
    pathName
  )
}


const readjustToastHeight = () => {

}


export { init };