require 'spec_helper'
require 'features/contexts/shared_contexts_for_signed_in_users'

feature "Signin features" do
  subject do
    visit signin_path
    page
  end

  after { clean_models User }

  feature 'User logs in' do

    before { subject }
    let(:user) do
      FactoryBot.create(:verified_user, password: 'password')
    end

    it 'Gives the user the ability to log out' do
      pending('PT-1213: TODO: figure out why test fails intermittently')
      fail
      find(:css, "#email").set(user.email)
      find(:css, "#password").set('password')
      click_button 'Login'
      visit signin_path
      expect(subject).to have_content('Sign Out')
    end
  end

  feature 'Signing out' do
    include_context 'signed in verified user'

    feature 'Clicking the sign out link' do
      it 'Lets the user sign in again' do
        subject
        click_link 'Sign Out'
        expect(subject).to have_content 'Log in'
      end
    end

  end

end
