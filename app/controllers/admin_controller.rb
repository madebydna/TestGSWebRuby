class AdminController < ApplicationController
  protect_from_forgery

  before_filter :restrict_by_ip
  before_filter :init_page

  ALLOWED_IPS = ['127.0.0.1', '172.18.1.0/24', '172.19.1.0/24', '172.20.1.0/24', '172.21.1.0/24', '172.22.1.0/24']

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

  def restrict_by_ip
    allowed = false

    # Convert remote IP to an integer.
    bremote_ip = view_context.remote_ip.split('.').map(&:to_i).pack('C*').unpack('N').first

    ALLOWED_IPS.each do |ipstring|
      ip, mask = ipstring.split '/'

      # Convert tested IP to an integer.
      bip = ip.split('.').map(&:to_i).pack('C*').unpack('N').first

      # Convert mask to an integer, and assume /32 if not specified.
      mask = mask ? mask.to_i : 32
      bmask = ((1 << mask) - 1) << (32 - mask)
      if bip & bmask == bremote_ip & bmask
        allowed = true
        break
      end
    end

    if not allowed
      render :text => 'Not authorized'
      return
    end
  end

end
