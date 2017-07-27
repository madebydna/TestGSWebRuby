// TODO: import Uri methods

import JoinModal from './join_modal';
import { addQueryParamToUrl } from '../../util/uri';
import BaseModal from './base_modal';

const SuccessModal = function($, options) {
    JoinModal.call(this, $, options);
    options = options || {};

    this.cssClass = options.cssClass || 'success-modal';
    this.heading = options.heading;
    this.subheading = options.subheading;
    this.modalUrl = '/gsr/modals/success_modal';
    if(this.heading) {
      this.modalUrl = addQueryParamToUrl('heading', this.heading, this.modalUrl);
    }
    if(this.subheading) {
      this.modalUrl = addQueryParamToUrl('subheading', this.subheading, this.modalUrl);
    }
};

SuccessModal.prototype = _.create(BaseModal.prototype, {
    'constructor': BaseModal
});

_.assign(SuccessModal.prototype, {

  initialize: function initialize() {
    this.initializeShowHideBehavior();
    this.$getModal().find('button').on('click', function() {
      this.getDeferred().resolve();
    }.bind(this));
  }
});

export default SuccessModal;
