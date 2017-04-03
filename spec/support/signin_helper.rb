module SigninHelper
  def sign_in_as_facebook_adam
    visit('/gsr/login/')
    click_button('Log in with Facebook')
    submit_facebook_adam
    # within('platformDialogForm') do
    #   click_button('Continue as Adam')
    # end
  end

  def submit_facebook_adam
    within('#login_form') do
      fill_in('email', :with => 'adam_kecbnxu_schrockescu@tfbnw.net')
      fill_in('pass', :with => 'password')
      click_button('loginbutton')
    end
  end

  def random_email
    "ssprouse+rspec_#{Time.now.strftime('%s')}@greatschools.org"
  end

  def register_in_modal
    within('.modal') do
      fill_in('email', with: random_email)
      find('#terms_terms').click
      click_button('Sign up')
    end
  end
end