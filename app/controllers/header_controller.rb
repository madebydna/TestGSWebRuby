class HeaderController < ApplicationController

  layout false
  protect_from_forgery except: :show

  def show
    content = render_to_string('nav/header')
    respond_to do |format|
      format.js {
        render json: {header: content}, callback: params['callback']
      }
    end
  end
end