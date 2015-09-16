class WpPost
  include ConstructFromHash

  attr_accessor :id, :type, :url, :title, :excerpt, :thumbnail, :thumbnail_size
  delegating_attr_accessor :thumbnail_images, WpThumbnailImage, as: :hash

  define_initialize_that_accepts_hash

end