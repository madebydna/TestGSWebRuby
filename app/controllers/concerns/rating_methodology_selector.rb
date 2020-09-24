module RatingMethodologySelector
  extend ActiveSupport::Concern

  included do
    helper_method :ratings_link, :path_to_yaml
  end

  def ratings_link_english
    ratings_path
  end

  def ratings_link_spanish
    ratings_spanish_path
  end

  def ratings_link
    if I18n.locale == :es
      ratings_link_spanish
    else
      ratings_link_english
    end
  end

  def path_to_yaml(context)
    context
  end
end