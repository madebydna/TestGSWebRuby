class OspLandingController < ApplicationController
  before_action :set_login_redirect
  before_action :login_required, only: [:dashboard]

  layout 'application'

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

    render 'osp/osp_landing', layout: 'deprecated_application'
  end

  def dashboard
    # If state/schoolId params are provided, redirect directly to that school's form
    if params[:state] && params[:schoolId]
      redirect_to(osp_page_path(:state =>params[:state], :schoolId => params[:schoolId], :page => 1))
    elsif current_user.is_esp_superuser? || approved_memberships.size > 1
      @superuser = current_user.is_esp_superuser?
      @schools = schools
      render 'osp/dashboard' # demigod disambiguation list and superuser form
    elsif single_membership # includes provisional
      redirect_to(osp_page_path(:state =>single_membership.state, :schoolId => single_membership.school_id, :page => 1))
    else
      redirect_to(my_account_path)
    end
  end

  private

  def single_membership
    return @_single_membership if defined?(@_single_membership)
    @_single_membership = if has_single_membership?
                            (approved_memberships + provisional_memberships).compact.first
                          end
  end

  def has_single_membership?
    approved_memberships.size == 1 || (approved_memberships.empty? && !provisional_memberships.empty?)
  end

  def esp_memberships
    @_esp_memberships ||= current_user.esp_memberships
  end

  def approved_memberships
    @_approved_memberships ||= esp_memberships.select(&:approved?)
  end

  def provisional_memberships
    @_provisional_memberships ||= esp_memberships.select(&:provisional?)
  end

  def schools
    @_schools ||= begin
      schools = approved_memberships.map do |m|
        School.on_db(m.state.downcase.to_sym).find_by_id(m.school_id) if m.state.present? && m.school_id.present?
      end
      schools.compact.select { |s| s.active == 1 }.sort_by(&:name)
    end
  end
end