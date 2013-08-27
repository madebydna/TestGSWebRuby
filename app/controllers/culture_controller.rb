class CultureController < LocalizedProfileController

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

end
