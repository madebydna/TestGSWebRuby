module RatingSourceConcerns
  def rating_source(year:, label:, description:nil, methodology:nil, more_anchor:nil, state:nil)
    ratings_link = (I18n.locale == :es ? ratings_spanish_path(anchor: more_anchor, trailing_slash: true) : ratings_path(anchor: more_anchor, trailing_slash: true))
    content = '<div>'
    content << '<h4 >' + label + '</h4>'

    description = rating_db_label(description) if description
    methodology = rating_db_label(methodology) if methodology
    if description || methodology
      content << "<p>#{[description, methodology].compact.join(' ')}</p>"
    end

    content << '<p>'
    content << '<span class="emphasis">' + rating_static_label(:source) + '</span>: GreatSchools; '
    content << "#{rating_static_label(:calculated_in)} #{year} "
    if more_anchor
      content << "| <span class=\"emphasis\">#{rating_static_label(:see_more)}</span>: "
      content << "<a href=\"#{ratings_link}\"; target=\"_blank\">#{rating_static_label(:about_this_rating)}</a>"
    end
    content << '</p>'
    content << '</div>'
    content
  end

  private

  def rating_static_label(key)
    I18n.t(key, scope: 'controllers.school_profile_controller', default: key)
  end

  def rating_db_label(key)
    I18n.t(key, scope: 'controllers.school_profile_controller', default: I18n.db_t(key, default: key))
  end
end