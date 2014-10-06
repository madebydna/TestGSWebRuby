class Admin::StyleGuideController < ApplicationController

  def index
    path = "admin/style_guide/"+params['page']
    render path
  end
end