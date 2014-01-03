class AdminController < ApplicationController
  protect_from_forgery

  before_filter :init_page

  layout 'application'

  def help

  end

  private

  def init_page
    gon.pagename = 'admin_help'
  end

end
