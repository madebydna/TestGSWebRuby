module CommunityProfiles
  class RatingScoreItem < SchoolProfiles::RatingScoreItem
    attr_accessor :label, :score, :state_average, :visualization, :range, :info_text, :description, :test_label, :source, :year, :grade, :grades, :flags, :breakdown, :subgroup, :data_type
  end
end