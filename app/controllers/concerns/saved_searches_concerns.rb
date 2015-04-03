module SavedSearchesConcerns
  extend ActiveSupport::Concern
  ERROR_MESSAGE = 'Currently we are unable to save your search. Please try again later'

  protected

  def handle_json(saved_search_attrs)
    errors = create_saved_search(saved_search_attrs)
    if errors.present?
      render json: { error: ERROR_MESSAGE }
    else
      render json: { }
    end
  end

  def handle_html(saved_search_attrs)
    errors = create_saved_search(saved_search_attrs)
    if errors.present?
      flash_error ERROR_MESSAGE
    else
      cookies[:saved_search] = 'success'
      flash_notice 'You have successfully saved your search!' if flash.empty?
    end
    redirect_path.nil? ? redirect_back_or_default : redirect_back_or_default(redirect_path)
  end

  def create_saved_search(saved_search_attrs)
    saved_search_attrs.except!(:city)
    current_user.saved_searches.create(saved_search_attrs).errors.full_messages
  end
end
