class SchoolSearchResult
  include ActionView::Helpers::AssetTagHelper
  include FitScoreConcerns

  attr_accessor :academic_focus, :arts_media, :arts_music, :arts_performing_written, :arts_visual, :before_after_care,
                :boys_sports, :city, :community_rating, :database_state, :distance, :dress_code, :enrollment,
                :foreign_language, :girls_sports, :id, :immersion_language, :instructional_model,
                :latitude, :level, :level_code, :longitude, :name, :on_page, :overall_gs_rating,
                :overall_gs_rating, :review_count, :school_media_first_hash, :state, :state_name, :street,
                :transportation, :type, :zip, :zipcode

  def initialize(hash)
    @fit_score = 0
    @max_fit_score = 0
    @fit_score_breakdown = []
    @attributes = hash
    hash.each { |name, value| instance_variable_set("@#{name}", value) }
  end

  def preschool?
    (!level_code.nil? && level_code == 'p')
  end
end
