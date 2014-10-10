module SavedSearchConcerns
  extend ActiveSupport::Concern

  def handle_json(params)
    if (create_saved_search params).is_a?(Exception)
      render json: { error: 'We are sorry but something went wrong' }
    else
      render json: { }
    end
  end

  def handle_html(params)
    if (create_saved_search params).is_a?(Exception)
      flash_error 'We are sorry but something went wrong'
    else
      cookies[:saved_search] = 'success'
      flash_notice 'You have successfully saved your search!'
    end
    redirect_path.nil? ? redirect_back_or_default : redirect_back_or_default(redirect_path)
  end

  def create_saved_search(params)
    begin
      name = params[:name]
      num_of_searches_with_same_name = current_user.saved_searches.num_of_prev_searches_named(name)

      params[:name] = "#{name}(#{num_of_searches_with_same_name})" if num_of_searches_with_same_name > 0
      current_user.saved_searches.create!(params)
    rescue Exception => e
      e
    end
  end
end
