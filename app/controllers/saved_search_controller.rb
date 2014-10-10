class SavedSearchController < ApplicationController
  include DeferredActionConcerns
  include SavedSearchConcerns

  def attempt_saved_search
    if logged_in?
      request.xhr? ? handle_json(saved_search_params) : handle_html(saved_search_params)
    else
      save_deferred_action :saved_search_deferred, saved_search_params
      flash_notice 'log in required'
      if request.xhr?
        render json: { redirect: signin_url }
      else
        redirect_to signin_url
      end
    end
  end

  protected

  def saved_search_params
    saved_search_params = {}
    saved_search_params[:name] = params[:search_name] || (return false)
    saved_search_params[:search_string] = params[:search_string] || (return false)
    saved_search_params[:num_results] = params[:num_results] || (return false)

    options = [:state, :url].inject({}) do | hash, param|
      hash.merge!({param => params[param]}) if params[param]; hash
    end
    saved_search_params[:options] = options.to_json if options.present?
    saved_search_params
  end

end
