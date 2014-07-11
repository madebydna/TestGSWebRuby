class SchoolProfileDecorator < Draper::Decorator
  decorates :school
  delegate_all

  include GradeLevelConcerns

  def link_to_overview(*args, &blk)
    h.link_to h.school_path(school), *args, &blk
  end

  def type
    school.type.gs_capitalize_first
  end

  def photo(width = 130, height = 130)
    uploaded_photo(height) || street_view_photo(width, height)
  end

  def city_state
    [city, state].join(', ')
  end

  def google_formatted_street_address
    address = "#{street},#{city},#{state}+#{zipcode}"
    address.gsub(/\s+/,'+')
  end

  def uploaded_photo(size = 130)
    media_hash = school_media_first_hash
    return unless media_hash.present?
    image_tag(
      h.generate_img_path(size, media_hash),
      class: 'thumbnail-border',
      alt: "Photo provided by "+name+"."
    )
  end

  def street_view_photo(width = 130, height = 130)
    return unless google_formatted_street_address.present?

    street_view_url =
      GoogleSignedImages.street_view_url(
        width,
        height,
        google_formatted_street_address
      )

    if google_formatted_street_address.present?
      image_tag(
        GoogleSignedImages.sign_url(street_view_url),
        class: 'thumbnail_border',
        alt: "Google Street View of "+name+" address."

      )
    end
  end

  def state_breadcrumb_text
    text =
      if state == 'DC'
        'District of Columbia'
      else
        States.state_name(state).gs_capitalize_words
      end
  end

  def city_breadcrumb_text
    text =
      if state == 'DC'
        'Washington, D.C.'
      else
        city
      end

    text.gs_capitalize_words
  end

end