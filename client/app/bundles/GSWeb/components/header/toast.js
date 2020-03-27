import { readCookie } from './utils';

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
    toast.innerHTML =
      "<div class='opensans-semibold'>We’re here for you. <a href='/gk/coronavirus-school-closure-support/'>Find our latest COVID-19 school closure resources here.</a><span class='toast-cancel'>X</span></div>";
    body.append(toast);
    activateListeners();
  }
}

const activateListeners = () => {
  document.querySelector('.toast-cancel').addEventListener('click', (e) => {
    document.cookie = "declineToast=true;expires=0;path=/";
    closeToast(e.target.parentElement)
  })
}

const closeToast = (node) =>{
  node.classList.add('dn');
}


export { init };