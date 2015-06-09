class Admin::StyleGuideController < ApplicationController

  layout "style_guide"

  def index
    page_name = params['page']
    if params['page'].blank?
      page_name = 'index'
    end
    path = "admin/style_guide/"+page_name
    @sections = []
    @directory = 'Make me dynamic directory name'
    @page_title = 'Make me dynamic page name'
    render path
  end
end
