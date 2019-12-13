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
      find('input[name="login"]').click
    end
  end

  # qa-testuser is a google email alias currently forwarding 
  # to asingh@greatschools.org
  def sign_in_as_testuser
    visit('/gsr/login/')
    fill_in('email', with: 'qa-testuser@greatschools.org')
    fill_in('password', with: 'secret123')
    click_button('Log in')
  end

  def random_email
    "ssprouse+rspec_#{Time.now.strftime('%s')}@greatschools.org"
  end

  def register_in_modal
    within('.remodal') do
      fill_in('email', with: random_email)
      click_button('Sign up')
    end
  end

  # TODO: Remove one of these helpers, as they are the same from a Capybara POV
  # Same as #register_in_modal, but no terms checkbox
  def register_in_email_modal
    within('.remodal') do
      fill_in('email', with: random_email)
      click_button('Sign up')
    end
  end
end
