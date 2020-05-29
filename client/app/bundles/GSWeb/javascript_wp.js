import { init as toastInit } from 'components/header/toast';
import { isSignedIn } from './util/session';

toastInit();

const newsletterLinkSelector = '.js-send-me-updates-button-footer';

if (isSignedIn()) {
  if (currentLocale() === 'en') {
    document.querySelector(newsletterLinkSelector).innerText = "Email Preferences"
  } else if (currentLocale() === 'es') {
    document.querySelector(newsletterLinkSelector).innerText = "Preferencias de correo electrónico"
  }
}