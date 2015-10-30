var GS = GS || {};
GS.modal = GS.modal || {};

GS.modal.SaveSearchModal= function($, options) {
    GS.modal.JoinModal.call(this, $, options);
    options = options || {};

    this.cssClass = options.cssClass || 'js-save-search-modal';
    this.modalUrl = '/gsr/modals/save_search_modal';
};

GS.modal.SaveSearchModal.prototype = _.create(GS.modal.JoinModal.prototype, {
    'constructor': GS.modal.JoinModal
});