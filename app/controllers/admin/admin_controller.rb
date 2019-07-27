class Admin::AdminController < ApplicationController
  protect_from_forgery

  before_action :init_page

  layout 'deprecated_application_with_webpack'

  def info

  end

  def examples_and_gotchas

  end

  def script_query
    @last_script_ran = ScriptLogger.where.not(output:nil).order(end: :desc).limit(10)
    @current_running_script = ScriptLogger.where(output:nil).order(end: :desc)
  end

  def omniture_test
    gon.pagename = 'omniture_test'
    gon.omniture_pagename = 'omniture_test'
    gon.omniture_hier1 = 'omniture_test,test_page'
    gon.omniture_sprops = {'userLoginStatus' => 'Logged In', 'schoolRating' => 7}
    gon.omniture_evars = {'review_updates_mss_traffic_driver' => 'testing'}
  end

  private

  def init_page
    gon.pagename = 'admin_help'
    set_meta_tags :robots => 'noindex'
  end

end
