//= require jquery
//= require modals/base_modal
//= require modals/email_join_modal
//= require modals/email_join_for_compare_schools_modal

describe('GS.modal.EmailJoinForCompareSchoolsModal', function() {
  describe('.getCssClass', function() {
    it('it returns signup_and_follow_schools class', function() {
      var cssClass = 'email-join-for-compare-schools';
      modal = new GS.modal.EmailJoinForCompareSchoolsModal(jQuery);
      expect(modal.getCssClass()).to.eq(cssClass);
    });
  });

  describe('.getModalUrl', function() {
    it('it returns signup_and_follow_schools url', function() {
      var url = '/gsr/modals/signup_and_follow_schools_modal';
      modal = new GS.modal.EmailJoinForCompareSchoolsModal(jQuery);
      expect(modal.getModalUrl()).to.eq(url);
    });
  });
});
