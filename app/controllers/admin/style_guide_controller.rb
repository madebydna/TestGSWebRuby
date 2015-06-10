class Admin::StyleGuideController < ApplicationController

  before_action :set_nav_instance_var!

  layout "style_guide"

  def index
    @sections = []
    @directory, @page_title = 'GreatSchools Style Guide', 'Welcome!'
  end

  def render_page
    @sections = []
    if path_to_page.present?
      @directory, @page_title = params[:category].gsub(/-|_/, ' ').capitalize, params[:page].gsub(/-|_/, ' ').capitalize
      render path_to_page
    else
      redirect_to admin_style_guide_path
    end
  end

  def path_to_page
    return @path_to_page if defined? @path_to_page
    @path_to_page = begin
      path = "admin/style_guide/pages/#{params[:category]}/#{params[:page]}"
      page_exists?(path) ? path : nil
    end
  end

  def page_exists?(path)
    full_path = "app/views/#{path}.html.erb"
    Find.find('app/views/admin/style_guide/pages/') { | p | return true if p == full_path }
    false
  end

  def set_nav_instance_var!
    @categories_and_pages = Dir['app/views/admin/style_guide/pages/**/*.erb'].group_by do | file |
      file.split('/')[-2] #grab parent directory of erb file
    end
  end
end
