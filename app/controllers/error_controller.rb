class ErrorController < ApplicationController

  layout :determine_layout

  def internal_error

  end

  def page_not_found
    gon.omniture_pagename = 'errorPage'
    gon.omniture_hier1 = "Error,404"
    set_meta_tags :title => "Page Not Found"
    begin
    respond_to do |format|
      format.html { render status: 404 }
    end

    rescue ActionController::UnknownFormat
      render status: 404, text: "Page not found"
    end
  end

  def school_not_found

  end

  private

  def determine_layout
    if action_name == 'internal_error'
      'no_header_and_footer'
    else
      'error'
    end
  end

end