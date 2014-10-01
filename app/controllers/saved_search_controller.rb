class SavedSearchController < ApplicationController
  include DeferredActionConcerns
  include SavedSearchConcerns

  def attempt_saved_search

    if logged_in?
      create_saved_search saved_search_params
      redirect_path.nil? ? redirect_back_or_default : redirect_back_or_default(redirect_path)
    else
      save_deferred_action :saved_search_deferred, saved_search_params
      flash_notice 'log in required'
      redirect_to join_url
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
    saved_search_params[:options] = options if options.present?
    saved_search_params
  end

end
