require 'features/page_objects/join_page'

describe 'User Registration Flows', remote: true do
  describe 'Facebook signin', remote: true do
    let(:join_page) { JoinPage.new }
    before { join_page.load }
    
    it 'should redirect to account page with user\'s name' do
       facebok_window = window_opened_by do
        join_page.facebook_button.click
       end
       within_window facebok_window do
        submit_facebook_adam
       end
       expect(page).to have_text('Adam')
       expect(page.current_path).to eq('/account/')
     end
  end

  describe 'Signing in as an existing user' do
    before do 
      sign_in_as_testuser
    end

    it 'should redirect to the home page'
    it 'should have a link to My Account'
    it 'should have a link to Sign Out'
  end

  describe 'Signing up as a new user' do
    it 'should redirect to the home page'
    it 'should have a link to My Account'
    it 'should have a link to Sign Out'
    # https://dev.to/bhserna/how-to-test-that-an-specific-email-was-sent-59ep
    it 'should send an email with an activation link'
    describe 'Using the activation link' do
      it 'should take user to a page to set a password'
      it 'should allow user to set a password and redirect to account page'
    end
  end

  describe 'Forgot Password Link' do
    it 'opens the forgot password flow'
    it 'sends email with link to reset password'
    it 'should allow user to reset password and redirect to account page'
  end
end