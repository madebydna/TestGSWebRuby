import {
  signupAndFollowSchool,
  signupAndGetNewsletter
} from '../util/newsletters';

const newsletterLinkSelector = '.js-send-me-updates-button-footer';

export function setupNewsletterLink() {
  $(newsletterLinkSelector).on('click', function () {
    let schoolName;
    let stateAbbreviation;
    let schoolId;

    if(window.gon && window.gon.school) {
      schoolName = gon.school.name;
      stateAbbreviation = gon.school.state;
      schoolId = gon.school.id;
    }

    if (schoolId && stateAbbreviation) {
      signupAndFollowSchool(stateAbbreviation, schoolId);
    } else {
      signupAndGetNewsletter();
    }
  });
}

