class WpPost
  include ConstructFromHash

  attr_accessor :id, :type, :url, :title, :excerpt, :thumbnail, :thumbnail_size, :custom_fields
  delegating_attr_accessor :thumbnail_images, WpThumbnailImage, as: :hash

  define_initialize_that_accepts_hash

  # define helper methods to get at different thumbnail images
  [
    :full,
    :thumbnail,
    :medium,
    :'main-feature',
    :'side-feature',
    :'large-tile',
    :'content-tile',
    :'small-thumbnail',
    :'article-square',
    :'featured-square',
    :'book-thumbnail',
    :'post-thumbnail'
  ].each do |thumbnail_type|
    method_safe_thumbnail_type = thumbnail_type.to_s.gsub('-', '_')
    method = "#{method_safe_thumbnail_type}_image"
    define_method(method) { thumbnail_images[thumbnail_type.to_s] if thumbnail_images }
  end

  [
      :deck,
      :promo
  ].each do |custom_field_type|
    method_safe_custom_field_type = custom_field_type.to_s.gsub('-', '_')
    define_method(method_safe_custom_field_type) do
      field = nil
      if custom_fields
        field = custom_fields['wpcf-' + custom_field_type.to_s]
        if field.present? && field.is_a?(Array) && field.size == 1
          field = field.first
        end
      end
      field
    end
  end

end