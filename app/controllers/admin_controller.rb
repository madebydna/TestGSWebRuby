class AdminController < ApplicationController
  protect_from_forgery

  before_filter :init_page

  layout 'application'

  def help

  end

  def info

  end

  def omniture_test
    gon.pagename = 'omniture_test'
    gon.omniture_pagename = 'omniture_test'
    gon.omniture_hier1 = 'omniture_test,test_page'
    gon.omniture_sprops = {'userLoginStatus' => 'Logged In', 'schoolRating' => 7}
    gon.omniture_evars = {'testEvar1' => 'testEvar1', 'testEvar2' => 'testEvar2'}
  end

  private

  def init_page
    gon.pagename = 'admin_help'
  end

end
