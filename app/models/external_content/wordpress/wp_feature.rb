class WpFeature
  include ConstructFromHash

  attr_accessor :heading
  delegating_attr_accessor :posts, WpPost, as: :array

  define_initialize_that_accepts_hash
end