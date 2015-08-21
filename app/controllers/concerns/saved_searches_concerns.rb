module SavedSearchesConcerns
  extend ActiveSupport::Concern
  ERROR_MESSAGE = I18n.t('controllers.concerns.saved_searches_concerns.search_not_saved_error')

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
      flash_notice I18n.t('controllers.concerns.saved_searches_concerns.search_saved') if flash.empty?
    end
    redirect_path.nil? ? redirect_back_or_default : redirect_back_or_default(redirect_path)
  end

  def create_saved_search(saved_search_attrs)
    saved_search_attrs.except!(:city)
    current_user.saved_searches.create(saved_search_attrs).errors.full_messages
  end
end
