class LocalizedProfileController < ApplicationController
  protect_from_forgery

  # Find school before executing culture action
  before_filter :find_school

  def initialize
    @category_positions = {}
  end

  def programs_resources
    page('Programs & resources')
    @category_positions = @page.categories_per_position(@school.collections)
    render :layout => 'application' # TODO: why do we need to use this? ApplicationController should render this by default
  end

  def extracurriculars
    page('Extracurriculars')
    @category_positions = @page.categories_per_position(@school.collections)
    render :layout => 'application' # TODO: why do we need to use this? ApplicationController should render this by default
  end

  def page(name)
    @page = Page.where(name: name).first
  end

  # Finds school given request param schoolId
  def find_school
    school_id = params[:schoolId] || 1

    if school_id.nil?
      # todo: redirect to school controller, school_not_found action
    end

    @school = School.find school_id
  end

end
