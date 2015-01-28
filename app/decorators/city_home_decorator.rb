class CityHomeDecorator < Draper::Decorator
  include GradeLevelConcerns

  decorates :city
  delegate_all

  NOT_RATED_VALUE = 'NR'

  def name
    city.name
  end

  def square_rating(rating, options = {})
    default_container_class = " pal tac text_fff rating-background-#{rating.to_s}"
    container_style = 'width:130px;height:120px;'

    h.content_tag(:div,
      class: options.fetch(:class, '') + default_container_class,
      style: container_style
    ) do
      rating_text_class = (rating == NOT_RATED_VALUE)? 'jumbo-text-sub' : 'jumbo-text'
      content = ''
      content << h.content_tag(:span, class: rating_text_class) { rating.to_s }
      if rating != NOT_RATED_VALUE
        content << h.tag(:br)
        content << 'out of 10' if rating != NOT_RATED_VALUE
      end
      content.html_safe
    end
  end

  def number_of_schools_in_city
    real_count = School.on_db(city.state.downcase.to_sym).
      active.
      where(city_id: city.id).
      count
  end

  alias_method :grade_range, :process_level

  def city_state_zip
    if city.present? && zipcode.present?
      "#{city}, #{state} #{zipcode}"
    end
  end

  def city_home_link(text = name)
    city_params = h.city_params_from_city(city)
    url = h.city_url(city_params)
    if url.present?
      h.link_to(text, url)
    end
  end

  def city_state
    if city.present?
      "#{city}, #{state}"
    end
  end

  def website_link
    url = city.home_page_url
    if url.present?
      h.link_to('City website', url, target: '_blank')
    end
  end

  def school_browse_url(query_param_hash = nil)
    city_params = h.city_params(city.state, city.name)
    city_params.merge!(query_param_hash) if query_param_hash.present?
    
    url = h.search_city_browse_url(city_params)
  end

  def school_browse_link(level_code = nil, &blk)
    level_code_to_label_map = {
      p: 'Preschools',
      e: 'Elementary schools',
      m: 'Middle schools',
      h: 'High schools'
    }
    
    city_params = {}
    city_params[:gradeLevels] = level_code if level_code.present?

    url = school_browse_url(city_params)

    if block_given?
      h.link_to(url, &blk)
    else
      h.link_to(
        level_code_to_label_map[level_code.to_sym],
        url
      )
    end
  end
end