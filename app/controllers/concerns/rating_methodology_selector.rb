module RatingMethodologySelector
  extend ActiveSupport::Concern

  STATE_EXCEPTIONS = %w(ca mi)

  included do
    helper_method :ratings_link, :path_to_yaml
  end

  def ratings_link_english
    STATE_EXCEPTIONS.include?(state.downcase) ? ratings_alt_path : ratings_path
  end

  def ratings_link_spanish
    STATE_EXCEPTIONS.include?(state.downcase) ? ratings_alt_path : ratings_spanish_path
  end

  def ratings_link
    if I18n.locale == :es
      ratings_link_spanish
    else
      ratings_link_english
    end
  end

  def path_to_yaml(context)
    STATE_EXCEPTIONS.include?(state.downcase) ? "#{context}_alt" : context
  end
end