module RatingMethodologySelector
  extend ActiveSupport::Concern

  STATE_EXCEPTIONS = %w(in nd)

  included do
    helper_method :ratings_link, :path_to_yaml
  end

  # JT-11010: We want to use the new copy ("*_alt") with the old link (ratings_path) for most states.
  # The exception states (IN & ND) should use the old copy with the new link (ratings_alt_path).
  def ratings_link_english
    STATE_EXCEPTIONS.exclude?(state.downcase) ? ratings_path : ratings_alt_path
  end

  def ratings_link_spanish
    STATE_EXCEPTIONS.exclude?(state.downcase) ? ratings_spanish_path : ratings_alt_path
  end

  def ratings_link
    if I18n.locale == :es
      ratings_link_spanish
    else
      ratings_link_english
    end
  end

  def path_to_yaml(context)
    STATE_EXCEPTIONS.exclude?(state.downcase) ? "#{context}_alt" : context
  end
end