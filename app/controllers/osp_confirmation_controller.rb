class OspConfirmationController < ApplicationController


  def show

    page_title = 'Registration Confirmation'
    gon.pageTitle = page_title
    gon.pagename = "GS:OSP:RegistrationConfirmation"
    set_omniture_data('GS:OSP:RegistrationConfirmation', 'Home,OSP,RegistrationConfirmation')
    set_meta_tags title: page_title,
                  keywords:'school account, school profile, edit profile, school leader account, school principal account, school official account'

    render 'osp/osp_confirmation'
  end

end