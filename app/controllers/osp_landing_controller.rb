class OspLandingController < ApplicationController
  before_action :set_login_redirect
  before_action :login_required, only: [:dashboard]

  def show
    page_title = 'Edit your school profile at GreatSchools'
    gon.pageTitle = page_title
    gon.pagename = 'GS:OSP:LandingPage'
    set_meta_tags title: page_title,
                  description:'Tell your school\'s story. Create a free school account on GreatSchools to claim and edit your school profile.',
                  keywords:'school account, school profile, edit profile, school leader account, school principal account, school official account'
    data_layer_gon_hash.merge!(
      {
        'page_name' => 'GS:OSP:LandingPage',
      }
    )

    render 'osp/osp_landing'
  end

  def dashboard
    # If state/schoolId params are provided, redirect directly to that school's form
    if params[:state] && params[:schoolId]
      redirect_to(osp_page_path(:state =>params[:state], :schoolId => params[:schoolId], :page => 1))
    else
      # TODO: If superuser, render superuser form
      # if current_user.is_esp_superuser?
      #   @superuser = true
      #   render 'osp/dashboard'
      #   return
      # end

      memberships = current_user.esp_memberships
      approved_memberships = memberships.select(&:approved?)
      provisional_memberships = memberships.select(&:provisional?)
      if approved_memberships.size == 1
        # If approved and list.size == 1, redirect to that school's form
        membership = approved_memberships.first
        redirect_to(osp_page_path(:state =>membership.state, :schoolId => membership.school_id, :page => 1))
      elsif approved_memberships.size > 1
        # Otherwise render demigod list
        # get ordered list of memberships (by school name ignoring state)
        #   for each membership get the school
        #   Sort memberships by school name
        #   Send list of schools to view
        redirect_to(my_account_path) # TODO implement correct behavior
      elsif !provisional_memberships.empty?
        # If provisional OSP user, get first provisional membership and redirect to that school's form
        membership = provisional_memberships.first
        redirect_to(osp_page_path(:state =>membership.state, :schoolId => membership.school_id, :page => 1))
      else
        # If other user, block access
        redirect_to(my_account_path)
      end
    end
  end
end
