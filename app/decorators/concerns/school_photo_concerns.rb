module SchoolPhotoConcerns

  def photo(width = 130, height = 130)
    uploaded_photo(height) || nil # default_photo #street_view_photo(width, height)
  end

  def uploaded_photo(size = 130)
    if school_media_first_hash.present?
      image_tag(
        h.school_media_image_path(school.state, size, school_media_first_hash),
        class: 'thumbnail-border',
        alt: "Photo provided by "+name+"."
      )
    end
  end

  def default_photo(size = 130)
      image_tag(
          image_path("search/no-school-photo.png"),
          class: 'thumbnail-border',
          alt: "Image provided by GreatSchools."
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
end
