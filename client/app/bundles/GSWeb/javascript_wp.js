import { isSignedIn } from 'util/session';
import { currentLocale } from 'util/i18n';

const newsletterLinkSelector = '.js-send-me-updates-button-footer';

if (isSignedIn()) {
  if (currentLocale() === 'en') {
    document.querySelector(newsletterLinkSelector).innerText = "Email Preferences"
  } else if (currentLocale() === 'es') {
    document.querySelector(newsletterLinkSelector).innerText = "Preferencias de correo electrónico"
  }
}