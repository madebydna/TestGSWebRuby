module OspHelper
  def osp_email_verification_url(user)
    tracking_code = 'eml_ospverify'
    verification_link_params = {}
    hash, date = EmailVerificationToken.token_and_date(user)
    verification_link_params.merge!(
      id: hash,
      date: date,
      redirect: '/official-school-profile/dashboard/',
      s_cid: tracking_code
    )
    verify_email_url(verification_link_params)
  end
end