import JoinModal from './join_modal';
import { create } from 'lodash';

const SaveSearchModal = function($, options) {
    JoinModal.call(this, $, options);
    options = options || {};

    this.cssClass = options.cssClass || 'js-save-search-modal';
    this.modalUrl = '/gsr/modals/save_search_modal';
};

SaveSearchModal.prototype = create(JoinModal.prototype, {
    'constructor': JoinModal
});

export default SaveSearchModal;
