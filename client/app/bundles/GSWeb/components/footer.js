import {
  signupAndGetNewsletter,
  signUpForGreatNewsAndMss
} from '../util/newsletters';
import * as validatingInputs from 'components/validating_inputs';
import { attachJQueryEventHandlers as attachMultiSelectButtonGroupEventHandlers } from 'util/multi_select_button_group';

import { translateWithDictionary, currentLocale } from 'util/i18n';

const newsletterLinkSelector = '.js-send-me-updates-button-footer';

const t = translateWithDictionary({
  es: {
    "Send me email updates about my child's school":
      'Envíeme actualizaciones por correo electrónico sobre la escuela de mi hijo'
  }
});

export function setupNewsletterLink() {
  $(() => {
    validatingInputs.addFilteringEventListener('body');
    attachMultiSelectButtonGroupEventHandlers();
  })


  $(newsletterLinkSelector).on('click', () => {
    let stateAbbreviation;
    let schoolId;

    if (window.gon && window.gon.school) {
      stateAbbreviation = gon.school.state;
      schoolId = gon.school.id;
    }

    if (schoolId && stateAbbreviation) {
      signUpForGreatNewsAndMss(
        {
          heading: t("Send me email updates about my child's school")
        },
        stateAbbreviation,
        schoolId
      );
    } else {
      if (currentLocale() == 'es'){
        let win = window.open("https://pub.s1.exacttarget.com/bkt2mldejgh", '_blank');
        win.focus();
      }
      else{
        signupAndGetNewsletter();
      }
    }
  });
}
