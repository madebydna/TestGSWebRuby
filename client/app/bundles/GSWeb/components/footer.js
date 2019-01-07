import { signupAndGetNewsletter } from '../util/newsletters';
import { translateWithDictionary } from 'util/i18n';

const newsletterLinkSelector = '.js-send-me-updates-button-footer';

const t = translateWithDictionary({
  es: {
    "Send me email updates about my child's school":
      'Envíeme actualizaciones por correo electrónico sobre la escuela de mi hijo'
  }
});

export function setupNewsletterLink() {
  $(newsletterLinkSelector).on('click', () => {
    let stateAbbreviation;
    let schoolId;

    if (window.gon && window.gon.school) {
      stateAbbreviation = gon.school.state;
      schoolId = gon.school.id;
    }

    if (schoolId && stateAbbreviation) {
      signupAndGetNewsletter({
        heading: t("Send me email updates about my child's school")
      });
    } else {
      signupAndGetNewsletter();
    }
  });
}
