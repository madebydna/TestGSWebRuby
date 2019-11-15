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

  def sign_in_as_ssprouse
    visit('/gsr/login/')
    fill_in('email', with: 'ssprouse@greatschools.org')
    fill_in('password', with: '0!apdoQu_3A')
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
