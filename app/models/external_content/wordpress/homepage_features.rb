class HomepageFeatures < ExternalContent
  include ConstructFromHash

  attr_accessor :type
  delegating_attr_accessor :first_feature, WpFeature
  delegating_attr_accessor :second_feature, WpFeature

  define_initialize_that_accepts_hash

  def features
    [first_feature, second_feature].compact
  end
end