class SavedSearchesController < ApplicationController
  include DeferredActionConcerns
  include SavedSearchesConcerns

  def create
    if logged_in?
      request.xhr? ? handle_json(saved_search_params) : handle_html(saved_search_params)
    else
      save_deferred_action :saved_search_deferred, saved_search_params
      redirect_to_login
    end
  end

  def destroy
    if logged_in?
      begin
        current_user.saved_searches.destroy(params[:id])
        render json: { }
      rescue => e
        if e.is_a?(ActiveRecord::RecordNotFound)
          render json: { }
        else
          render json: { error: 'We are sorry but something went wrong. Please try again later' }
        end
      end
    else
      redirect_to_login
    end
  end

  protected

  def redirect_to_login
    flash_notice 'log in required'
    if request.xhr?
      render json: { redirect: signin_url }
    else
      redirect_to signin_url
    end
  end

  def saved_search_params
    return false unless params[:search_name].present? && params[:search_string].present? && params[:num_results].present?

    saved_search_params = {}
    saved_search_params[:name] = params[:search_name]
    saved_search_params[:search_string] = params[:search_string]
    saved_search_params[:num_results] = params[:num_results]

    options = [:state, :url].inject({}) do | hash, param|
      hash.merge!({param => params[param]}) if params[param]; hash
    end
    saved_search_params[:options] = options.to_json if options.present?
    saved_search_params
  end

end
