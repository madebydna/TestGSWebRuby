class WpThumbnailImage
  include ConstructFromHash
  attr_accessor :url, :width, :height
  define_initialize_that_accepts_hash
end