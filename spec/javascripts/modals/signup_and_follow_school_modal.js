//= require jquery
//= require modals/base_modal
//= require modals/email_join_modal
//= require modals/email_join_for_school_profile_modal

describe('GS.modal.SignupAndFollowSchoolModal', function() {
  describe('.getCssClass', function() {
    it('it returns signup_and_follow_school class', function() {
      var cssClass = 'email-join-for-school-profile-modal';
      modal = new GS.modal.SignupAndFollowSchoolModal(jQuery);
      expect(modal.getCssClass()).to.eq(cssClass);
    });
  });

  describe('.getModalUrl', function() {
    it('it returns signup_and_follow_school url', function() {
      var url = '/gsr/modals/signup_and_follow_school_modal';
      modal = new GS.modal.SignupAndFollowSchoolModal(jQuery);
      expect(modal.getModalUrl()).to.eq(url);
    });
  });
});
