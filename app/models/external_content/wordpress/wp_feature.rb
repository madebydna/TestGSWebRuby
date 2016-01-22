class WpFeature
  include ConstructFromHash

  attr_accessor :heading
  delegating_attr_accessor :posts, WpPost, as: :array

  define_initialize_that_accepts_hash

  def valid_posts
    begin
      posts.select do |post|
        post.thumbnail_images.present? && (post.promo || post.title) && post.url && post.large_tile_image
      end
    rescue
      []
    end
  end
end