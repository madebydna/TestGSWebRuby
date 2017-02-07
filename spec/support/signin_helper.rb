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
end
