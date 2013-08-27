class LocalizedProfileController < ApplicationController
  protect_from_forgery


  # Find school before executing culture action
  before_filter :find_school, only: [:culture]
  before_filter :page, only: [:culture]

  def initialize
    @category_positions = {}
  end

  def culture
    @category_positions = @page.categories_per_position(@school.collections)
    render :layout => 'application' # TODO: why do we need to use this? ApplicationController should render this by default
  end

  def page
    @page = Page.where(name: 'Extracurriculars').first
  end

  # Finds school given request param schoolId
  def find_school
    school_id = params[:schoolId]

    if school_id.nil?
      # todo: redirect to school controller, school_not_found action
    end

    @school = School.find school_id
  end

end
