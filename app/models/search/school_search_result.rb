class SchoolSearchResult
  include ActionView::Helpers::AssetTagHelper
  include FitScoreConcerns

  attr_accessor :academic_focus, :arts_media, :arts_music, :arts_performing_written, :arts_visual, :before_after_care,
                :boys_sports, :city, :community_rating, :database_state, :distance, :dress_code, :enrollment,
                :foreign_language, :girls_sports, :grade_range, :id, :immersion_language, :instructional_model,
                :latitude, :level, :level_code, :longitude, :name, :on_page, :overall_gs_rating,
                :review_count, :school_media_first_hash, :state, :state_name, :street, :summer_program,
                :transportation, :type, :voucher_type, :zip, :zipcode, :profile_path, :students_vouchers

  def initialize(hash)
    @fit_score = 0
    @max_fit_score = 0
    @fit_ratio = 0
    @fit_score_breakdown = []
    @academic_focus = hash['academic_focus']
    @arts_media = hash['arts_media']
    @arts_music = hash['arts_music']
    @arts_performing_written = hash['arts_performing_written']
    @arts_visual = hash['arts_visual']
    @before_after_care = hash['before_after_care']
    @boys_sports = hash['boys_sports']
    @city = hash['city']
    @community_rating = hash['community_rating']
    @database_state = hash['school_database_state']
    @distance = hash['distance']
    @dress_code = hash['dress_code']
    @enrollment = hash['school_size']
    @foreign_language = hash['foreign_language']
    @girls_sports = hash['girls_sports']
    @grade_range = hash['school_grade_range']
    @id = hash['school_id']
    @immersion_language = hash['immersion_language']
    @instructional_model = hash['instructional_model']
    @latitude = hash['school_latitude']
    @level = hash['grades']
    @level_code = hash['level_code']
    @longitude = hash['school_longitude']
    @name = hash['school_name']
    @on_page = hash['on_page']
    @overall_gs_rating = hash['overall_gs_rating']
    @profile_path = hash['school_profile_path']
    @review_count = hash['school_review_count_ruby']
    @school_media_first_hash = hash['school_media_first_hash']
    @state = hash['state']
    @state_name = hash['state_name']
    @street = hash['street']
    @students_vouchers = hash['students_vouchers']
    @summer_program = hash['summer_program']
    @transportation = hash['transportation']
    @type = hash['school_type']
    @voucher_type = hash['voucher_type']
    @zip = hash['zip']
    @zipcode = hash['zip']
  end

  def preschool?
    (!level_code.nil? && level_code == 'p')
  end
end
