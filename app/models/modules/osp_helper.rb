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
    email_send_link_no_admin(verify_email_url(verification_link_params))
  end

  def send_email_to_osp(membership, status)
    if status == 'approved'
      OspApprovalEmail.deliver_to_user(membership.user,
                                       School.on_db(membership.state.downcase).find(membership.school_id),
                                       generate_osp_dashboard_url(membership.school_id, membership.state.downcase))
    elsif status == 'rejected'
      OspRejectionEmail.deliver_to_user(membership.user, School.on_db(membership.state.downcase).find(membership.school_id))
    end
  end

  def generate_osp_dashboard_url(school_id, state)
    osp_page_url(
      {
        :page => 1,
        :schoolId => school_id,
        :state => state.downcase
      }
    )
  end


end