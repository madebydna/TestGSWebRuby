//= require jquery
//= require modals/base_modal

describe('GS.modal.BaseModal', function() {
  describe('.getCssClass', function() {
    it('it returns a null', function() {
      modal = new GS.modal.BaseModal(jQuery);
      expect(modal.getCssClass()).to.eq(null);
    });
  });

  describe('.getModalUrl', function() {
    it('it returns a null', function() {
      modal = new GS.modal.BaseModal(jQuery);
      expect(modal.getModalUrl()).to.eq(null);
    });
  });
});
