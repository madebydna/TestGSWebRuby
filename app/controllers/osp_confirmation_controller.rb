class OspConfirmationController < ApplicationController

  before_action :set_city_state

  def show

    page_title = 'Registration Confirmation'
    gon.pageTitle = page_title
    gon.pagename = "GS:OSP:RegistrationConfirmation"
    set_meta_tags title: page_title

    @school = School.find_by_state_and_id(@state[:short], params[:schoolId]) if @state.present? && params[:schoolId].present?

    render 'osp/osp_confirmation'
  end

end
