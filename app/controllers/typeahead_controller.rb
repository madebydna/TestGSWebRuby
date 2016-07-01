class TypeaheadController < ApplicationController

  protect_from_forgery except: :show

  def show
    render js: Rails.application.assets.find_asset('wp_autocomplete')
  end

end
