class AdminController < ApplicationController
  protect_from_forgery

  before_filter :init_page

  layout 'application'

  def help

  end

  def omniture_test
    gon.pagename = 'omniture_test'
    gon.omniture_pagename = 'omniture_test'
    gon.omniture_heirarchy = 'overview,omniture_test'
    gon.omniture_sprops = {'test_1_sprop' => 'testprop1', 'test_2_sprop' => 'testprop2'}
    gon.omniture_evars = {'test_1_evar' => 'testevar1', 'test_2_evar' => 'testevar2'}
  end

  private

  def init_page
    gon.pagename = 'admin_help'
  end

end
