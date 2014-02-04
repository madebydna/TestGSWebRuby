class AdminController < ApplicationController
  protect_from_forgery

  before_filter :init_page

  layout 'application'

  def help

  end

  def omniture_test
    gon.pagename = 'omniture_test'
    gon.omniture_pagename = 'omniture_test'
    gon.omniture_hier1 = 'omniture_test,test_page'
    gon.omniture_sprops = {'user_login_status' => 'Logged In', 'school_rating' => 7}
    gon.omniture_evars = {'test_1_evar' => 'testevar1', 'test_2_evar' => 'testevar2'}
  end

  private

  def init_page
    gon.pagename = 'admin_help'
  end

end
