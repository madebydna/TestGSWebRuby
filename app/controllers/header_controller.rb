class HeaderController < ApplicationController
  protect_from_forgery except: :show

  def show
    content = render_to_string('nav/header', layout: 'header')
    expires_in(30.minutes, public: true, must_revalidate: true)
    respond_to do |format|
      format.js {
        render json: {header: content}, callback: params['callback']
      }
      format.html {
        render 'nav/header', layout: 'header'
      }
    end
  end
end