module SavedSearchesConcerns
  extend ActiveSupport::Concern

  def handle_json(params)
    if (create_saved_search params).is_a?(Exception)
      render json: { error: 'We are sorry but something went wrong. Please Try again Later' }
    else
      render json: { }
    end
  end

  def handle_html(params)
    if (create_saved_search params).is_a?(Exception)
      flash_error 'We are sorry but something went wrong. Please Try again Later'
    else
      cookies[:saved_search] = 'success'
      flash_notice 'You have successfully saved your search!' if flash.empty?
    end
    redirect_path.nil? ? redirect_back_or_default : redirect_back_or_default(redirect_path)
  end

  def create_saved_search(params)
    begin
      name = params[:name]
      searches_with_same_name = current_user.saved_searches.searches_named(name)
      if searches_with_same_name.count > 0
        last_searches_number = /\((\d*)\)$/.match(searches_with_same_name.last.name)
        params[:name] = "#{name}(#{last_searches_number.present? ? last_searches_number[1].to_i + 1 : 1})"
      end
      current_user.saved_searches.create!(params)
    rescue Exception => e
      e
    end
  end
end
