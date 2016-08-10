class FooterController < ApplicationController
  protect_from_forgery except: :show

  def show
    content = render_to_string('nav/footer', layout: 'footer')
    respond_to do |format|
      format.js {
        render json: {data: content}, callback: params['callback']
      }
    end
  end
end
