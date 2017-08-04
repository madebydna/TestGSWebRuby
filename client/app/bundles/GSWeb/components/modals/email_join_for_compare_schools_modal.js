import { create } from 'lodash';

import EmailJoinModal from './email_join_modal';

const EmailJoinForCompareSchoolsModal = function($, options) {
  EmailJoinModal.call(this, $, options);
  options = options || {};

  this.cssClass = options.cssClass || 'email-join-for-compare-schools';
  this.modalUrl = '/gsr/modals/signup_and_follow_schools_modal';

  this.eventTrackingConfig = {
    'default': {
      'show': {
        'eventCategory': 'Registration',
        'eventAction': 'Email Hover',
        'eventLabel': 'GS Newsletter/MSS'
      }
    }
  };
};

EmailJoinForCompareSchoolsModal.prototype = create(EmailJoinModal.prototype, {
  'constructor': EmailJoinModal
});

export default EmailJoinForCompareSchoolsModal;
