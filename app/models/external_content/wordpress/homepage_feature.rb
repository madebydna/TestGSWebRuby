class HomepageFeature < ExternalContent
  include ConstructFromHash

  attr_accessor :status, :type
  delegating_attr_accessor :first_feature, WpFeature
  delegating_attr_accessor :second_feature, WpFeature

  define_initialize_that_accepts_hash

end