require 'spec_helper'

feature 'Account management page' do

  subject do
    visit manage_account_path
    page
  end

  after do
    clean_models EspMembership, MemberRole, Role
  end

  feature 'requires user to be logged in' do
    context 'when user is not logged in' do
      it 'should return to the login page' do
      end
    end
  end

  feature 'User is logged in' do
    include_context 'signed in verified user'

    scenario 'It displays change password link' do
      expect(subject).to have_content('Change password')
    end

    context 'when user has approved osp membership' do
      let!(:esp_membership) {FactoryGirl.create(:esp_membership,:with_approved_status,:member_id=> user.id )}
      scenario 'It displays link to edit osp' do
        expect(subject).to have_content('Edit school profile')
      end
    end

    context 'when user has provisional osp membership' do
      let!(:esp_membership) {FactoryGirl.create(:esp_membership,:with_provisional_status,:member_id=> user.id,:school_id=>1,:state=> 'mi' )}
      scenario 'It displays link to edit osp' do
        expect(subject).to have_content('Edit school profile')
      end
    end

    context 'when user is osp super user' do
      let!(:esp_superuser_role) {FactoryGirl.create(:esp_superuser_role )}
      let!(:member_role) {FactoryGirl.create(:member_role,member_id: user.id,role_id:esp_superuser_role.id)}
      scenario 'It displays link to edit osp' do
        binding.pry
        expect(subject).to have_content('Edit school profile')
      end
    end

  end

end
