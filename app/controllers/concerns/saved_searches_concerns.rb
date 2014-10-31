module SavedSearchesConcerns
  extend ActiveSupport::Concern

  def handle_json(saved_search_attrs)
    if (create_saved_search saved_search_attrs).is_a?(Exception)
      render json: { error: 'We are sorry but something went wrong. Please try again later' }
    else
      render json: { }
    end
  end

  def handle_html(saved_search_attrs)
    if (create_saved_search saved_search_attrs).is_a?(Exception)
      flash_error 'We are sorry but something went wrong. Please try again later'
    else
      cookies[:saved_search] = 'success'
      flash_notice 'You have successfully saved your search!' if flash.empty?
    end
    redirect_path.nil? ? redirect_back_or_default : redirect_back_or_default(redirect_path)
  end

  def create_saved_search(saved_search_attrs)
    begin
      name = saved_search_attrs[:name]
      searches_with_same_name = current_user.saved_searches.searches_named(name)
      if searches_with_same_name.count > 0
        last_searches_number = /\((\d*)\)$/.match(searches_with_same_name.last.name)
        saved_search_attrs[:name] = "#{name}(#{last_searches_number.present? ? last_searches_number[1].to_i + 1 : 1})"
      end
      current_user.saved_searches.create!(saved_search_attrs)
    rescue Exception => e
      e
    end
  end
end
