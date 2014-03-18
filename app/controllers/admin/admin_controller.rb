class Admin::AdminController < ApplicationController
  protect_from_forgery

  before_filter :init_page

  layout 'application'

  def help

  end

  def info

  end

  def examples_and_gotchas

  end

  def omniture_test
    gon.pagename = 'omniture_test'
    gon.omniture_pagename = 'omniture_test'
    gon.omniture_hier1 = 'omniture_test,test_page'
    gon.omniture_sprops = {'userLoginStatus' => 'Logged In', 'schoolRating' => 7}
    gon.omniture_evars = {'review_updates_mss_btn_source' => 'testing'}
  end

  private

  def init_page
    gon.pagename = 'admin_help'
    set_meta_tags :robots => 'noindex'
  end

end
