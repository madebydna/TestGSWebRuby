import {
  signupAndGetNewsletter,
  signUpForGreatNewsAndMss
} from '../util/newsletters';
import * as validatingInputs from 'components/validating_inputs';
import { attachJQueryEventHandlers as attachMultiSelectButtonGroupEventHandlers } from 'util/multi_select_button_group';

import { currentLocale } from 'util/i18n';

const newsletterLinkSelector = '.js-send-me-updates-button-footer';

export function setupNewsletterLink() {
  $(() => {
    validatingInputs.addFilteringEventListener('body');
    attachMultiSelectButtonGroupEventHandlers();
  });

  $(newsletterLinkSelector).on('click', () => {
    let stateAbbreviation;
    let schoolId;

    if (window.gon && window.gon.school) {
      stateAbbreviation = gon.school.state;
      schoolId = gon.school.id;
    }

    if (schoolId && stateAbbreviation) {
      // let propsToPass = modalTopContent();
      // let successMessage = successMessageMSS();
      signUpForGreatNewsAndMss(
        modalTopContent(),
        stateAbbreviation,
        schoolId,
        successMessageMSS(),
        'en'
      );
    } else {
        signupAndGetNewsletter();
    }
  });

  function successMessageMSS(){
    if (currentLocale() == 'en'){
      return '';
    }
    else{
      return "¡Todo listo! Usted está suscrito a nuestro boletín de noticias y actualizaciones sobre %{school_name}<br /><br /><a href='https://pub.s1.exacttarget.com/bkt2mldejgh' target='_blank'><span class='heading'>¿Quieres más en español?</span> <br />Tenemos Boletines Grado por Grado del Kínder hasta el 12.° grado. Haz clic aquí al suscribirte.</a>";
    }
  }

  function modalTopContent(){
    if (currentLocale() == 'en'){
      return {
        heading: "Send me email updates about my child's school"
      };
    }
    else{
      return {
        heading: 'Envíeme actualizaciones por correo electrónico sobre la escuela de mi hijo',
        subheading: "Lo sentimos, actualmente no ofrecemos correos electrónicos sobre tu escuela en español, pero lo haremos en un futuro cercano. Actualmente ofrecemos boletines disponibles en español basados en el grado de tu hijo para ayudarte a apoyar el aprendizaje en el hogar. Verás un enlace en la siguiente página para suscribirte."
      };
    }
  }
}
