class HeaderController < ApplicationController
  respond_to :html, :js

  layout false
  def show
    expires_in 1.day, :public => true
  end
  # protect_from_forgery except: :show

  # def show
  #   content = render_to_string('nav/header')
  #   respond_to do |format|
  #     format.js {
  #       render json: {data: content}, callback: params['callback']
  #     }
  #   end
  # end
end